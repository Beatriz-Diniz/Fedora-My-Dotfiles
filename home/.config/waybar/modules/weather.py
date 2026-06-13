#!/usr/bin/env python3
import requests
import json

API_KEY = "6ea5b5aaaf0c3808300e32f177fafda3"  # Substitua pela sua chave de API do OpenWeatherMap
CITY_ID = "3449319"  # Substitua pelo ID da sua cidade (pode ser obtido em https://openweathermap.org/find)
UNITS = "metric"  # Use "imperial" para Fahrenheit

# Dicionário para mapear descrições de clima a símbolos
WEATHER_SYMBOLS = {
    "clear sky": "\u2600\ufe0f",            # ☀️
    "few clouds": "\u26C5",                 # ⛅
    "scattered clouds": "\u2601",           # ☁️
    "broken clouds": "\u2601",              # ☁️
    "shower rain": "\U0001F327",            # 🌧️
    "rain": "\U0001F326",                   # 🌦️
    "thunderstorm": "\u26A1",               # ⚡
    "snow": "\u2744",                       # ❄️
    "mist": "\U0001F32B",                   # 🌫️
    "overcast clouds": "\u2601",            # ☁️
    "light rain": "\U0001F326",             # 🌦️
    "broken clouds": "\u2601",              # ☁️
    "moderate rain": "\U0001F327",          # 🌧️
    "thunderstorm with light rain": "\u26C8",# ⛈️
    "light snow": "\u2744",                 # ❄️
    "haze": "\U0001F32B",                   # 🌫️
    "fog": "\U0001F32B",                    # 🌫️
    "smoke": "\U0001F32B",                  # 🌫️
    "light intensity shower rain": "\U0001F327", # 🌦️
    "heavy intensity rain": "\U0001F327",   # 🌦️
    "thunderstorm with rain": "\U0001F327", # 🌦️
    "thunderstorm with heavy rain": "\U0001F327", # 🌦️
    "thunderstorm with heavy drizzle": "\U0001F327", # 🌦️
    "thunderstorm with light drizzle": "\U0001F327", # 🌦️
    "thunderstorm with drizzle": "\U0001F327", # 🌦️
    "moderate rain": "\U0001F327", # 🌦️
    "night": "\U0001F319",  # 🌙
    "night clear sky": "\U0001F31D",  # 🌝
    "night few clouds": "\U0001F324",  # 🌤️
    "night scattered clouds": "\U0001F325",  # 🌥️
    "night broken clouds": "\U0001F325",  # 🌥️
    "night shower rain": "\U0001F326",  # 🌦️
    "night rain": "\U0001F327",  # 🌧️
    "night thunderstorm": "\U0001F329",  # 🌩️
    "night snow": "\U0001F328",  # 🌨️
    "night mist": "\U0001F32B",  # 🌫️
    "night overcast clouds": "\u2601",  # ☁️
}

def get_weather():
    url = f"http://api.openweathermap.org/data/2.5/weather?id={CITY_ID}&appid={API_KEY}&units={UNITS}"
    response = requests.get(url)
    if response.status_code == 200:
        data = response.json()
        weather = data['weather'][0]['description']
        temp = data['main']['temp']
        symbol = WEATHER_SYMBOLS.get(weather, "\u2753")
        return f"{symbol} {temp:.1f}°C"
    else:
        return "Error fetching weather data"

def main():
    weather_info = get_weather()
    print(weather_info)
    output = weather_info
    print(json.dumps(output))

if __name__ == "__main__":
    main()
