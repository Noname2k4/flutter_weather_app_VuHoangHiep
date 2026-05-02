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
  String timeFormat = '24h';
  String themeMode = 'light';

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    themeMode = prefs.getString('themeMode') ?? 'light';

    setState(() {
      temperatureUnit = prefs.getString('temperatureUnit') ?? 'C';
      timeFormat = prefs.getString('timeFormat') ?? '24h';
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
      timeFmt: timeFormat,
      theme: themeMode,
    );

    await _loadSettings();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Đã lưu & áp dụng cài đặt'),
        backgroundColor: Theme.of(context).colorScheme.surface,
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
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black54
                : Colors.black.withOpacity(0.04),
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
                style: TextStyle(
                  color: Theme.of(context).textTheme.titleLarge?.color,
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
                              : Theme.of(context).textTheme.bodyMedium?.color,
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
                                : Theme.of(context).dividerColor,
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        iconTheme: Theme.of(context).iconTheme,
        title: Text(
          'Cài đặt',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                    title: 'Giao diện',
                    icon: Icons.dark_mode_outlined,
                    options: const [
                      {'display': 'Sáng', 'value': 'light'},
                      {'display': 'Tối', 'value': 'dark'},
                      {'display': 'Theo hệ thống', 'value': 'system'},
                    ],
                    groupValue: themeMode,
                    onChanged: (v) => setState(() => themeMode = v),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: isLoading ? null : _saveSettings,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
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
  String timeFormat = '24h';
  ThemeMode themeMode = ThemeMode.light;

  bool isLoaded = false;

  /// Loads settings from SharedPreferences
  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final theme = prefs.getString('themeMode') ?? 'light';

    temperatureUnit = prefs.getString('temperatureUnit') ?? 'C';
    timeFormat = prefs.getString('timeFormat') ?? '24h';

    if (theme == 'dark') {
      themeMode = ThemeMode.dark;
    } else if (theme == 'system') {
      themeMode = ThemeMode.system;
    } else {
      themeMode = ThemeMode.light;
    }

    isLoaded = true;
    notifyListeners();
  }

  /// Updates settings and saves to SharedPreferences
  Future<void> updateSettings({
    required String tempUnit,
    required String timeFmt,
    required String theme,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('temperatureUnit', tempUnit);
    await prefs.setString('timeFormat', timeFmt);
    await prefs.setString('themeMode', theme);

    temperatureUnit = tempUnit;
    timeFormat = timeFmt;
    if (theme == 'dark') {
      themeMode = ThemeMode.dark;
    } else if (theme == 'system') {
      themeMode = ThemeMode.system;
    } else {
      themeMode = ThemeMode.light;
    }

    notifyListeners();
  }
}
