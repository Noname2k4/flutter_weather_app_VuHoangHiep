import 'package:flutter/foundation.dart';

enum WeatherLayer { temperature, wind, precipitation, clouds }

class MapProvider with ChangeNotifier {
  double _lat = 0.0;
  double _lon = 0.0;
  WeatherLayer _currentLayer = WeatherLayer.temperature;

  double get lat => _lat;
  double get lon => _lon;
  WeatherLayer get currentLayer => _currentLayer;

  String get layerName {
    switch (_currentLayer) {
      case WeatherLayer.temperature:
        return 'temp_new';
      case WeatherLayer.wind:
        return 'wind_new';
      case WeatherLayer.precipitation:
        return 'precipitation_new';
      case WeatherLayer.clouds:
        return 'clouds_new';
    }
  }

  void setLayer(WeatherLayer layer) {
    _currentLayer = layer;
    notifyListeners();
  }

  void setLocation(double lat, double lon) {
    _lat = lat;
    _lon = lon;
    notifyListeners();
  }
}
