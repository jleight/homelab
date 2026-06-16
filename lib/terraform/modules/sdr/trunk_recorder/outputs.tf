output "systems" {
  description = "Configured systems (short name, type, and channel CSV) — consumed by the audio player to label talkgroups and locate recordings."
  value = [
    for s in var.trunk_recorder.systems : {
      short_name  = s.short_name
      type        = s.type
      channel_csv = s.channel_csv
    }
  ]
}
