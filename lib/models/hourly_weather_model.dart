class HourlyWeatherModel {
  final DateTime time;
  final double temperature;
  final String icon;

  /// Constructor for HourlyWeatherModel
  HourlyWeatherModel({
    required this.time,
    required this.temperature,
    required this.icon,
  });

  /// Creates HourlyWeatherModel from JSON
  factory HourlyWeatherModel.fromJson(
    Map<String, dynamic> json,
    int timezoneOffset,
  ) {
    final dt = DateTime.fromMillisecondsSinceEpoch(
      (json['dt'] + timezoneOffset) * 1000,
      isUtc: true,
    );
    return HourlyWeatherModel(
      time: dt,
      temperature: (json['temp']).toDouble(),
      icon: json['weather'][0]['icon'],
    );
  }
}
