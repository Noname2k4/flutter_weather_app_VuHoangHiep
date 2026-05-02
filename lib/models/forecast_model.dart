class DailyForecastModel {
  final DateTime date;
  final double minTemp;
  final double maxTemp;
  final String icon;

  DailyForecastModel({
    required this.date,
    required this.minTemp,
    required this.maxTemp,
    required this.icon,
  });

  factory DailyForecastModel.fromJson(
    Map<String, dynamic> json,
    int timezoneOffset,
  ) {
    final dt = DateTime.fromMillisecondsSinceEpoch(
      (json['dt'] + timezoneOffset) * 1000,
      isUtc: true,
    );
    return DailyForecastModel(
      date: dt,
      minTemp: (json['temp']['min']).toDouble(),
      maxTemp: (json['temp']['max']).toDouble(),
      icon: json['weather'][0]['icon'],
    );
  }
}
