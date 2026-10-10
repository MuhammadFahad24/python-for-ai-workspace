# import
import requests
import pandas as pd
import matplotlib.pyplot as plt
import os

url = "https://api.open-meteo.com/v1/forecast"

params = {
    "latitude" : 25.3969,
    "longitude" : 68.3772,
    "daily" : "temperature_2m_max,temperature_2m_min",
    "forecast_days" : 7
}

response = requests.get(url, params=params)
data = response.json()
dates = data["daily"]["time"]
min_temp = data["daily"]["temperature_2m_min"]
max_temp = data["daily"]["temperature_2m_max"]

datas = {
    "Dates" : data["daily"]["time"],
    "Min_Temp" : data["daily"]["temperature_2m_min"],
    "Max_Temp" : data["daily"]["temperature_2m_max"]
}

df = pd.DataFrame(datas)

plt.figure(figsize=(10, 6))

plt.plot(df["Dates"], df["Min_Temp"], marker="o", label="Minimum Temperature")
plt.plot(df["Dates"], df["Max_Temp"], marker="o", label="Maximum Temperature")

plt.title("Hyderabad's Next 7 Days Temperature")
plt.xlabel("Dates")
plt.ylabel("Temperature (°C)")
plt.legend()

plt.xticks(rotation=45)
plt.tight_layout()

plt.savefig("Hyderabad Next 7 Days Weather")
plt.show()

if not os.path.exists("data"):
    os.makedirs("data")
df.to_csv("data/hyderabad_next_7_days_temperature")
print("Saved Successfully")