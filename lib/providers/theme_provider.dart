import 'package:flutter/material.dart';
import '../services/hive_service.dart';

class ThemeProvider extends ChangeNotifier {
  late bool _isDarkMode;

  ThemeProvider() {
    _isDarkMode = HiveService.isDarkMode();
  }

  bool get isDarkMode => _isDarkMode;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    HiveService.setDarkMode(_isDarkMode);
    notifyListeners();
  }

  void setDarkMode(bool isDark) {
    if (_isDarkMode != isDark) {
      _isDarkMode = isDark;
      HiveService.setDarkMode(_isDarkMode);
      notifyListeners();
    }
  }
}
