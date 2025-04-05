import 'package:flutter/material.dart';

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
    primary: Colors.white,
    onPrimary: Colors.white,
    secondary: Color(0xFF1F2636), // Slightly lighter shade for contrast
    onSecondary: Colors.white,
    surface: Color(0xFF1F2636), // Dark background
    onSurface: Colors.white,
    error: Colors.red,
    onError: Colors.white,
    outline: Colors.grey,
    scrim: Color(0xFF1F2636),
  ),
  scaffoldBackgroundColor: const Color(0xFF1F2636), // Dark background
  useMaterial3: true,
);
