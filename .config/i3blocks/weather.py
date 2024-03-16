#!/usr/bin/env python
import requests
from collections import namedtuple
from datetime import datetime
from optparse import OptionParser

Icon = namedtuple('Icon', 'day night')

# All Hex Codes from https://erikflowers.github.io/weather-icons/
# All Weather Codes from https://www.worldweatheronline.com/developer/api/docs/weather-icons.aspx
CODE_TO_ICON = {
    "113": Icon('\ue33d', '\ue32b'),  # Sunny / Clear
    "116": Icon('\ue302', '\ue32e'),  # Partly Cloudy
    "119": Icon('\ue312', '\ue32e'),  # Cloudy
    "122": Icon('\ue343', '\ue343'),  # Overcast
    "143": Icon('\ue313', '\ue346'),  # Mist
    "176": Icon('\ue318', '\ue333'),  # Patchy rain possible
    "179": Icon('\ue31a', '\ue335'),  # Patchy snow possible
    "182": Icon('\ue318', '\ue317'),  # Patchy sleet possible
    "185": Icon('\ue318', '\ue321'),  # Patchy freezing drizzle possible
    "200": Icon('\ue31d', '\ue31d'),  # Thundery outbreaks possible
    "227": Icon('\ue314', '\ue338'),  # Blowing snow
    "230": Icon('\ue31e', '\ue31e'),  # Blizzard
    "248": Icon('\ue313', '\ue313'),  # Fog
    "260": Icon('\ue313', '\ue326'),  # Freezing fog
    "263": Icon('\ue315', '\ue315'),  # Patchy light drizzle
    "266": Icon('\ue315', '\ue315'),  # Light drizzle
    "281": Icon('\ue321', '\ue321'),  # Freezing drizzle
    "284": Icon('\ue321', '\ue321'),  # Heavy freezing drizzle
    "293": Icon('\ue315', '\ue315'),  # Patchy light rain
    "296": Icon('\ue315', '\ue315'),  # Light rain
    "299": Icon('\ue315', '\ue315'),  # Moderate rain at times
    "302": Icon('\ue315', '\ue315'),  # Moderate rain
    "305": Icon('\ue315', '\ue315'),  # Heavy rain at times
    "308": Icon('\ue315', '\ue315'),  # Heavy rain
    "311": Icon('\ue315', '\ue315'),  # Light freezing rain
    "314": Icon('\ue315', '\ue315'),  # Moderate or heavy freezing rain
    "317": Icon('\ue315', '\ue315'),  # Light sleet
    "320": Icon('\ue315', '\ue315'),  # Moderate or heavy sleet
    "323": Icon('\ue315', '\ue315'),  # Patchy light snow
    "326": Icon('\ue315', '\ue315'),  # Light snow
    "329": Icon('\ue315', '\ue315'),  # Patchy moderate snow
    "332": Icon('\ue315', '\ue315'),  # Moderate snow
    "335": Icon('\ue315', '\ue315'),  # Patchy heavy snow
    "338": Icon('\ue315', '\ue315'),  # Heavy snow
    "350": Icon('\ue315', '\ue315'),  # Ice pellets
    "353": Icon('\ue315', '\ue315'),  # Light rain shower
    "356": Icon('\ue315', '\ue315'),  # Moderate or heavy rain shower
    "359": Icon('\ue315', '\ue315'),  # Torrential rain shower
    "362": Icon('\ue315', '\ue315'),  # Light sleet showers
    "365": Icon('\ue315', '\ue315'),  # Moderate or heavy sleet showers
    "368": Icon('\ue315', '\ue315'),  # Light snow showers
    "371": Icon('\ue315', '\ue315'),  # Moderate or heavy snow showers
    "374": Icon('\ue315', '\ue315'),  # Light showers of ice pellets
    "377": Icon('\ue315', '\ue315'),  # Moderate or heavy showers of ice pellets
    "386": Icon('\ue315', '\ue315'),  # Patchy light rain with thunder
    "389": Icon('\ue315', '\ue315'),  # Moderate or heavy rain with thunder
    "392": Icon('\ue315', '\ue315'),  # Patchy light snow with thunder
    "395": Icon('\ue315', '\ue315')   # Moderate or heavy snow with thunder
}


class WttrApi:
    def __init__(self, city, unit_degree):
        self.city = city
        self.info = self._get_current_info(city)
        self.unit_degree = unit_degree
        

    def _get_current_info(self, city):
        ''' Get current information which contains current_condition and astronomy
            (sunrise and sunset time)'''
   
        Info = namedtuple('Info', 'condition astronomy')    
        r = requests.get(f'http://wttr.in/{city}?format=j1').json()    
        condition = r['current_condition'][0]
        astronomy = r['weather'][0]['astronomy'][0]
        return Info(condition, astronomy)

    def _get_sunrise_sunset_time(self):
        astronomy = self.info.astronomy
        return astronomy['sunrise'], astronomy['sunset']    

    def _get_temperature(self):
        '''Get current temperature'''

        if self.unit_degree == 'F':
            return f'{self.info.condition["temp_F"]} \uf045'
        return f'{self.info.condition["temp_C"]} \uf03c'     
    
    @staticmethod
    def _get_datetime(time_string, local_time):
        '''Convert time string to correct datetime obj'''

        datetime_obj = datetime.strptime(time_string, '%I:%M %p')
        return datetime_obj.replace(year=local_time.year,
                                    month=local_time.month, 
                                    day=local_time.day)

    def _is_day(self):
        '''Return True if the sun hasn't set yet'''

        local_time = self.info.condition['localObsDateTime']
        local_time = datetime.strptime(local_time, '%Y-%m-%d %I:%M %p')
        sunrise, sunset = [
            self._get_datetime(time, local_time)
            for time in self._get_sunrise_sunset_time()
        ]
        return sunrise <= local_time <= sunset

    def _get_weather_icon(self):
        '''
        Get weather icon based on weather code
        You can find codes at https://www.worldweatheronline.com/developer/api/docs/weather-icons.aspx
        CODE_TO_ICON is a dictionary where keys is weather codes and values is Icon namedtuples with 'day' and 'night' attributes
        '''

        weather_code = self.info.condition['weatherCode']
        if self._is_day():
            return CODE_TO_ICON[weather_code].day
        return CODE_TO_ICON[weather_code].night

    def get_weather_status(self, short):
        '''i3blocks uses pango to render the folowin output into the desired icons'''

        temperature = self._get_temperature()
        weather_icon = self._get_weather_icon()
        if short:
            return f"<span font='Weather Icons'>{weather_icon} {temperature}</span>"
        return f"<span font='Weather Icons'>{self.city}: {weather_icon} {temperature}</span>"            

def get_options():
    ''' Get options from command line'''

    parser = OptionParser()
    parser.add_option('-f', '--farenheit', dest='farenheit',
                      action='store_true', default=False,
                      help='Report degrees in Farenheit')
    parser.add_option('-c', '--city', dest='city',
                      action='store', help='Your city', default=get_city())
    parser.add_option('-s', '--short', dest='short',
                      action='store_true', default=False,
                      help='Short report (without city name)')

    options = parser.parse_args()[0]
    return options

def get_city():
    '''Get city as determined by IP address (it works better than wttr default)'''
    r = requests.get('http://ip-api.com/json').json()
    return r['city']

def main():
    options = get_options()
    if options.farenheit:
        unit_degree = 'F'
    else:
        unit_degree = 'C'
    weather = WttrApi(options.city, unit_degree)
    print(weather.get_weather_status(options.short))

if __name__ == "__main__":
    main()

