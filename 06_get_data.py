import requests
from datetime import datetime, timedelta
import pandas as pd
import matplotlib.pyplot as plt
import os

today = datetime.now()
week_ago = today - timedelta(days=7)

start_date = week_ago.strftime("%Y-%m-%d")
end_date = today.strftime("%Y-%m-%d")

url = f"https://api.open-meteo.com/v1/forecast?latitude=25.3969&longitude=68.3772&start_date={start_date}&end_date={end_date}&daily=temperature_2m_max,temperature_2m_min"

response = requests.get(url)
data = response.json()
print(data)

daily_data = data["daily"]
df = pd.DataFrame({
    "date" : daily_data["time"],
    "max_temp" : daily_data["temperature_2m_max"],
    "min_temp" : daily_data["temperature_2m_min"]
})

df["date"] = pd.to_datetime(df["date"])
print(df)

plt.figure(figsize=(10, 6))
plt.plot(df["date"], df["max_temp"], marker="o", label="Max_Temp")
plt.plot(df["date"], df["min_temp"], marker="o", label="Min_Temp")

plt.xlabel("date")
plt.ylabel("Temperature (°C)")
plt.title("Hyderabad Temperature - Past 7 Days")
plt.legend()

plt.xticks(rotation=45)
plt.tight_layout()

plt.savefig("Hyderabad_weather.png")
plt.show()

if not os.path.exists("data"):
    os.makedirs("data")
df.to_csv("data/Hyderabad_weather.csv", index=False)
print("Data Saved to CSV")