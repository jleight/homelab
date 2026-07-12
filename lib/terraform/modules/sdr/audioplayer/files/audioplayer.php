<?php
// audioplayer.php — a no-database Trunk Recorder web player.
//
// A fork of upstream trunk-recorder/utils/audioplayer.php, rewritten to be fast
// over an SMB share. Upstream walks the ENTIRE capture tree and stat()s every
// recording on every 10-second poll; against a network share that is painfully
// slow. This version instead:
//
//   * Scans only ONE day's directory (<capture>/<system>/YYYY/MM/DD) — the day
//     the request asks for — rather than the whole tree.
//   * Treats completed (past) days as immutable: the first time one is viewed we
//     write a lean per-day JSON summary to the share; later views read the
//     summary and never touch the recording directory again.
//   * Scans the current day live (it's still growing), but stats only the files
//     a request will actually display — filenames carry the talkgroup, epoch and
//     frequency, so filtering/sorting/slicing all happen before any stat().
//
// The page (HTML) render does no scanning at all; only the ?since= AJAX endpoint
// touches the filesystem. Talkgroup labels and the encrypted-talkgroup filter
// are resolved at read time from the CSVs (not baked into summaries), so editing
// a talkgroup file takes effect immediately and old summaries stay valid.

$FileType = 'm4a';

date_default_timezone_set(getenv('TZ') ?: 'UTC');

$CONFIG = (function (string $configFilePath = '/var/www/configs/config.json') {
    if (!file_exists($configFilePath)) {
        return false;
    }

    return json_decode(file_get_contents($configFilePath));
})();

if (false === $CONFIG) {
    $error = 'Config file does not exist';
    goto html;
}

if (empty($CONFIG->systems)) {
    $error = 'No systems found in config file';
    goto html;
}

// Activity logging to the container log (via Apache's stderr — `kubectl logs`).
// Configurable logLevel: "quiet" (warnings only), "info" (default — the one-time
// per-day summary builds + warnings), or "debug" (also every live scan, cache
// hit and request). error_log() writes regardless of the display_errors setting.
$LOG_LEVELS  = ['error' => 0, 'info' => 1, 'debug' => 2];
$_confLevel  = strtolower($CONFIG->logLevel ?? 'info');
$_confLevel  = ($_confLevel === 'quiet') ? 'error' : $_confLevel;
$LOG_LEVEL   = $LOG_LEVELS[$_confLevel] ?? 1;
$logAt = function (string $level, string $msg) use ($LOG_LEVELS, $LOG_LEVEL): void {
    if (($LOG_LEVELS[$level] ?? 1) <= $LOG_LEVEL) {
        error_log("[audioplayer] {$msg}");
    }
};

$FileType   = $CONFIG->fileType ?? $FileType;
$captureDir = rtrim($CONFIG->captureDir, '/');
// Stripped from a recording's on-disk path to turn it into an Apache URL (the
// recordings live inside the document root under /media).
$baseDir  = rtrim($CONFIG->baseDir ?? '', '/');
$indexDir = rtrim($CONFIG->indexDir ?? '', '/');
// Row cap for the initial unfiltered "today" load only (see the slice below).
// 0 disables it.
$initialLimit = (int) ($CONFIG->initialLimit ?? 100);

// Talkgroup label + mode lookup, keyed [system][decimal-TGID]. Loaded from the
// labelled CSVs on every request (cheap, local ConfigMap files) so it always
// reflects the current talkgroup list and never has to live in the summaries.
$TGFile = function (?string $tgFilePath): array {
    $return = [];

    if (!$tgFilePath || !file_exists($tgFilePath)) {
        return $return;
    }

    $radioreference_format = false;
    foreach (file($tgFilePath) as $line) {
        if (trim($line) === '') {
            continue;
        }
        // Explicit escape="" (RFC-4180 behaviour) — silences PHP 8.5's
        // str_getcsv() deprecation and is fine for these simple label files.
        if (!$radioreference_format) {
            [$DEC, $HEX, $Mode, $AlphaTag, $Description, $Tag, $Group, $Priority] = array_pad(str_getcsv($line, ',', '"', ''), 8, null);
        } else {
            [$DEC, $HEX, $AlphaTag, $Mode, $Description, $Tag, $Group] = array_pad(str_getcsv($line, ',', '"', ''), 7, null);
        }
        if ($DEC == 'Decimal') {
            $radioreference_format = true;
            continue;
        }
        $return[$DEC] = ['tag' => $AlphaTag, 'mode' => $Mode];
    }

    return $return;
};

$TGS = [];
foreach ($CONFIG->systems as $system) {
    $TGS[$system->shortName] = $TGFile($system->talkgroupsFile ?? null);
}

// ── Directory / summary helpers ────────────────────────────────────────────

// <capture>/<system>/Y/M/D for a Y-m-d date string, so we can jump straight to a
// day's folder. Trunk Recorder writes the month and day WITHOUT leading zeros
// (e.g. 2026/7/1), so build that; fall back to a zero-padded variant in case a
// build differs, resolving to whichever actually exists.
$dayDir = function (string $shortName, string $dateStr) use ($captureDir): string {
    $dt   = new DateTimeImmutable($dateStr);
    $base = "{$captureDir}/{$shortName}";
    foreach (['Y/n/j', 'Y/m/d'] as $fmt) {
        $candidate = "{$base}/{$dt->format($fmt)}";
        if (is_dir($candidate)) {
            return $candidate;
        }
    }
    return "{$base}/{$dt->format('Y/n/j')}";
};

// Parse a recording filename (TGID-EPOCH_FREQ.ext) into a record. No stat() —
// everything but the file size comes from the name and path. Returns null for
// anything that isn't a recording of the expected type/shape.
$parseFile = function (string $dir, string $filename) use ($FileType, $baseDir): ?array {
    if (pathinfo($filename, PATHINFO_EXTENSION) !== $FileType) {
        return null;
    }
    $parts = preg_split('/[-_]/', pathinfo($filename, PATHINFO_FILENAME));
    if (count($parts) < 3) {
        return null;
    }
    [$TGID, $TIME, $FREQ] = $parts;
    // Trunk Recorder timestamps can carry fractional seconds (e.g. 1781566145.024)
    // and the frequency a trailing ".0", so accept any numeric epoch (truncated to
    // a whole second) rather than requiring digits only.
    if (!is_numeric($TIME)) {
        return null;
    }

    $full = "{$dir}/{$filename}";

    return [
        'path'       => ($baseDir !== '') ? str_ireplace($baseDir, '', $full) : $full,
        'fullpath'   => $full, // transient; used to stat live rows, never serialized
        'tgid'       => $TGID,
        'unix_date'  => (int) $TIME,
        'frequency'  => ((float) $FREQ / 1000000),
    ];
};

// Every recording in one day's directory, as name-parsed records (no stat).
$scanDay = function (string $shortName, string $dateStr) use ($dayDir, $parseFile): array {
    $dir = $dayDir($shortName, $dateStr);
    if (!is_dir($dir)) {
        return [];
    }

    $records = [];
    foreach (scandir($dir) ?: [] as $filename) {
        if ($filename === '.' || $filename === '..') {
            continue;
        }
        $rec = $parseFile($dir, $filename);
        if ($rec === null) {
            continue;
        }
        $rec['systemname'] = $shortName;
        $records[] = $rec;
    }

    return $records;
};

// Fill in size_kb by stat()ing each record, dropping files that are missing or
// too small to play (upstream's <1 KiB filter for truncated recordings). Rows
// that already carry size_kb (i.e. loaded from a summary) pass straight through
// without a stat.
$statRecords = function (array $records): array {
    $out = [];
    foreach ($records as $rec) {
        if (isset($rec['size_kb'])) {
            $out[] = $rec;
            continue;
        }
        $bytes = @filesize($rec['fullpath']);
        if ($bytes === false || $bytes < 1024) {
            continue;
        }
        $rec['size_kb'] = (int) round($bytes / 1024);
        $out[] = $rec;
    }

    return $out;
};

$summaryPath = function (string $shortName, string $dateStr) use ($indexDir): string {
    return "{$indexDir}/{$shortName}/{$dateStr}.json";
};

$readSummary = function (string $shortName, string $dateStr) use ($indexDir, $summaryPath): ?array {
    if ($indexDir === '') {
        return null;
    }
    $p = $summaryPath($shortName, $dateStr);
    if (!file_exists($p)) {
        return null;
    }
    $data = json_decode(file_get_contents($p), true);

    return is_array($data) ? $data : null;
};

// Persist a completed day's fully-stat'd records. Written to a temp file and
// renamed so a reader never sees a half-written summary; a racing writer just
// re-publishes identical data. Only the lean, stable fields are stored — labels
// and the encrypted filter are re-derived from the CSVs at read time.
$writeSummary = function (string $shortName, string $dateStr, array $records) use ($indexDir, $summaryPath, $logAt): void {
    if ($indexDir === '') {
        return;
    }
    $p   = $summaryPath($shortName, $dateStr);
    $dir = dirname($p);
    if (!is_dir($dir) && !@mkdir($dir, 0777, true) && !is_dir($dir)) {
        $logAt('error', "WARN could not create index directory {$dir}");
        return;
    }

    $lean = array_map(fn ($r) => [
        'path'       => $r['path'],
        'size_kb'    => $r['size_kb'],
        'tgid'       => $r['tgid'],
        'unix_date'  => $r['unix_date'],
        'frequency'  => $r['frequency'],
        'systemname' => $r['systemname'],
    ], $records);

    $tmp = "{$p}.tmp." . getmypid();
    if (@file_put_contents($tmp, json_encode($lean)) === false || !@rename($tmp, $p)) {
        $logAt('error', "WARN could not write summary {$p}");
        @unlink($tmp);
        return;
    }
    $logAt('debug', "wrote summary {$p} (" . count($lean) . " calls)");
};

// Records for one system on one date. Past days come from the summary (built and
// cached on first view); the current/future day is always scanned live and left
// unsized so the caller only stats what it shows.
$recordsForSystemDate = function (string $shortName, string $dateStr, string $today)
    use ($dayDir, $scanDay, $statRecords, $readSummary, $writeSummary, $logAt): array {
    if ($dateStr < $today) {
        $cached = $readSummary($shortName, $dateStr);
        if ($cached !== null) {
            $logAt('debug', "summary cache hit: {$shortName} {$dateStr} (" . count($cached) . " calls)");
            return $cached;
        }
        $dir = $dayDir($shortName, $dateStr);
        // A day with no directory at all (e.g. a date scrubbed in the picker that
        // predates this system) is empty — don't litter the index with a summary.
        if (!is_dir($dir)) {
            $logAt('debug', "no recordings directory: {$shortName} {$dateStr} ({$dir})");
            return [];
        }
        // First view of a completed day: scan + size everything once, then cache.
        // This is the one heavy filesystem pass, so log it at info.
        $t0      = microtime(true);
        $scanned = $scanDay($shortName, $dateStr);
        $records = $statRecords($scanned);
        $writeSummary($shortName, $dateStr, $records);
        $ms = (int) round((microtime(true) - $t0) * 1000);
        $logAt('info', "built summary: {$shortName} {$dateStr} — scanned " . count($scanned) . " files, " . count($records) . " playable, {$ms}ms ({$dir})");

        return $records;
    }

    // Current/future day: always scanned live (cheap — one directory, no stats yet).
    $t0      = microtime(true);
    $records = $scanDay($shortName, $dateStr);
    $ms      = (int) round((microtime(true) - $t0) * 1000);
    $logAt('debug', "live scan: {$shortName} {$dateStr} — " . count($records) . " files, {$ms}ms (" . $dayDir($shortName, $dateStr) . ")");

    return $records;
};

// ── AJAX endpoint: files for a date, newer than `since` ──────────────────────

if (isset($_REQUEST['since'])) {
    $since     = (int) $_REQUEST['since'];
    $filter_tg = (empty($_GET['tg'])) ? null : $_GET['tg'];
    $today     = (new DateTimeImmutable())->format('Y-m-d');

    try {
        $dateStr = (!empty($_GET['date']))
            ? (new DateTimeImmutable($_GET['date']))->format('Y-m-d')
            : $today;
    } catch (Exception $e) {
        $dateStr = $today;
    }

    // Gather the day's records across all systems, then filter by talkgroup
    // (name-based, no stat).
    $records = [];
    foreach ($CONFIG->systems as $system) {
        foreach ($recordsForSystemDate($system->shortName, $dateStr, $today) as $rec) {
            if ($filter_tg !== null && (string) $rec['tgid'] != (string) $filter_tg) {
                continue;
            }
            $records[] = $rec;
        }
    }

    // Newest matching recording on this date — the client advances its cursor to
    // this so subsequent polls only return what arrives later.
    $latest = 0;
    foreach ($records as $rec) {
        if ($rec['unix_date'] > $latest) {
            $latest = $rec['unix_date'];
        }
    }

    // Only the files newer than the client's cursor, oldest-first (TIME then FREQ
    // to match upstream ordering).
    $records = array_values(array_filter($records, fn ($r) => $r['unix_date'] > $since));
    usort($records, fn ($a, $b) => ($a['unix_date'] <=> $b['unix_date']) ?: ($a['frequency'] <=> $b['frequency']));

    // Cap the initial unfiltered load only for the live "today" view: it bounds
    // the stat() count (today's rows aren't sized yet) and keeps the feed recent.
    // A specific past day is served from its already-sized summary, so we return
    // the whole day — pick a date to browse it in full. A talkgroup filter is
    // never capped.
    if ($since === 0 && $filter_tg === null && $dateStr === $today && $initialLimit > 0) {
        $records = array_slice($records, -$initialLimit);
    }

    // Size the survivors (no-op for summary rows, which already carry size_kb).
    $records = $statRecords($records);

    // Resolve talkgroup label and drop permanently-encrypted talkgroups (current
    // trunk-recorder still records these, producing unplayable audio).
    $newfiles = [];
    foreach ($records as $r) {
        $tg = $TGS[$r['systemname']][$r['tgid']] ?? null;
        if ($tg !== null && isset($tg['mode']) && stripos($tg['mode'], 'E') !== false) {
            continue;
        }
        $newfiles[] = [
            'path'       => $r['path'],
            'size_kb'    => $r['size_kb'],
            'talkgroup'  => $tg['tag'] ?? $r['tgid'],
            'unix_date'  => $r['unix_date'],
            'date'       => date("Y-m-d\TH:i:s\Z", $r['unix_date']),
            'frequency'  => $r['frequency'],
            'systemname' => $r['systemname'],
        ];
    }

    $logAt('debug', "request: date={$dateStr} tg=" . ($filter_tg ?? 'all') . " since={$since} — returned " . count($newfiles) . " calls, latest={$latest}");

    header('Content-Type: application/json');
    echo json_encode([
        'latest'   => $latest,
        'newfiles' => $newfiles,
    ]);
    exit();
}

html:
?>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
        <meta name="format-detection" content="telephone=no">
        <title>Trunk Player</title>
        <link href="https://stackpath.bootstrapcdn.com/bootswatch/4.5.0/flatly/bootstrap.min.css" rel="stylesheet" integrity="sha384-mhpbKVUOPCSocLzx2ElRISIORFRwr1ZbO9bAlowgM5kO7hnpRBe+brVj8NNPUiFs" crossorigin="anonymous">
        <link href="https://stackpath.bootstrapcdn.com/bootswatch/4.5.0/flatly/bootstrap.min.css" rel="stylesheet" integrity="sha384-mhpbKVUOPCSocLzx2ElRISIORFRwr1ZbO9bAlowgM5kO7hnpRBe+brVj8NNPUiFs" crossorigin="anonymous" media="(prefers-color-scheme: light)">
        <link href="https://stackpath.bootstrapcdn.com/bootswatch/4.5.0/darkly/bootstrap.min.css" rel="stylesheet" integrity="sha384-Bo21yfmmZuXwcN/9vKrA5jPUMhr7znVBBeLxT9MA4r2BchhusfJ6+n8TLGUcRAtL" crossorigin="anonymous" media="(prefers-color-scheme: dark)">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/select2/4.0.13/css/select2.min.css" integrity="sha512-nMNlpuaDPrqlEls3IX/Q56H36qvBASwb3ipuo3MxeWbsQB1881ox0cRv7UPTgBlriqoynt35KjEwgGUeUXIPnw==" crossorigin="anonymous" referrerpolicy="no-referrer" />

        <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.6.0/jquery.min.js" integrity="sha512-894YE6QWD5I59HgZOGReFYm4dnWc1Qt5NtvYSaNcOP+u1T9qYdvdihz0PPSiiqn/+/3e7Jo4EaG7TubfWGUrMQ==" crossorigin="anonymous" referrerpolicy="no-referrer"></script>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/handlebars.js/4.7.7/handlebars.min.js" integrity="sha512-RNLkV3d+aLtfcpEyFG8jRbnWHxUqVZozacROI4J2F1sTaDqo1dPQYs01OMi1t1w9Y2FdbSCDSQ2ZVdAC8bzgAg==" crossorigin="anonymous" referrerpolicy="no-referrer"></script>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/select2/4.0.13/js/select2.min.js" integrity="sha512-2ImtlRlf2VVmiGZsjm9bEyhjGW4dU7B6TNwh/hx/iSByxNENtj3WVE6o/9Lj4TJeVXPi4bnOIMXFIJJAeufa0A==" crossorigin="anonymous" referrerpolicy="no-referrer"></script>
        <style>
            #interface, audio {
                width: 100%;
            }
            table {
                text-align: center;
            }
            .select2-selection {
                height: calc(1.5em + .75rem + 2px) !important;
            }
        </style>
    </head>
    <body>
        <div class="container">
            <div id="interface">
                <div class="row">
                    <div class="form-group col-lg-4">
                        <label class="form-control-label" for="date">Date</label>
                        <input class="form-control" id="date" name="date" type="date" value="<?=date('Y-m-d')?>" />
                    </div>
                    <div class="form-group col-lg-4">
                        <label class="form-control-label" for="tg">Talk Group</label>
                        <select class="form-control" id="tg" name="tg">
                            <option value="">All Calls</option>
<?php   foreach ($CONFIG->systems as $system):  ?>
                            <optgroup value="<?=$system->shortName?>">
<?php       foreach ($TGS[$system->shortName] as $TGID => $data): ?>
                            <option value="<?=$TGID?>"><?=$data['tag']?> (<?=$TGID?>, <?=$data['mode']?>)</option>
<?php       endforeach; ?>
                            </optgroup>
<?php   endforeach; ?>
                        </select>
                    </div>
                    <div class="form-group col-lg-4">
                        <label class="form-control-label">Controls</label>
                        <button class="btn btn-primary btn-block" type="button" onclick="updateFiles(true)">Filter</button>
                    </div>
                </div>
                <div class="row">
                    <div class="form-group col-lg-12"><button class="btn btn-primary btn-block" onclick="window.scrollTo(0, document.body.scrollHeight);">Jump to bottom</button>Click on a row to begin sequential playback. Click file size to download.</div>
                </div>
            </div>
            <table class="table" id="calls_table">
                <thead>
                    <tr>
                        <td>Time</td>
                        <td>Talk Group</td>
                        <td>MHz</td>
                        <td>Size</td>
                    </tr>
                </thead>
                <tbody>
<?php   if (isset($error)): ?>
                    <tr class="text-warning">
                        <th colspan="4"><?=$error?></th>
                    </tr>
<?php   endif;  ?>
            </table>
            <br />
            <br />
            <br />
            <br />
            <nav class="navbar fixed-bottom navbar-expand-sm navbar-dark bg-primary">
                <audio id="audio_player" preload="none" controls>
                    Sorry, your browser does not support HTML5 audio.
                </audio>
            </nav>
        </div>
        <script>
            var latest = 0;
            var template = Handlebars.compile(`
                <tr>
                    <td>{{ date }}</td>
                    <td>{{ talkgroup }}</td>
                    <td>{{ frequency }}</td>
                    <td><a href="{{ path }}">{{ size_kb }}k</a></td>
                </tr>
            `);
            var last_played = 0;
            var auto_play_new_row = false;

            $(function () {
                updateFiles();
                setInterval(updateFiles, 10*1000);
                $('#tg').select2();

                $('#calls_table tr').on('click', onClickTableRow);

                $('#audio_player').on('ended', function () {
                    var current_row = $('#calls_table .table-active')[0];

                    var next_row = $(current_row).closest('tr').next('tr');
                    if (next_row.length > 0)
                    {
                        playAudioFromRow(next_row[0]);
                    }
                    else
                    {
                        auto_play_new_row = true;
                    }
                });
            });

            function updateFiles(clear_files=false)
            {
                if (clear_files)
                {
                    $('#audio_player').trigger('stop');
                    $('#calls_table tr').remove();
                    latest = 0;
                }
                $.ajax({
                    url: window.location.pathname,
                    data: {
                        'since': latest,
                        'tg': $('#tg').val(),
                        'date': $('#date').val(),
                    },
                    success: function (data, textStatus, jqXHR) {
                        if (data.latest == 0 || data.newfiles.length == 0) return;

                        $(data.newfiles).each(function (i, newcall) {
                            var new_row_html = template(newcall);
                            var new_row_ref = $(new_row_html).appendTo($('#calls_table tbody'));
                            if (auto_play_new_row)
                            {
                                auto_play_new_row = false;
                                playAudioFromRow(new_row_ref);
                            }
                        });
                        latest = data.latest;

                        // refresh click handlers to account for new rows
                        $('#calls_table tr').off();
                        $('#calls_table tr').on('click', onClickTableRow);
                    }
                });
            }

            function onClickTableRow()
            {
                playAudioFromRow(this);
            }

            function playAudioFromRow(row)
            {
                $('#calls_table .table-active').removeClass('table-active');
                $(row).addClass('table-active');

                var dllink = $($(row).find('a')[0])
                $('#audio_player').attr('src', dllink.attr('href'));
                $('#audio_player').trigger('play');
            }
        </script>
    </body>
</html>
