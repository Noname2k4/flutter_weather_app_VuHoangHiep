import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String temperatureUnit = 'C';
  String windSpeedUnit = 'm/s';
  String timeFormat = '24h';
  String language = 'Tiếng Việt';

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      temperatureUnit = prefs.getString('temperatureUnit') ?? 'C';
      windSpeedUnit = prefs.getString('windSpeedUnit') ?? 'm/s';
      timeFormat = prefs.getString('timeFormat') ?? '24h';
      language = prefs.getString('language') ?? 'Tiếng Việt';
      isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    final settingsProvider = context.read<SettingsProvider>();

    setState(() {
      isLoading = true;
    });

    await settingsProvider.updateSettings(
      tempUnit: temperatureUnit,
      windUnit: windSpeedUnit,
      timeFmt: timeFormat,
      lang: language,
    );

    await _loadSettings();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Đã lưu & áp dụng cài đặt'),
        backgroundColor: const Color.fromARGB(255, 54, 54, 54),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildModernSettingCard({
    required String title,
    required IconData icon,
    required List<Map<String, String>> options,
    required String groupValue,
    required Function(String) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.blueAccent, size: 24),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            children: options.map((option) {
              final value = option['value']!;
              final display = option['display']!;
              final isSelected = value == groupValue;

              return InkWell(
                onTap: () => onChanged(value),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        display,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: isSelected
                              ? Colors.blueAccent
                              : Colors.black87,
                        ),
                      ),
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? Colors.blueAccent
                                : Colors.grey.shade400,
                            width: 2,
                          ),
                          color: isSelected
                              ? Colors.blueAccent
                              : Colors.transparent,
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.done,
                                size: 12,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'Cài đặt',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: ListView(
                children: [
                  _buildModernSettingCard(
                    title: 'Đơn vị nhiệt độ',
                    icon: Icons.thermostat_outlined,
                    options: const [
                      {'display': 'Celsius (°C)', 'value': 'C'},
                      {'display': 'Fahrenheit (°F)', 'value': 'F'},
                    ],
                    groupValue: temperatureUnit,
                    onChanged: (v) => setState(() => temperatureUnit = v),
                  ),
                  _buildModernSettingCard(
                    title: 'Đơn vị tốc độ gió',
                    icon: Icons.air_outlined,
                    options: const [
                      {'display': 'Mét/giây (m/s)', 'value': 'm/s'},
                      {'display': 'Kilômét/giờ (km/h)', 'value': 'km/h'},
                      {'display': 'Dặm/giờ (mph)', 'value': 'mph'},
                    ],
                    groupValue: windSpeedUnit,
                    onChanged: (v) => setState(() => windSpeedUnit = v),
                  ),
                  _buildModernSettingCard(
                    title: 'Định dạng thời gian',
                    icon: Icons.access_time_outlined,
                    options: const [
                      {'display': '24 giờ (HH:mm)', 'value': '24h'},
                      {'display': '12 giờ (hh:mm a)', 'value': '12h'},
                    ],
                    groupValue: timeFormat,
                    onChanged: (v) => setState(() => timeFormat = v),
                  ),
                  _buildModernSettingCard(
                    title: 'Ngôn ngữ',
                    icon: Icons.language_outlined,
                    options: const [
                      {'display': 'Tiếng Việt', 'value': 'Tiếng Việt'},
                      {'display': 'English', 'value': 'English'},
                    ],
                    groupValue: language,
                    onChanged: (v) => setState(() => language = v),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: isLoading ? null : _saveSettings,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 5,
                    ),
                    child: Text(
                      isLoading ? 'Đang tải...' : 'LƯU CÀI ĐẶT',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}

class SettingsProvider extends ChangeNotifier {
  String temperatureUnit = 'C';
  String windSpeedUnit = 'm/s';
  String timeFormat = '24h';
  String language = 'Tiếng Việt';

  bool isLoaded = false;

  /// Loads settings from SharedPreferences
  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    temperatureUnit = prefs.getString('temperatureUnit') ?? 'C';
    windSpeedUnit = prefs.getString('windSpeedUnit') ?? 'm/s';
    timeFormat = prefs.getString('timeFormat') ?? '24h';
    language = prefs.getString('language') ?? 'Tiếng Việt';

    isLoaded = true;
    notifyListeners();
  }

  /// Updates settings and saves to SharedPreferences
  Future<void> updateSettings({
    required String tempUnit,
    required String windUnit,
    required String timeFmt,
    required String lang,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('temperatureUnit', tempUnit);
    await prefs.setString('windSpeedUnit', windUnit);
    await prefs.setString('timeFormat', timeFmt);
    await prefs.setString('language', lang);

    temperatureUnit = tempUnit;
    windSpeedUnit = windUnit;
    timeFormat = timeFmt;
    language = lang;

    notifyListeners();
  }
}
