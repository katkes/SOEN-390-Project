import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soen_390/styles/theme.dart'; // Update this import to match your project structure

void main() {
  group('Light App Theme Tests', () {
    test('appTheme has correct primary color', () {
      expect(appTheme.primaryColor, equals(const Color(0xFF912338)));
    });

    test('appTheme uses Material 3', () {
      expect(appTheme.useMaterial3, isTrue);
    });

    test('appTheme has correct scaffold background color', () {
      expect(appTheme.scaffoldBackgroundColor, equals(Colors.white));
    });

    group('appTheme ColorScheme tests', () {
      test('has light brightness', () {
        expect(appTheme.colorScheme.brightness, equals(Brightness.light));
      });

      test('has correct primary color', () {
        expect(appTheme.colorScheme.primary, equals(const Color(0xFF912338)));
      });

      test('has correct onPrimary color', () {
        expect(appTheme.colorScheme.onPrimary, equals(Colors.white));
      });

      test('has correct secondary color', () {
        expect(appTheme.colorScheme.secondary, equals(const Color(0xFF912338)));
      });

      test('has correct onSecondary color', () {
        expect(appTheme.colorScheme.onSecondary, equals(Colors.white));
      });

      test('has correct surface color', () {
        expect(appTheme.colorScheme.surface, equals(Colors.white));
      });

      test('has correct onSurface color', () {
        expect(appTheme.colorScheme.onSurface, equals(Colors.black));
      });

      test('has correct error color', () {
        expect(appTheme.colorScheme.error, equals(Colors.red));
      });

      test('has correct onError color', () {
        expect(appTheme.colorScheme.onError, equals(Colors.white));
      });

      test('has correct outline color', () {
        expect(appTheme.colorScheme.outline, equals(Colors.grey));
      });

      test('has correct scrim color', () {
        expect(appTheme.colorScheme.scrim, equals(Colors.black));
      });
    });
  });

  group('Dark App Theme Tests', () {
    test('darkAppTheme has correct primary color', () {
      expect(darkAppTheme.primaryColor, equals(const Color(0xFF912338)));
    });

    test('darkAppTheme uses Material 3', () {
      expect(darkAppTheme.useMaterial3, isTrue);
    });

    test('darkAppTheme has correct scaffold background color', () {
      expect(darkAppTheme.scaffoldBackgroundColor,
          equals(const Color(0xFF1F2636)));
    });

    group('darkAppTheme ColorScheme tests', () {
      test('has dark brightness', () {
        expect(darkAppTheme.colorScheme.brightness, equals(Brightness.dark));
      });

      test('has correct primary color', () {
        expect(darkAppTheme.colorScheme.primary, equals(Colors.white));
      });

      test('has correct onPrimary color', () {
        expect(darkAppTheme.colorScheme.onPrimary, equals(Colors.white));
      });

      test('has correct secondary color', () {
        expect(darkAppTheme.colorScheme.secondary,
            equals(const Color(0xFF1F2636)));
      });

      test('has correct onSecondary color', () {
        expect(darkAppTheme.colorScheme.onSecondary, equals(Colors.white));
      });

      test('has correct surface color', () {
        expect(
            darkAppTheme.colorScheme.surface, equals(const Color(0xFF1F2636)));
      });

      test('has correct onSurface color', () {
        expect(darkAppTheme.colorScheme.onSurface, equals(Colors.white));
      });

      test('has correct error color', () {
        expect(darkAppTheme.colorScheme.error, equals(Colors.red));
      });

      test('has correct onError color', () {
        expect(darkAppTheme.colorScheme.onError, equals(Colors.white));
      });

      test('has correct outline color', () {
        expect(darkAppTheme.colorScheme.outline, equals(Colors.grey));
      });

      test('has correct scrim color', () {
        expect(darkAppTheme.colorScheme.scrim, equals(const Color(0xFF1F2636)));
      });
    });
  });

  test('Light and dark themes have different brightness', () {
    expect(appTheme.colorScheme.brightness,
        isNot(darkAppTheme.colorScheme.brightness));
  });

  test('Light and dark themes have different scaffold background colors', () {
    expect(appTheme.scaffoldBackgroundColor,
        isNot(darkAppTheme.scaffoldBackgroundColor));
  });
}
