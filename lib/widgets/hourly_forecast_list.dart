import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/hourly_weather_model.dart';

class HourlyForecastList extends StatelessWidget {
  final List<HourlyWeatherModel> items;
  final bool usePlaceholder;

  const HourlyForecastList({
    super.key,
    required this.items,
    this.usePlaceholder = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Container(
            width: 80,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(DateFormat.Hm().format(item.time)),
                usePlaceholder
                    ? const Placeholder(fallbackHeight: 40, fallbackWidth: 40)
                    : Image.network(
                        'https://openweathermap.org/img/wn/${item.icon}.png',
                        height: 40,
                        width: 40,
                      ),
                Text('${item.temperature}°'),
              ],
            ),
          );
        },
      ),
    );
  }
}
