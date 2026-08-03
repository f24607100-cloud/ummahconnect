import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/hive_service.dart';

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final HiveService _hiveService = HiveService();
  static const String _themeKey = 'app_theme_mode';

  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadTheme();
  }

  void _loadTheme() {
    final modeString = _hiveService.getValue<String>(HiveService.settingsBox, _themeKey, defaultValue: 'system');
    switch (modeString) {
      case 'light':
        state = ThemeMode.light;
        break;
      case 'dark':
        state = ThemeMode.dark;
        break;
      default:
        state = ThemeMode.system;
    }
  }

  Future<void> toggleTheme(bool isDarkMode) async {
    final mode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    state = mode;
    await _hiveService.setValue<String>(
      HiveService.settingsBox,
      _themeKey,
      isDarkMode ? 'dark' : 'light',
    );
  }
  
  bool get isDarkMode => state == ThemeMode.dark;
}

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});
