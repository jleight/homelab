"""The interceptor's Ambient (observer) device type, extended for this station.

The stock parser only knows the core outdoor fields and drops everything else,
including the WS-2000's extra channels, the AQIN air monitor and the lightning
detector. This adds an 'ambient' device type that maps them, and adds the
database columns the stock schema has no place for.

Field meanings and units are from Ambient's device data specs:
https://github.com/ambient-weather/api-docs/wiki/Device-Data-Specs
"""

import weewx.manager
import weewx.units

from user.interceptor import *  # noqa: F401,F403 - DRIVER_NAME, confeditor_loader
from user.interceptor import (
    DRIVER_NAME,
    Consumer,
    InterceptorDriver,
    Observer,
    loginf,
)

CHANNELS = range(1, 9)

# Readings with no column in the stock wview_extended schema.
NEW_COLUMNS = {
    'pm2_5_in': 'group_concentration',
    'pm10_0_in': 'group_concentration',
    'aqinTemp': 'group_temperature',
    'aqinHumidity': 'group_percent',
    'co2BatteryStatus': None,
    'lightningBatteryStatus': None,
}

for _name, _group in NEW_COLUMNS.items():
    if _group:
        weewx.units.obs_group_dict[_name] = _group

# Ambient reports most batteries as 1=OK, 0=low; WeeWX uses 0=OK, 1=low.
# The lightning detector is the exception and already reports 1=low.
INVERTED_BATTERIES = (
    ['battery_out', 'battery_in', 'battery_co2']
    + ['battery_%d' % n for n in CHANNELS]
)


class AmbientObserver(Observer):

    class Parser(Observer.Parser):

        LABEL_MAP = dict(Observer.Parser.LABEL_MAP)
        LABEL_MAP.update({
            # The console's own sea-level pressure, which its calibration
            # applies to, rather than WeeWX's estimate from altitude.
            'baromrelin': 'barometer',
            'hourlyrainin': 'rain_rate',
            'battout': 'battery_out',
            'battin': 'battery_in',
            'co2_in_aqin': 'co2',
            'pm25_in_aqin': 'pm2_5_in',
            'pm10_in_aqin': 'pm10_0_in',
            'pm_in_temp_aqin': 'temperature_aqin',
            'pm_in_humidity_aqin': 'humidity_aqin',
            'batt_co2': 'battery_co2',
            'batt_lightning': 'battery_lightning',
            'lightning_day': 'lightning_day',
            'lightning_distance': 'lightning_distance',
        })
        for _n in CHANNELS:
            LABEL_MAP['temp%df' % _n] = 'temperature_%d' % _n
            LABEL_MAP['humidity%d' % _n] = 'humidity_%d' % _n
            LABEL_MAP['batt%d' % _n] = 'battery_%d' % _n

        # Values the console derives from the readings above. WeeWX computes
        # its own versions, so these are dropped without logging.
        IGNORED_LABELS = Observer.Parser.IGNORED_LABELS + [
            'stationtype', 'maxdailygust', 'eventrainin',
            'winddir_avg10m', 'windspdmph_avg10m',
            'co2_in_24h_aqin', 'pm25_in_24h_aqin', 'pm10_in_24h_aqin',
            'aqi_pm25_aqin', 'aqi_pm10_aqin',
            'aqi_pm25_24h_aqin', 'aqi_pm10_24h_aqin',
            'lightning_hour', 'lightning_time',
        ]

        def __init__(self):
            super().__init__()
            self._last_lightning = None

        def parse(self, s):
            pkt = super().parse(s)

            for label in INVERTED_BATTERIES:
                if pkt.get(label) is not None:
                    pkt[label] = 0 if pkt[label] else 1

            # lightning_day is a running count that resets at midnight; WeeWX
            # wants the strikes since the last packet. The distance is that of
            # the last strike, which may be hours old, so it is only kept when
            # this packet brought new strikes.
            day = pkt.pop('lightning_day', None)
            distance = pkt.pop('lightning_distance', None)
            if day is not None:
                last = self._last_lightning
                if last is not None:
                    strikes = day - last if day >= last else day
                    pkt['lightning_strike_count'] = strikes
                    if strikes > 0 and distance is not None:
                        pkt['lightning_distance'] = distance
                self._last_lightning = day

            return pkt

    SENSOR_MAP = dict(Consumer.DEFAULT_SENSOR_MAP)
    SENSOR_MAP.update({
        'outTempBatteryStatus': 'battery_out',
        'inTempBatteryStatus': 'battery_in',
        'co2': 'co2',
        'pm2_5_in': 'pm2_5_in',
        'pm10_0_in': 'pm10_0_in',
        'aqinTemp': 'temperature_aqin',
        'aqinHumidity': 'humidity_aqin',
        'co2BatteryStatus': 'battery_co2',
        'lightningBatteryStatus': 'battery_lightning',
        'lightning_strike_count': 'lightning_strike_count',
        'lightning_distance': 'lightning_distance',
    })
    for _n in CHANNELS:
        SENSOR_MAP['extraTemp%d' % _n] = 'temperature_%d' % _n
        SENSOR_MAP['extraHumid%d' % _n] = 'humidity_%d' % _n
        SENSOR_MAP['batteryStatus%d' % _n] = 'battery_%d' % _n

    def __init__(self, **stn_dict):
        # Observer hard-codes its own Parser, so go around it.
        Consumer.__init__(
            self, AmbientObserver.Parser(), handler=Observer.Handler,
            **stn_dict)

    def default_sensor_map(self):
        return dict(AmbientObserver.SENSOR_MAP)


InterceptorDriver.DEVICE_TYPES['ambient'] = AmbientObserver


def loader(config_dict, _):
    _ensure_columns(config_dict)
    return InterceptorDriver(**config_dict[DRIVER_NAME])


def _ensure_columns(config_dict):
    # The driver loads before the archive service opens the database, so
    # columns added here are in place for the first record.
    with weewx.manager.open_manager_with_config(
            config_dict, 'wx_binding', initialize=True) as dbm:
        for name in NEW_COLUMNS:
            if name not in dbm.obskeys:
                dbm.add_column(name)
                loginf('added column %s to the archive' % name)
