import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/weather_provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  String? _selectedCity;

  @override
  Widget build(BuildContext context) {
    final searchProvider = context.watch<SearchProvider>();
    final weatherProvider = context.read<WeatherProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Tìm kiếm thành phố',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: TextField(
                controller: _controller,
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  hintText: 'Nhập tên thành phố',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 18,
                  ),
                  suffixIcon: Container(
                    margin: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.search, color: Colors.blueAccent),
                      onPressed: () async {
                        final city = _controller.text.trim();
                        if (city.isNotEmpty) {
                          _selectedCity = city;
                          searchProvider.addRecentSearch(city);
                          await weatherProvider.fetchWeatherByCity(city);
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (searchProvider.recentSearches.isNotEmpty)
                      _buildSection(
                        title: 'Tìm kiếm gần đây',
                        items: searchProvider.recentSearches,
                        onTap: (c) async {
                          _selectedCity = c;
                          await weatherProvider.fetchWeatherByCity(c);
                          Navigator.pop(context);
                        },
                        searchProvider: searchProvider,
                      ),
                    const SizedBox(height: 30),

                    if (searchProvider.favoriteCities.isNotEmpty)
                      _buildSection(
                        title: 'Thành phố yêu thích',
                        items: searchProvider.favoriteCities,
                        onTap: (c) async {
                          _selectedCity = c;
                          await weatherProvider.fetchWeatherByCity(c);
                          Navigator.pop(context);
                        },
                        searchProvider: searchProvider,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<String> items,
    required Function(String) onTap,
    required SearchProvider searchProvider,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 12.0),
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black87,
            ),
          ),
        ),
        Column(
          children: items.map((c) {
            final isFavorite = searchProvider.favoriteCities.contains(c);
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                leading: Icon(
                  Icons.location_on_outlined,
                  color: Colors.blueAccent.shade100,
                ),
                title: Text(
                  c,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                trailing: IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.redAccent : Colors.grey.shade400,
                  ),
                  onPressed: () {
                    if (isFavorite) {
                      searchProvider.removeFavoriteCity(c);
                    } else {
                      searchProvider.addFavoriteCity(c);
                    }
                  },
                ),
                onTap: () => onTap(c),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class SearchProvider extends ChangeNotifier {
  List<String> _recentSearches = [];
  List<String> _favoriteCities = [];

  List<String> get recentSearches => _recentSearches;
  List<String> get favoriteCities => _favoriteCities;

  /// Constructor for SearchProvider, loads saved data
  SearchProvider() {
    loadData();
  }

  /// Loads recent searches and favorite cities from SharedPreferences
  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _recentSearches = prefs.getStringList('recent_searches') ?? [];
    _favoriteCities = prefs.getStringList('favorite_cities') ?? [];
    notifyListeners();
  }

  /// Adds a city to recent searches
  Future<void> addRecentSearch(String city) async {
    _recentSearches.remove(city);
    _recentSearches.insert(0, city);
    if (_recentSearches.length > 10)
      _recentSearches = _recentSearches.take(10).toList();
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('recent_searches', _recentSearches);
    notifyListeners();
  }

  /// Adds a city to favorite cities
  Future<void> addFavoriteCity(String city) async {
    if (!_favoriteCities.contains(city)) {
      if (_favoriteCities.length >= 5) {
        _favoriteCities.removeAt(0);
      }
      _favoriteCities.add(city);
      final prefs = await SharedPreferences.getInstance();
      prefs.setStringList('favorite_cities', _favoriteCities);
      notifyListeners();
    }
  }

  /// Removes a city from favorite cities
  Future<void> removeFavoriteCity(String city) async {
    _favoriteCities.remove(city);
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('favorite_cities', _favoriteCities);
    notifyListeners();
  }
}
