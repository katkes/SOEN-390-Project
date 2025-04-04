import 'package:flutter/material.dart';

class AppThemes{
  static final ThemeData lightTheme = ThemeData(
      primaryColor: const Color(0xFF912338),
      colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF912338),
      onPrimary: Colors.white,
      secondary: Color(0xFF912338),
      onSecondary: Colors.white,
      surface: Colors.white,
      onSurface: Colors.black,
      error: Colors.red,
      onError: Colors.white,
      outline: Colors.grey,
      scrim: Colors.black,
    ),
    scaffoldBackgroundColor: Colors.white,
    useMaterial3: true,
  );

  static final ThemeData darkAppTheme = ThemeData(
    primaryColor: const Color(0xFF912338),
    colorScheme: const ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF912338),
    onPrimary: Colors.white,
    secondary: Color(0xFFB33E50), // Slightly lighter shade for contrast
    onSecondary: Colors.white,
    surface: Color(0xFF0D1117), // Dark background
    onSurface: Colors.white,
    error: Colors.red,
    onError: Colors.white,
    outline: Colors.grey,
    scrim: Color(0xFF0D1117),
    ),
    scaffoldBackgroundColor: const Color(0xFF0D1117), // Dark background
    useMaterial3: true,
    );
}


final ThemeData appTheme = ThemeData(
  primaryColor: const Color(0xFF912338),
  colorScheme: const ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF912338),
    onPrimary: Colors.white,
    secondary: Color(0xFF912338),
    onSecondary: Colors.white,
    surface: Colors.white,
    onSurface: Colors.black,
    error: Colors.red,
    onError: Colors.white,
    outline: Colors.grey,
    scrim: Colors.black,
  ),
  scaffoldBackgroundColor: Colors.white,
  useMaterial3: true,
);


final ThemeData darkAppTheme = ThemeData(
  primaryColor: const Color(0xFF912338),
  colorScheme: const ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF912338),
    onPrimary: Colors.white,
    secondary: Color(0xFFB33E50), // Slightly lighter shade for contrast
    onSecondary: Colors.white,
    surface: Color(0xFF0D1117), // Dark background
    onSurface: Colors.white,
    error: Colors.red,
    onError: Colors.white,
    outline: Colors.grey,
    scrim: Color(0xFF0D1117),
  ),
  scaffoldBackgroundColor: const Color(0xFF0D1117), // Dark background
  useMaterial3: true,
);
