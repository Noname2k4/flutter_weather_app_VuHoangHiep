import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';
import '../models/hourly_weather_model.dart';
import '../models/forecast_model.dart';

class WeatherProvider extends ChangeNotifier {
  final WeatherService service;

  WeatherProvider({WeatherService? service})
    : service = service ?? WeatherService();

  List<HourlyWeatherModel> hourlyForecast = [];
  List<DailyForecastModel> dailyForecast = [];

  WeatherModel? weather;
  bool isLoading = false;
  String? error;

  /// Fetches current weather by latitude and longitude
  Future<void> fetchWeather(double lat, double lon) async {
    try {
      isLoading = true;
      notifyListeners();

      weather = await service.getCurrentWeather(lat: lat, lon: lon);
      error = null;
    } catch (e) {
      error = e.toString();
      weather = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Fetches hourly and daily forecast by latitude and longitude
  Future<void> fetchForecast(double lat, double lon) async {
    try {
      isLoading = true;
      notifyListeners();

      final data = await service.getForecast(lat: lat, lon: lon);
      hourlyForecast = data['hourly'];
      dailyForecast = data['daily'];
      error = null;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Fetches current weather by city name
  Future<void> fetchWeatherByCity(String cityName) async {
    try {
      isLoading = true;
      notifyListeners();

      weather = await service.getCurrentWeatherByCity(cityName);
      error = null;
    } catch (e) {
      error = e.toString();
      weather = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Fetches hourly and daily forecast by city name
  Future<void> fetchForecastByCity(String cityName) async {
    try {
      isLoading = true;
      notifyListeners();

      final current = await service.getCurrentWeatherByCity(cityName);
      final data = await service.getForecast(
        lat: current.latitude,
        lon: current.longitude,
      );

      hourlyForecast = data['hourly'];
      dailyForecast = data['daily'];
      error = null;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
