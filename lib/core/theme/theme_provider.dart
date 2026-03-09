import 'package:flutter/material.dart';

import 'theme_mode_storage.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  bool get isDark => _themeMode == ThemeMode.dark;

  Future<void> load() async {
    final saved = await ThemeModeStorage.read();
    if (saved != null) {
      _themeMode = saved;
      notifyListeners();
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    await ThemeModeStorage.save(mode);
  }

  Future<void> toggle() async {
    await setThemeMode(_themeMode == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark);
  }
}
