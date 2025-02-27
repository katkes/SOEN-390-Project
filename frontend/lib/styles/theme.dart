import 'package:flutter/material.dart';

final ThemeData appTheme = ThemeData(
  primaryColor: const Color(0xFF912338),
  colorScheme: const ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF912338),
    onPrimary: Colors.white,
    secondary: Color(0xFF912338),
    onSecondary: Colors.white,
    surface: Colors.white, // Use surface instead of background
    onSurface: Colors.black, // Text/icon color on surface
    error: Colors.red,
    onError: Colors.white,
    outline: Colors.grey,
    scrim: Colors.black, // Optional: Used for overlays like dialogs
  ),
  scaffoldBackgroundColor: Colors.white, // Explicitly set background for pages
  useMaterial3: true,
);
