import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';

const _background = Color(0xFF071525);
const _accent = Color(0xFF8BE9FF);

void main() {
  runApp(const WeatherGlassApp());
}

class WeatherGlassApp extends StatelessWidget {
  const WeatherGlassApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather Glass',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _accent,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: _background,
        useMaterial3: true,
      ),
      home: const WeatherHomePage(),
    );
  }
}

class WeatherHomePage extends StatefulWidget {
  const WeatherHomePage({super.key});

  @override
  State<WeatherHomePage> createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {
  final _weatherService = WeatherService();
  WeatherSnapshot? _weather;
  Object? _error;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final weather = await _weatherService.fetchHyderabadForecast();
      if (!mounted) return;
      setState(() {
        _weather = weather;
        _isLoading = false;
      });
    } on Exception catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: _Atmosphere()),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final contentWidth =
                    constraints.maxWidth > 1080 ? 1080.0 : constraints.maxWidth;
                return Center(
                  child: SizedBox(
                    width: contentWidth,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: constraints.maxWidth < 480 ? 18 : 32,
                        vertical: 24,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 28),
                          if (_isLoading)
                            const _LoadingPanel()
                          else if (_error != null)
                            _ErrorPanel(
                              message: _error.toString(),
                              onRetry: _loadWeather,
                            )
                          else if (_weather != null)
                            _buildDashboard(_weather!, contentWidth)
                          else
                            const _ErrorPanel(
                              message: 'Weather data is unavailable.',
                            ),
                          const SizedBox(height: 24),
                          const Center(
                            child: Text(
                              'Weather data by Open-Meteo',
                              style: TextStyle(
                                color: Colors.white38,
                                fontSize: 12,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
          ),
          child: const Icon(Icons.cloud_outlined, color: _accent, size: 23),
        ),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'WEATHER',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.2,
                color: _accent,
              ),
            ),
            Text(
              'Glass forecast',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const Spacer(),
        IconButton.filledTonal(
          tooltip: 'Refresh forecast',
          onPressed: _isLoading ? null : _loadWeather,
          style: IconButton.styleFrom(
            backgroundColor: Colors.white.withValues(alpha: 0.1),
            foregroundColor: Colors.white,
          ),
          icon: const Icon(Icons.refresh_rounded),
        ),
      ],
    );
  }

  Widget _buildDashboard(WeatherSnapshot weather, double width) {
    final wide = width >= 760;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (wide)
          Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: 6, child: _CurrentWeatherPanel(weather: weather)),
              const SizedBox(width: 16),
              Expanded(flex: 4, child: _SunrisePanel(weather: weather)),
            ],
          )
        else ...[
          _CurrentWeatherPanel(weather: weather),
          const SizedBox(height: 16),
          _SunrisePanel(weather: weather),
        ],
        const SizedBox(height: 16),
        _buildMetrics(weather, width),
        const SizedBox(height: 26),
        Row(
          children: [
            const Text(
              '7-day forecast',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
            ),
            const Spacer(),
            Text(
              '°C',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.58),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GlassPanel(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: SizedBox(
            height: 146,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: weather.days.length,
              separatorBuilder: (context, index) => Container(
                width: 1,
                margin: const EdgeInsets.symmetric(vertical: 8),
                color: Colors.white.withValues(alpha: 0.09),
              ),
              itemBuilder: (context, index) => _ForecastDayTile(
                day: weather.days[index],
                isToday: index == 0,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Updated ${_formatTime(weather.updatedAt)} · Hyderabad',
          style: const TextStyle(color: Colors.white38, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildMetrics(WeatherSnapshot weather, double width) {
    final columns = width >= 760 ? 4 : 2;
    final metrics = [
      _MetricData(
        label: 'FEELS LIKE',
        value: '${weather.feelsLike.round()}°',
        icon: Icons.thermostat_rounded,
      ),
      _MetricData(
        label: 'HUMIDITY',
        value: '${weather.humidity.round()}%',
        icon: Icons.water_drop_outlined,
      ),
      _MetricData(
        label: 'WIND',
        value: '${weather.windSpeed.round()} km/h',
        icon: Icons.air_rounded,
      ),
      _MetricData(
        label: 'UV INDEX',
        value: weather.uvIndex.toStringAsFixed(1),
        icon: Icons.wb_sunny_outlined,
      ),
    ];

    return GridView.builder(
      itemCount: metrics.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: width < 380 ? 1.8 : 2.15,
      ),
      itemBuilder: (context, index) => _MetricCard(data: metrics[index]),
    );
  }
}

class _Atmosphere extends StatelessWidget {
  const _Atmosphere();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF112B45), _background, Color(0xFF101A35)],
            ),
          ),
          child: SizedBox.expand(),
        ),
        Positioned(
          top: -150,
          right: -80,
          child: _GlowOrb(color: Color(0xFF32C5DB), size: 360),
        ),
        Positioned(
          left: -180,
          bottom: -180,
          child: _GlowOrb(color: Color(0xFF5860BE), size: 420),
        ),
      ],
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.2),
              blurRadius: size * 0.7,
              spreadRadius: size * 0.12,
            ),
          ],
        ),
      ),
    );
  }
}

class GlassPanel extends StatelessWidget {
  const GlassPanel({
    required this.child,
    this.padding = const EdgeInsets.all(20),
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.075),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.16),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 28,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _CurrentWeatherPanel extends StatelessWidget {
  const _CurrentWeatherPanel({required this.weather});

  final WeatherSnapshot weather;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on_outlined, color: _accent, size: 18),
              const SizedBox(width: 6),
              const Text(
                'HYDERABAD',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
              const Spacer(),
              const Icon(Icons.my_location_rounded, color: _accent, size: 14),
              const SizedBox(width: 5),
              Text(
                _formatTime(weather.updatedAt),
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            weather.condition,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  '${weather.temperature.round()}°',
                  style: const TextStyle(
                    fontSize: 84,
                    height: 1.08,
                    fontWeight: FontWeight.w300,
                    letterSpacing: -5,
                  ),
                ),
              ),
              Icon(
                weatherIcon(weather.weatherCode),
                color: const Color(0xFFFFD98A),
                size: 76,
              ),
              const SizedBox(width: 12),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'H: ${weather.days.first.maximum.round()}°   '
            'L: ${weather.days.first.minimum.round()}°',
            style: const TextStyle(color: Colors.white60, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _SunrisePanel extends StatelessWidget {
  const _SunrisePanel({required this.weather});

  final WeatherSnapshot weather;

  @override
  Widget build(BuildContext context) {
    final day = weather.days.first;
    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'TODAY',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              const Icon(Icons.wb_twilight_rounded, color: _accent, size: 25),
              const SizedBox(width: 12),
              const Expanded(
                child: Text('Sunrise', style: TextStyle(color: Colors.white70)),
              ),
              Text(
                _formatTime(day.sunrise),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(color: Colors.white.withValues(alpha: 0.12), height: 1),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Icons.nights_stay_outlined, color: _accent, size: 23),
              const SizedBox(width: 12),
              const Expanded(
                child: Text('Sunset', style: TextStyle(color: Colors.white70)),
              ),
              Text(
                _formatTime(day.sunset),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Daylight ${_daylightDuration(day.sunrise, day.sunset)}',
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _MetricData {
  const _MetricData({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.data});

  final _MetricData data;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(data.icon, color: _accent, size: 17),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  data.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          Text(
            data.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _ForecastDayTile extends StatelessWidget {
  const _ForecastDayTile({required this.day, required this.isToday});

  final ForecastDay day;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 82,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            isToday ? 'Today' : _weekday(day.date),
            style: TextStyle(
              color: isToday ? _accent : Colors.white60,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Icon(
            weatherIcon(day.weatherCode),
            color: const Color(0xFFFFD98A),
            size: 23,
          ),
          const SizedBox(height: 8),
          Text(
            weatherCondition(day.weatherCode),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white54, fontSize: 10),
          ),
          const SizedBox(height: 8),
          Text(
            '${day.maximum.round()}° / ${day.minimum.round()}°',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _LoadingPanel extends StatelessWidget {
  const _LoadingPanel();

  @override
  Widget build(BuildContext context) {
    return const GlassPanel(
      padding: EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Center(
        child: Column(
          children: [
            CircularProgressIndicator(color: _accent),
            SizedBox(height: 16),
            Text('Checking the sky…', style: TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}

class _ErrorPanel extends StatelessWidget {
  const _ErrorPanel({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.cloud_off_outlined, color: Color(0xFFFFB4AB)),
              SizedBox(width: 10),
              Text(
                'Could not load the forecast',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(message, style: const TextStyle(color: Colors.white60)),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
            ),
          ],
        ],
      ),
    );
  }
}

class WeatherSnapshot {
  const WeatherSnapshot({
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.weatherCode,
    required this.updatedAt,
    required this.days,
  });

  final double temperature;
  final double feelsLike;
  final double humidity;
  final double windSpeed;
  final int weatherCode;
  final DateTime updatedAt;
  final List<ForecastDay> days;

  String get condition => weatherCondition(weatherCode);

  double get uvIndex => days.first.uvIndex;

  factory WeatherSnapshot.fromJson(Map<String, dynamic> json) {
    final current = _readMap(json, 'current');
    final daily = _readMap(json, 'daily');
    final dates = _readList(daily, 'time');
    final minimums = _readList(daily, 'temperature_2m_min');
    final maximums = _readList(daily, 'temperature_2m_max');
    final codes = _readList(daily, 'weather_code');
    final uvIndexes = _readList(daily, 'uv_index_max');
    final sunrises = _readList(daily, 'sunrise');
    final sunsets = _readList(daily, 'sunset');

    if (dates.length != 7 ||
        minimums.length != dates.length ||
        maximums.length != dates.length ||
        codes.length != dates.length ||
        uvIndexes.length != dates.length ||
        sunrises.length != dates.length ||
        sunsets.length != dates.length) {
      throw const FormatException('The forecast response is incomplete.');
    }

    return WeatherSnapshot(
      temperature: _readNumber(current, 'temperature_2m'),
      feelsLike: _readNumber(current, 'apparent_temperature'),
      humidity: _readNumber(current, 'relative_humidity_2m'),
      windSpeed: _readNumber(current, 'wind_speed_10m'),
      weatherCode: _readNumber(current, 'weather_code').round(),
      updatedAt: DateTime.parse(_readString(current, 'time')),
      days: List<ForecastDay>.generate(
        dates.length,
        (index) => ForecastDay(
          date: DateTime.parse(_readListString(dates, index)),
          minimum: _readListNumber(minimums, index),
          maximum: _readListNumber(maximums, index),
          weatherCode: _readListNumber(codes, index).round(),
          uvIndex: _readListNumber(uvIndexes, index),
          sunrise: DateTime.parse(_readListString(sunrises, index)),
          sunset: DateTime.parse(_readListString(sunsets, index)),
        ),
      ),
    );
  }
}

class ForecastDay {
  const ForecastDay({
    required this.date,
    required this.minimum,
    required this.maximum,
    required this.weatherCode,
    required this.uvIndex,
    required this.sunrise,
    required this.sunset,
  });

  final DateTime date;
  final double minimum;
  final double maximum;
  final int weatherCode;
  final double uvIndex;
  final DateTime sunrise;
  final DateTime sunset;
}

class WeatherService {
  static const _latitude = 25.3969;
  static const _longitude = 68.3772;

  Future<WeatherSnapshot> fetchHyderabadForecast() async {
    final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': '$_latitude',
      'longitude': '$_longitude',
      'current':
          'temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,wind_speed_10m',
      'daily':
          'temperature_2m_max,temperature_2m_min,weather_code,uv_index_max,sunrise,sunset',
      'forecast_days': '7',
      'temperature_unit': 'celsius',
      'wind_speed_unit': 'kmh',
      'timezone': 'auto',
    });

    final client = HttpClient()..connectionTimeout = const Duration(seconds: 12);
    try {
      final request = await client.getUrl(uri).timeout(
            const Duration(seconds: 15),
          );
      final response = await request.close().timeout(
            const Duration(seconds: 15),
          );
      final body = await response
          .transform(utf8.decoder)
          .join()
          .timeout(const Duration(seconds: 15));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException(
          'Weather service returned HTTP ${response.statusCode}.',
          uri: uri,
        );
      }

      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('The weather response is not an object.');
      }
      return WeatherSnapshot.fromJson(decoded);
    } on SocketException {
      throw const WeatherRequestException(
        'Check your internet connection and try again.',
      );
    } on FormatException {
      throw const WeatherRequestException(
        'The weather service returned an unreadable forecast.',
      );
    } on HttpException {
      rethrow;
    } on Exception catch (error) {
      throw WeatherRequestException('Could not reach the weather service: $error');
    } finally {
      client.close(force: true);
    }
  }
}

class WeatherRequestException implements Exception {
  const WeatherRequestException(this.message);

  final String message;

  @override
  String toString() => message;
}

double _readNumber(Map<String, dynamic> values, String key) {
  final value = values[key];
  if (value is num) return value.toDouble();
  throw FormatException('Missing or invalid weather value: $key.');
}

Map<String, dynamic> _readMap(Map<String, dynamic> values, String key) {
  final value = values[key];
  if (value is Map<String, dynamic>) return value;
  throw FormatException('Missing or invalid forecast section: $key.');
}

List<dynamic> _readList(Map<String, dynamic> values, String key) {
  final value = values[key];
  if (value is List<dynamic>) return value;
  throw FormatException('Missing or invalid forecast values: $key.');
}

String _readString(Map<String, dynamic> values, String key) {
  final value = values[key];
  if (value is String) return value;
  throw FormatException('Missing or invalid weather value: $key.');
}

double _readListNumber(List<dynamic> values, int index) {
  final value = values[index];
  if (value is num) return value.toDouble();
  throw const FormatException('The forecast contains an invalid value.');
}

String _readListString(List<dynamic> values, int index) {
  final value = values[index];
  if (value is String) return value;
  throw const FormatException('The forecast contains an invalid date.');
}

String weatherCondition(int code) {
  if (code == 0) return 'Clear';
  if (code <= 3) return 'Partly cloudy';
  if (code == 45 || code == 48) return 'Fog';
  if (code <= 57) return 'Drizzle';
  if (code <= 67) return 'Rain';
  if (code <= 77) return 'Snow';
  if (code <= 82) return 'Showers';
  if (code <= 86) return 'Snow showers';
  if (code >= 95) return 'Thunderstorm';
  return 'Cloudy';
}

IconData weatherIcon(int code) {
  if (code == 0) return Icons.wb_sunny_rounded;
  if (code <= 3) return Icons.cloud_queue_rounded;
  if (code == 45 || code == 48) return Icons.cloud_rounded;
  if (code <= 57) return Icons.grain_rounded;
  if (code <= 67 || (code >= 80 && code <= 82)) {
    return Icons.umbrella_rounded;
  }
  if (code <= 77 || code == 85 || code == 86) return Icons.ac_unit_rounded;
  if (code >= 95) return Icons.thunderstorm_rounded;
  return Icons.cloud_rounded;
}

String _weekday(DateTime date) {
  const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return names[date.weekday - 1];
}

String _formatTime(DateTime date) {
  final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
  final minute = date.minute.toString().padLeft(2, '0');
  final period = date.hour < 12 ? 'AM' : 'PM';
  return '$hour:$minute $period';
}

String _daylightDuration(DateTime sunrise, DateTime sunset) {
  final duration = sunset.difference(sunrise);
  return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
}
