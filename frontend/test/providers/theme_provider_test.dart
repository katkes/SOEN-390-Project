import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soen_390/providers/theme_provider.dart';
import 'package:soen_390/styles/theme.dart';

// Test group for ThemeNotifier
void main() {
  late ThemeNotifier themeNotifier;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    themeNotifier = ThemeNotifier();
  });

  group('ThemeNotifier initialization', () {
    test('should initialize with appTheme by default', () async {
      // Set up mock shared preferences with no saved values
      SharedPreferences.setMockInitialValues({});

      // Create the notifier
      final notifier = ThemeNotifier();

      // Wait for _loadTheme to complete
      await Future.delayed(const Duration(milliseconds: 100));

      // Verify initial state is appTheme (light theme)
      expect(notifier.state, appTheme);
    });

    test('should initialize with darkAppTheme when isDarkMode is true in preferences', () async {
      // Set up mock shared preferences with dark mode enabled
      SharedPreferences.setMockInitialValues({'isDarkMode': true});

      // Create the notifier
      final notifier = ThemeNotifier();

      // Wait for _loadTheme to complete
      await Future.delayed(const Duration(milliseconds: 100));

      // Verify initial state is darkAppTheme
      expect(notifier.state, darkAppTheme);
    });
  });

  group('toggleTheme method', () {
    test('should toggle from light to dark theme', () async {
      // Set up mock shared preferences
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      // Create the notifier with initial light theme
      final notifier = ThemeNotifier();
      await Future.delayed(const Duration(milliseconds: 100)); // Wait for _loadTheme

      // Verify starting state is light theme
      expect(notifier.state, appTheme);

      // Toggle the theme
      await notifier.toggleTheme();

      // Verify state changed to dark theme
      expect(notifier.state, darkAppTheme);

      // Verify preference was saved
      expect(prefs.getBool('isDarkMode'), true);
    });

    test('should toggle from dark to light theme', () async {
      // Set up mock shared preferences with dark mode enabled
      SharedPreferences.setMockInitialValues({'isDarkMode': true});
      final prefs = await SharedPreferences.getInstance();

      // Create the notifier with initial dark theme
      final notifier = ThemeNotifier();
      await Future.delayed(const Duration(milliseconds: 100)); // Wait for _loadTheme

      // Verify starting state is dark theme
      expect(notifier.state, darkAppTheme);

      // Toggle the theme
      await notifier.toggleTheme();

      // Verify state changed to light theme
      expect(notifier.state, appTheme);

      // Verify preference was saved
      expect(prefs.getBool('isDarkMode'), false);
    });
  });

  group('_loadTheme method', () {
    test('should load light theme when no preference is set', () async {
      // Set up mock shared preferences with no values
      SharedPreferences.setMockInitialValues({});

      // Create notifier (which will call _loadTheme internally)
      final notifier = ThemeNotifier();

      // Wait for _loadTheme to complete
      await Future.delayed(const Duration(milliseconds: 100));

      // Verify state is light theme
      expect(notifier.state, appTheme);
    });

    test('should load light theme when isDarkMode is explicitly false', () async {
      // Set up mock shared preferences with dark mode disabled
      SharedPreferences.setMockInitialValues({'isDarkMode': false});

      // Create notifier (which will call _loadTheme internally)
      final notifier = ThemeNotifier();

      // Wait for _loadTheme to complete
      await Future.delayed(const Duration(milliseconds: 100));

      // Verify state is light theme
      expect(notifier.state, appTheme);
    });

    test('should load dark theme when isDarkMode is true', () async {
      // Set up mock shared preferences with dark mode enabled
      SharedPreferences.setMockInitialValues({'isDarkMode': true});

      // Create notifier (which will call _loadTheme internally)
      final notifier = ThemeNotifier();

      // Wait for _loadTheme to complete
      await Future.delayed(const Duration(milliseconds: 100));

      // Verify state is dark theme
      expect(notifier.state, darkAppTheme);
    });
  });

  group('themeProvider', () {
    test('should create and provide a ThemeNotifier instance', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Access the provider
      final themeDataFromProvider = container.read(themeProvider);

      // Verify it returns a ThemeData instance
      expect(themeDataFromProvider, isA<ThemeData>());

      // Verify we can access the notifier
      final notifier = container.read(themeProvider.notifier);
      expect(notifier, isA<ThemeNotifier>());
    });
  });

  group('ThemeNotifier integration', () {
    test('should properly retain state after multiple toggles', () async {
      // Set up mock shared preferences
      SharedPreferences.setMockInitialValues({});

      // Create the notifier
      final notifier = ThemeNotifier();
      await Future.delayed(const Duration(milliseconds: 100)); // Wait for _loadTheme

      // Initial state should be light
      expect(notifier.state, appTheme);

      // First toggle - should switch to dark
      await notifier.toggleTheme();
      expect(notifier.state, darkAppTheme);

      // Second toggle - should switch back to light
      await notifier.toggleTheme();
      expect(notifier.state, appTheme);

      // Third toggle - should switch to dark again
      await notifier.toggleTheme();
      expect(notifier.state, darkAppTheme);
    });

    test('should save preference after toggling theme', () async {
      // Set up mock shared preferences
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      // Create the notifier
      final notifier = ThemeNotifier();
      await Future.delayed(const Duration(milliseconds: 100)); // Wait for _loadTheme

      // Toggle to dark
      await notifier.toggleTheme();

      // Verify preference was saved
      expect(prefs.getBool('isDarkMode'), true);

      // Toggle back to light
      await notifier.toggleTheme();

      // Verify preference was updated
      expect(prefs.getBool('isDarkMode'), false);
    });
  });
}