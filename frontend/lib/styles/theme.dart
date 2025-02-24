import 'package:flutter/material.dart';

final ThemeData appTheme = ThemeData(
  primaryColor: Color(0xFF912338),
  colorScheme: ColorScheme(
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
