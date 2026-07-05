import 'package:flutter/material.dart';
import '../services/hive_service.dart';
import '../core/constants.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = true; // Dark mode is required/default

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadTheme();
  }

  void _loadTheme() {
    final saved = HiveService.settingsBox.get(AppConstants.themeKey);
    _isDarkMode = saved ?? true; // default to dark
    notifyListeners();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    HiveService.settingsBox.put(AppConstants.themeKey, _isDarkMode);
    notifyListeners();
  }

  void setDarkMode(bool value) {
    _isDarkMode = value;
    HiveService.settingsBox.put(AppConstants.themeKey, _isDarkMode);
    notifyListeners();
  }
}
