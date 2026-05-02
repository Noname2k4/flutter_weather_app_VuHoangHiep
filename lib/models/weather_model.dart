class WeatherModel {
  final String cityName;
  final double temperature;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final int windDeg;
  final int pressure;
  final int visibility;
  final DateTime sunrise;
  final DateTime sunset;
  final String description;
  final String icon;
  final DateTime dateTime;
  final double latitude;
  final double longitude;

  WeatherModel({
    required this.cityName,
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.windDeg,
    required this.pressure,
    required this.visibility,
    required this.sunrise,
    required this.sunset,
    required this.description,
    required this.icon,
    required this.dateTime,
    required this.latitude,
    required this.longitude,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final timezoneOffset = json['timezone'] ?? 0;

    return WeatherModel(
      cityName: json['name'],
      temperature: (json['main']['temp']).toDouble(),
      feelsLike: (json['main']['feels_like']).toDouble(),
      humidity: json['main']['humidity'],
      pressure: json['main']['pressure'],
      windSpeed: (json['wind']['speed']).toDouble(),
      windDeg: json['wind']['deg'] ?? 0,
      visibility: json['visibility'] ?? 0,
      sunrise: DateTime.fromMillisecondsSinceEpoch(
        (json['sys']['sunrise'] + timezoneOffset) * 1000,
        isUtc: true,
      ),
      sunset: DateTime.fromMillisecondsSinceEpoch(
        (json['sys']['sunset'] + timezoneOffset) * 1000,
        isUtc: true,
      ),
      description: json['weather'][0]['description'],
      icon: json['weather'][0]['icon'],
      dateTime: DateTime.fromMillisecondsSinceEpoch(
        (json['dt'] + timezoneOffset) * 1000,
        isUtc: true,
      ),
      latitude: (json["coord"]["lat"] as num).toDouble(),
      longitude: (json["coord"]["lon"] as num).toDouble(),
    );
  }

  bool get isDay {
    return dateTime.isAfter(sunrise) && dateTime.isBefore(sunset);
  }
}
