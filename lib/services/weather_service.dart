import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/hourly_weather_model.dart';
import '../models/forecast_model.dart';
import '../models/weather_model.dart';

class WeatherService {
  /// Fetch current weather by latitude and longitude
  Future<WeatherModel> getCurrentWeather({
    required double lat,
    required double lon,
  }) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}/weather?lat=$lat&lon=$lon&units=metric&appid=${ApiConfig.apiKey}',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return WeatherModel.fromJson(data);
    } else {
      throw Exception('Failed to load current weather: ${response.statusCode}');
    }
  }

  /// Fetch hourly and daily forecast by latitude and longitude
  Future<Map<String, dynamic>> getForecast({
    required double lat,
    required double lon,
  }) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}/forecast?lat=$lat&lon=$lon&units=metric&appid=${ApiConfig.apiKey}',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      final int timezoneOffset = data['city']['timezone'] ?? 0;
      final List list = data['list'] as List;

      final hourly = list.take(8).map((e) {
        final dt = DateTime.fromMillisecondsSinceEpoch(
          (e['dt'] + timezoneOffset) * 1000,
          isUtc: true,
        );
        return HourlyWeatherModel(
          time: dt,
          temperature: (e['main']['temp']).toDouble(),
          icon: e['weather'][0]['icon'],
        );
      }).toList();

      Map<String, List<dynamic>> dailyMap = {};
      for (var e in list) {
        final dt = DateTime.fromMillisecondsSinceEpoch(
          (e['dt'] + timezoneOffset) * 1000,
          isUtc: true,
        );
        final dayKey = "${dt.year}-${dt.month}-${dt.day}";
        if (!dailyMap.containsKey(dayKey)) dailyMap[dayKey] = [];
        dailyMap[dayKey]!.add(e);
      }

      final daily = dailyMap.entries.take(5).map((entry) {
        final temps = entry.value
            .map((e) => (e['main']['temp']).toDouble())
            .toList();
        final icons = entry.value
            .map((e) => e['weather'][0]['icon'] as String)
            .toList();
        final dtSample = DateTime.fromMillisecondsSinceEpoch(
          (entry.value[0]['dt'] + timezoneOffset) * 1000,
          isUtc: true,
        );
        return DailyForecastModel(
          date: dtSample,
          minTemp: temps.reduce((a, b) => a < b ? a : b),
          maxTemp: temps.reduce((a, b) => a > b ? a : b),
          icon: icons[0],
        );
      }).toList();

      return {'hourly': hourly, 'daily': daily};
    } else {
      throw Exception(
        'Failed to load forecast data: ${response.statusCode}',
      ); // Throw error
    }
  }

  /// Fetch current weather by city name
  Future<WeatherModel> getCurrentWeatherByCity(String city) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}/weather?q=${Uri.encodeComponent(city)}&appid=${ApiConfig.apiKey}&units=metric',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return WeatherModel.fromJson(data);
    } else {
      throw Exception('Cannot load weather for $city');
    }
  }
}
