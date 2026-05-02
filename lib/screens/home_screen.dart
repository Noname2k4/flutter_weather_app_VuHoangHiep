import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/screens/forecast_screen.dart';
import '../providers/location_provider.dart';
import '../providers/weather_provider.dart';
import '../providers/map_provider.dart';
import '../widgets/hourly_forecast_list.dart';
import '../widgets/daily_forecast_card.dart';
import '../screens/search_screen.dart';
import '../screens/manuailocation_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/forecast_screen.dart';
import '../config/api_config.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    final locationProvider = context.read<LocationProvider>();
    final weatherProvider = context.read<WeatherProvider>();
    final searchProvider = context.read<SearchProvider>();

    await searchProvider.loadData();
    await locationProvider.fetchLocation();

    final location = locationProvider.currentLocation;
    if (location != null) {
      await Future.wait([
        weatherProvider.fetchWeather(location.latitude, location.longitude),
        weatherProvider.fetchForecast(location.latitude, location.longitude),
      ]);
    }
  }

  Future<void> _refreshWeather() async {
    final locationProvider = context.read<LocationProvider>();
    final weatherProvider = context.read<WeatherProvider>();
    final location = locationProvider.currentLocation;

    if (location != null) {
      await Future.wait([
        weatherProvider.fetchWeather(location.latitude, location.longitude),
        weatherProvider.fetchForecast(location.latitude, location.longitude),
      ]);
    }
  }

  String formatTime(BuildContext context, DateTime time) {
    final settings = context.read<SettingsProvider>();
    if (settings.timeFormat == '12h') {
      return DateFormat('hh:mm a').format(time);
    }
    return DateFormat('HH:mm').format(time);
  }

  String formatDate(DateTime dt) => DateFormat('EEE, dd/MM/yyyy').format(dt);

  @override
  Widget build(BuildContext context) {
    final weatherProvider = context.watch<WeatherProvider>();
    final settings = context.watch<SettingsProvider>();
    final searchProvider = context.watch<SearchProvider>();
    final locationProvider = context.watch<LocationProvider>();

    final List<String> swipeCities = [
      "__current_location__",
      ...searchProvider.favoriteCities,
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        title: const Text(
          'Thời tiết',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.list, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ManualLocationScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.map, color: Colors.black),
            onPressed: () {
              final weather = context.read<WeatherProvider>().weather;
              if (weather == null) return;

              context.read<MapProvider>().setLocation(
                weather.latitude,
                weather.longitude,
              );

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ForecastScreen(apiKey: ApiConfig.apiKey),
                ),
              );
            },
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: swipeCities.length,
        onPageChanged: (index) async {
          final weatherProvider = context.read<WeatherProvider>();
          final location = locationProvider.currentLocation;

          if (swipeCities[index] == "__current_location__") {
            if (location != null) {
              await weatherProvider.fetchWeather(
                location.latitude,
                location.longitude,
              );
              await weatherProvider.fetchForecast(
                location.latitude,
                location.longitude,
              );
            }
          } else {
            await weatherProvider.fetchWeatherByCity(swipeCities[index]);
            await weatherProvider.fetchForecastByCity(swipeCities[index]);
          }
        },
        itemBuilder: (_, index) {
          if (weatherProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (weatherProvider.error != null) {
            return Center(child: Text('Lỗi: ${weatherProvider.error}'));
          }
          if (weatherProvider.weather != null) {
            return _buildWeatherContent(context);
          }
          return const Center(child: Text('Không có dữ liệu thời tiết'));
        },
      ),
    );
  }

  Widget _buildWeatherContent(BuildContext context) {
    final weatherProvider = context.read<WeatherProvider>();
    final settings = context.read<SettingsProvider>();

    return RefreshIndicator(
      onRefresh: _refreshWeather,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              weatherProvider.weather!.cityName,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Ngày giờ: ${formatDate(weatherProvider.weather!.dateTime)} ${formatTime(context, weatherProvider.weather!.dateTime)}',
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                gradient: LinearGradient(
                  colors: weatherProvider.weather!.isDay
                      ? [
                          Colors.blue.shade400,
                          Colors.lightBlue.shade300,
                          Colors.blue.shade100,
                          Colors.cyan.shade100,
                        ]
                      : [
                          Colors.blue.shade900,
                          Colors.indigo.shade700,
                          Colors.lightBlue.shade800,
                          Colors.cyan.shade600,
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Image.network(
                    'https://openweathermap.org/img/wn/${weatherProvider.weather!.icon}@4x.png',
                    width: 120,
                    height: 120,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${_formatTemperature(weatherProvider.weather!.temperature, settings.temperatureUnit)}°${settings.temperatureUnit}',
                    style: const TextStyle(
                      fontSize: 52,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    weatherProvider.weather!.description,
                    style: const TextStyle(fontSize: 18, color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final double itemWidth = (constraints.maxWidth - 30) / 2;
                      return Wrap(
                        spacing: 30,
                        runSpacing: 16,
                        children: [
                          _buildInfoItem(
                            'Cảm giác như',
                            '${_formatTemperature(weatherProvider.weather!.feelsLike, settings.temperatureUnit)}°${settings.temperatureUnit}',
                            itemWidth,
                          ),
                          _buildInfoItem(
                            'Độ ẩm',
                            '${weatherProvider.weather!.humidity}%',
                            itemWidth,
                          ),
                          _buildInfoItem(
                            'Gió',
                            '${_formatWind(weatherProvider.weather!.windSpeed, settings.windSpeedUnit)} ${settings.windSpeedUnit}\nHướng: ${weatherProvider.weather!.windDeg}°',
                            itemWidth,
                          ),
                          _buildInfoItem(
                            'Áp suất',
                            '${weatherProvider.weather!.pressure} hPa',
                            itemWidth,
                          ),
                          _buildInfoItem(
                            'Tầm nhìn',
                            '${weatherProvider.weather!.visibility} m',
                            itemWidth,
                          ),
                          _buildInfoItem(
                            'Mặt trời mọc',
                            formatTime(
                              context,
                              weatherProvider.weather!.sunrise,
                            ),
                            itemWidth,
                          ),
                          _buildInfoItem(
                            'Mặt trời lặn',
                            formatTime(
                              context,
                              weatherProvider.weather!.sunset,
                            ),
                            itemWidth,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Dự báo theo giờ',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(8),
              child: HourlyForecastList(items: weatherProvider.hourlyForecast),
            ),
            const SizedBox(height: 24),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Dự báo 5 ngày',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Column(
              children: weatherProvider.dailyForecast
                  .map(
                    (e) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: DailyForecastCard(item: e),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String title, String value, double width) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTemperature(double temp, String unit) {
    if (unit == 'F') temp = (temp * 9 / 5) + 32;
    return temp.toStringAsFixed(1);
  }

  String _formatWind(double wind, String unit) {
    if (unit == 'km/h') wind *= 3.6;
    if (unit == 'mph') wind *= 2.23694;
    return wind.toStringAsFixed(1);
  }
}
