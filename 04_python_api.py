import requests

def Get_Weather():
    def get_weather(latitude, longitude):

        url = "https://api.open-meteo.com/v1/forecast"

        params = {
            "latitude" : latitude,
            "longitude" : longitude,
            "current" : "temperature_2m,wind_speed_10m"
        }

        response = requests.get(url, params=params)
        data = response.json()
        temperature = data["current"]["temperature_2m"]
        wind_speed = data["current"]["wind_speed_10m"]

        return temperature, wind_speed

    temperature, wind_speed = get_weather(
        latitude=25.3969,
        longitude=68.3772
    )

    print(f"Hyderabad's Temperature: {temperature}°C")
    print(f"Hyderabad's Wind Speed: {wind_speed}km/h")

Get_Weather()