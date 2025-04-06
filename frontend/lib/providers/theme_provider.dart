/// This file provides the functionality (with shared preferences flutter package) to provide
/// a theme toggle functionality. This is done by the "isDarkMode" variable via sharedPreference package

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soen_390/styles/theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeNotifier extends StateNotifier<ThemeData> {
  ThemeNotifier() : super(appTheme) {
    _loadTheme();
  }

  Future<void> toggleTheme() async {
    state = (state == appTheme) ? darkAppTheme : appTheme;

    // Save the theme preference
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', state == darkAppTheme);
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkMode') ?? false;
    state = isDark ? darkAppTheme : appTheme;
  }
}

// Create a Riverpod provider for the theme mode
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeData>((ref) {
  return ThemeNotifier();
});
