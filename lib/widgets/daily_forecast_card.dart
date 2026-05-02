import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/forecast_model.dart';

class DailyForecastCard extends StatelessWidget {
  final DailyForecastModel item;
  final bool usePlaceholder;

  const DailyForecastCard({
    super.key,
    required this.item,
    this.usePlaceholder = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: usePlaceholder
          ? const Placeholder(fallbackHeight: 40, fallbackWidth: 40)
          : Image.network('https://openweathermap.org/img/wn/${item.icon}.png'),
      title: Text(DateFormat.E().format(item.date)),
      trailing: Text('${item.minTemp}° / ${item.maxTemp}°'),
    );
  }
}
