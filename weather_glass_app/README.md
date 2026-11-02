# Weather Glass

A responsive Flutter weather dashboard inspired by iOS glass surfaces. It uses
the same Hyderabad coordinates and Open-Meteo forecast API as
[`08_matplolib_for_temp.py`](../08_matplolib_for_temp.py), and displays live
conditions, a seven-day forecast, daily high/low temperatures, sunrise and
sunset, humidity, wind, and UV index.

## Requirements

- Flutter 3.27 or newer
- An internet connection for live weather data

## Generate native platform projects

From this directory, generate the platform folders for the devices you want to
build:

```shell
flutter create --platforms android,ios,windows,macos,linux .
```

Flutter requires macOS and Xcode to build or run the iOS app. Android and
desktop builds require their corresponding Flutter platform toolchains.

## Run

```shell
flutter pub get
flutter run
```

To select a target explicitly, run `flutter devices` and then
`flutter run -d <device-id>`.
