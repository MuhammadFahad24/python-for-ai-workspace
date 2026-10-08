import requests

url = "https://api.open-meteo.com/v1/forecast"

params = {
    "latitude" : 25.3969,
    "longitude" : 68.3772,
    "daily" : "temperature_2m_max,temperature_2m_min",
    "forecast_day" : 7
}

response = requests.get(url, params=params)
data = response.json()
min_temperature = data["daily"]["temperature_2m_min"]
max_temperature = data["daily"]["temperature_2m_max"]
dates = data["daily"]["time"]

print("Hyderabad's Next 7 Days Temperature")
for i in range(7):
    print(f"Dates: {dates[i]}")
    print(f"Minimum Temperature: {min_temperature[i]}°C")
    print(f"Maximum Temperature: {max_temperature[i]}°C")