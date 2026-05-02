import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/location_provider.dart';
import '../providers/weather_provider.dart';
import '../widgets/hourly_forecast_list.dart';
import '../widgets/daily_forecast_card.dart';
import '../screens/search_screen.dart';
import '../screens/manuailocation_screen.dart';
import '../screens/settings_screen.dart';

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
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final locationProvider = context.read<LocationProvider>();
    final weatherProvider = context.read<WeatherProvider>();
    final searchProvider = context.read<SearchProvider>();

    await searchProvider.loadData();
    await locationProvider.fetchLocation();

    final location = locationProvider.currentLocation;
    if (location != null) {
      await weatherProvider.fetchWeather(location.latitude, location.longitude);
      await weatherProvider.fetchForecast(
        location.latitude,
        location.longitude,
      );
    }
  }

  Future<void> _refreshWeather() async {
    final locationProvider = context.read<LocationProvider>();
    final weatherProvider = context.read<WeatherProvider>();
    final location = locationProvider.currentLocation;

    if (location != null) {
      await weatherProvider.fetchWeather(location.latitude, location.longitude);
      await weatherProvider.fetchForecast(
        location.latitude,
        location.longitude,
      );
    }
  }

  String formatTime(BuildContext context, DateTime time) {
    final settings = context.read<SettingsProvider>();
    if (settings.timeFormat == '12h') {
      return DateFormat('hh:mm a').format(time);
    }
    return DateFormat('HH:mm').format(time);
  }

  String formatDate(DateTime dt) => DateFormat('dd/MM/yyyy').format(dt);

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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 2,
        title: Text(
          'Thời tiết',
          style: TextStyle(
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Theme.of(context).iconTheme.color),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.list, color: Theme.of(context).iconTheme.color),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ManualLocationScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(
              Icons.settings,
              color: Theme.of(context).iconTheme.color,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
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
          if (weatherProvider.isLoading || !settings.isLoaded) {
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
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Ngày giờ: ${formatDate(weatherProvider.weather!.dateTime)} ${formatTime(context, weatherProvider.weather!.dateTime)}',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
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
                    style: TextStyle(
                      fontSize: 52,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).cardColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    weatherProvider.weather!.description,
                    style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.color?.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: Card(
                color: Theme.of(context).cardColor,
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
                            'Nhiệt độ',
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
                            '${weatherProvider.weather!.windSpeed.toStringAsFixed(1)} m/s\nHướng: ${weatherProvider.weather!.windDeg}°',
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
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.black54
                        : Colors.black12,
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
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
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
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.black54
                                : Colors.black12,
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
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(
                context,
              ).textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyLarge?.color,
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
}
