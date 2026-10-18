"""Applies this station's settings to the image's generic WeeWX config.

Runs before weewxd on every start. The image's files are fresh each time, so
everything here is applied from scratch rather than merged.
"""

import os

import configobj

ROOT = '/home/weewx/weewx-data'
CONF = os.path.join(ROOT, 'weewx.conf')
SKIN = os.path.join(ROOT, 'skins', 'new-belchertown')

conf = configobj.ConfigObj(CONF, encoding='utf-8')

conf['Station'].update({
    'location': 'Kenmore, NY',
    'latitude': '42.961252',
    'longitude': '-78.868401',
    'altitude': ['200', 'meter'],
})

# The Ambient device type in ambient.py maps the WS-2000's extra sensors.
conf['Interceptor'].update({
    'driver': 'user.ambient',
    'device_type': 'ambient',
})

# Every report picks these up, so the console's sensors read as rooms.
defaults = conf['StdReport'].setdefault('Defaults', {})
labels = defaults.setdefault('Labels', {}).setdefault('Generic', {})
labels.update({
    'inTemp': 'First Floor Temperature',
    'inHumidity': 'First Floor Humidity',
    'extraTemp2': 'Second Floor Temperature',
    'extraHumid2': 'Second Floor Humidity',
    'extraTemp3': 'Third Floor Temperature',
    'extraHumid3': 'Third Floor Humidity',
    'co2': 'Indoor CO2',
    'pm2_5_in': 'Indoor PM2.5',
    'pm10_0_in': 'Indoor PM10',
    'aqinTemp': 'Air Monitor Temperature',
    'aqinHumidity': 'Air Monitor Humidity',
    'lightning_strike_count': 'Lightning Strikes',
    'lightning_distance': 'Lightning Distance',
})

conf.write()

# An image built before the skin was added has nothing to chart yet.
if not os.path.isdir(SKIN):
    raise SystemExit(0)

# New Belchertown falls back to built-in charts without a charts.conf, so
# start from its shipped example and add a group for the house's sensors.
charts = configobj.ConfigObj(
    os.path.join(SKIN, 'charts.conf.example'), encoding='utf-8')
charts['house'] = {
    'title': 'House',
    'show_button': 'true',
    'button_text': 'House',
    'time_length': '604800',
    'tooltip_date_format': 'LLL',
    'gapsize': '300',
    'chart1': {
        'title': 'Temperature by Floor',
        'inTemp': {},
        'extraTemp2': {},
        'extraTemp3': {},
    },
    'chart2': {
        'title': 'Humidity by Floor',
        'inHumidity': {},
        'extraHumid2': {},
        'extraHumid3': {},
    },
    'chart3': {
        'title': 'Indoor Air Quality',
        'co2': {'yAxis': '1'},
        'pm2_5_in': {},
        'pm10_0_in': {},
    },
    'chart4': {
        'title': 'Lightning',
        'type': 'column',
        'lightning_strike_count': {'aggregate_type': 'sum', 'aggregate_interval': '3600'},
        'lightning_distance': {'type': 'scatter', 'yAxis': '1'},
    },
}
charts.filename = os.path.join(SKIN, 'charts.conf')
charts.write()
