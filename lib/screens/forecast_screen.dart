import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../providers/map_provider.dart';

class ForecastScreen extends StatefulWidget {
  final String apiKey;
  const ForecastScreen({super.key, required this.apiKey});

  @override
  State<ForecastScreen> createState() => _ForecastScreenState();
}

class _ForecastScreenState extends State<ForecastScreen> {
  @override
  Widget build(BuildContext context) {
    final mapProvider = context.watch<MapProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _getTitle(mapProvider.currentLayer),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          PopupMenuButton<WeatherLayer>(
            onSelected: (layer) {
              mapProvider.setLayer(layer);
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: WeatherLayer.temperature,
                child: Text("🌡 Temperature"),
              ),
              PopupMenuItem(value: WeatherLayer.wind, child: Text("💨 Wind")),
              PopupMenuItem(
                value: WeatherLayer.precipitation,
                child: Text("☔ Precipitation"),
              ),
              PopupMenuItem(
                value: WeatherLayer.clouds,
                child: Text("☁ Cloud Map"),
              ),
            ],
          ),
        ],
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(mapProvider.lat, mapProvider.lon),
          initialZoom: 8,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            userAgentPackageName: 'com.example.weatherapp',
          ),

          TileLayer(
            key: ValueKey(mapProvider.currentLayer),
            urlTemplate:
                "https://tile.openweathermap.org/map/${mapProvider.layerName}/{z}/{x}/{y}.png?appid=${widget.apiKey}",
            userAgentPackageName: 'com.example.weatherapp',
          ),
        ],
      ),
    );
  }

  String _getTitle(WeatherLayer layer) {
    switch (layer) {
      case WeatherLayer.temperature:
        return "Temperature Map";
      case WeatherLayer.wind:
        return "Wind Map";
      case WeatherLayer.precipitation:
        return "Precipitation Map";
      case WeatherLayer.clouds:
        return "Cloud Map";
    }
  }
}
