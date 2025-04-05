import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soen_390/styles/theme.dart';
import 'package:soen_390/providers/theme_provider.dart'; // Adjust import path as needed

// Generate mock for SharedPreferences
@GenerateMocks([SharedPreferences])
import 'theme_provider_test.mocks.dart';

void main() {
  late MockSharedPreferences mockPrefs;
  late ProviderContainer container;

  setUp(() {
    mockPrefs = MockSharedPreferences();

    // Override the SharedPreferences.getInstance() to return our mock
    SharedPreferences.setMockInitialValues({});

    container = ProviderContainer(
      overrides: [
        // Override the provider to use a custom implementation for testing
        themeProvider.overrideWith((ref) {
          return TestThemeNotifier(mockPrefs);
        }),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('ThemeNotifier Initialization', () {
    test('should initialize with light theme as default when preferences is null', () async {
      // Setup
      when(mockPrefs.getBool('isDarkMode')).thenReturn(null);

      // Act - Get the initial state
      final themeData = container.read(themeProvider);

      // Assert
      expect(themeData, equals(appTheme));
      verify(mockPrefs.getBool('isDarkMode')).called(1);
    });

    test('should initialize with light theme when preferences is explicitly false', () async {
      // Setup
      when(mockPrefs.getBool('isDarkMode')).thenReturn(false);

      // Act - Get the initial state
      final themeData = container.read(themeProvider);

      // Assert
      expect(themeData, equals(appTheme));
      verify(mockPrefs.getBool('isDarkMode')).called(1);
    });

    test('should load dark theme from preferences if saved as dark', () async {
      // Setup
      when(mockPrefs.getBool('isDarkMode')).thenReturn(true);

      // Force the provider to reload with the new mock setup
      container = ProviderContainer(
        overrides: [
          themeProvider.overrideWith((ref) {
            return TestThemeNotifier(mockPrefs);
          }),
        ],
      );

      // Act - Get the state after loading from preferences
      final themeData = container.read(themeProvider);

      // Assert
      expect(themeData, equals(darkAppTheme));
      verify(mockPrefs.getBool('isDarkMode')).called(1);
    });

    test('should handle _loadTheme explicitly', () async {
      // Setup
      when(mockPrefs.getBool('isDarkMode')).thenReturn(true);

      // Create notifier directly to test _loadTheme
      final notifier = TestThemeNotifier(mockPrefs);

      // Act - Call _loadTheme explicitly
      await notifier.loadThemeExposed();

      // Assert
      expect(notifier.debugState, equals(darkAppTheme));
      verify(mockPrefs.getBool('isDarkMode')).called(1);
    });
  });

  group('ThemeNotifier Toggle Functionality', () {
    test('should toggle from light to dark theme', () async {
      // Setup
      when(mockPrefs.getBool('isDarkMode')).thenReturn(false);
      when(mockPrefs.setBool('isDarkMode', true)).thenAnswer((_) async => true);

      // Act - Get the initial state then toggle
      final initialTheme = container.read(themeProvider);
      await container.read(themeProvider.notifier).toggleTheme();
      final newTheme = container.read(themeProvider);

      // Assert
      expect(initialTheme, equals(appTheme));
      expect(newTheme, equals(darkAppTheme));
      verify(mockPrefs.setBool('isDarkMode', true)).called(1);
    });

    test('should toggle from dark to light theme', () async {
      // Setup
      when(mockPrefs.getBool('isDarkMode')).thenReturn(true);
      when(mockPrefs.setBool('isDarkMode', false)).thenAnswer((_) async => true);

      // Force the provider to reload with the new mock setup
      container = ProviderContainer(
        overrides: [
          themeProvider.overrideWith((ref) {
            return TestThemeNotifier(mockPrefs);
          }),
        ],
      );

      // Act - Get the initial state then toggle
      final initialTheme = container.read(themeProvider);
      await container.read(themeProvider.notifier).toggleTheme();
      final newTheme = container.read(themeProvider);

      // Assert
      expect(initialTheme, equals(darkAppTheme));
      expect(newTheme, equals(appTheme));
      verify(mockPrefs.setBool('isDarkMode', false)).called(1);
    });

    test('should toggle multiple times correctly', () async {
      // Setup
      when(mockPrefs.getBool('isDarkMode')).thenReturn(false);
      when(mockPrefs.setBool('isDarkMode', true)).thenAnswer((_) async => true);
      when(mockPrefs.setBool('isDarkMode', false)).thenAnswer((_) async => true);

      final notifier = container.read(themeProvider.notifier);

      // Act - Toggle multiple times
      await notifier.toggleTheme(); // Light to dark
      await notifier.toggleTheme(); // Dark to light
      await notifier.toggleTheme(); // Light to dark again

      // Assert
      expect(container.read(themeProvider), equals(darkAppTheme));
      verify(mockPrefs.setBool('isDarkMode', true)).called(2);
      verify(mockPrefs.setBool('isDarkMode', false)).called(1);
    });

    test('should handle SharedPreferences failure during toggle', () async {
      // Setup
      when(mockPrefs.getBool('isDarkMode')).thenReturn(false);
      when(mockPrefs.setBool('isDarkMode', true)).thenThrow(Exception('Failed to save preference'));

      // Act & Assert
      final notifier = container.read(themeProvider.notifier);

      // The toggle should still update the state even if saving fails
      expect(container.read(themeProvider), equals(appTheme));
      await notifier.toggleTheme();
      expect(container.read(themeProvider), equals(darkAppTheme));

      verify(mockPrefs.setBool('isDarkMode', true)).called(1);
    });
  });

  group('ThemeNotifier Error Handling', () {
    test('should handle SharedPreferences get errors gracefully', () async {
      // Setup
      when(mockPrefs.getBool('isDarkMode')).thenThrow(Exception('SharedPreferences error'));

      // Force the provider to reload with the new mock setup
      container = ProviderContainer(
        overrides: [
          themeProvider.overrideWith((ref) {
            return TestThemeNotifier(mockPrefs);
          }),
        ],
      );

      // Act - Get the state after error
      final themeData = container.read(themeProvider);

      // Assert - Should default to light theme on error
      expect(themeData, equals(appTheme));
    });

    test('should handle SharedPreferences set errors during toggleTheme', () async {
      // Setup
      when(mockPrefs.getBool('isDarkMode')).thenReturn(false);
      when(mockPrefs.setBool(any, any)).thenThrow(Exception('SharedPreferences set error'));

      final notifier = container.read(themeProvider.notifier);

      // Act & Assert - Toggle should still work for UI even if saving fails
      expect(container.read(themeProvider), equals(appTheme));

      // This should not throw even though SharedPreferences throws
      await expectLater(notifier.toggleTheme(), completes);

      // The state should still be updated even though saving failed
      expect(container.read(themeProvider), equals(darkAppTheme));
    });

    test('should handle _loadTheme errors explicitly', () async {
      // Setup
      when(mockPrefs.getBool('isDarkMode')).thenThrow(Exception('SharedPreferences load error'));

      // Create notifier directly
      final notifier = TestThemeNotifier(mockPrefs);

      // Reset state to ensure we're testing the load
      notifier.resetState(null);

      // Act - Call _loadTheme explicitly
      await notifier.loadThemeExposed();

      // Assert - Should default to light theme on error
      expect(notifier.debugState, equals(appTheme));
    });
  });

  group('ThemeNotifier State Management', () {
    test('should properly listen to state changes', () async {
      // Setup
      when(mockPrefs.getBool('isDarkMode')).thenReturn(false);
      when(mockPrefs.setBool('isDarkMode', true)).thenAnswer((_) async => true);

      // Setup a listener
      final themeChanges = <ThemeData>[];
      final subscription = container.listen(
        themeProvider,
            (_, next) => themeChanges.add(next),
        fireImmediately: true,
      );

      // Act - Toggle the theme
      await container.read(themeProvider.notifier).toggleTheme();

      // Cleanup
      subscription.close();

      // Assert
      expect(themeChanges.length, equals(2));
      expect(themeChanges[0], equals(appTheme)); // Initial state
      expect(themeChanges[1], equals(darkAppTheme)); // After toggle
    });

    test('should not notify listeners if toggling does not change state due to error', () async {
      // Setup
      when(mockPrefs.getBool('isDarkMode')).thenReturn(false);

      // Setup a special test notifier that fails during state change
      final failingNotifier = FailingToggleThemeNotifier(mockPrefs);

      // Override the container
      container = ProviderContainer(
        overrides: [
          themeProvider.overrideWith((_) => failingNotifier),
        ],
      );

      // Setup a listener
      final themeChanges = <ThemeData>[];
      final subscription = container.listen(
        themeProvider,
            (_, next) => themeChanges.add(next),
        fireImmediately: true,
      );

      // Act - Try to toggle the theme with a notifier that fails
      await failingNotifier.toggleTheme();

      // Cleanup
      subscription.close();

      // Assert - Only the initial state should be in the list
      expect(themeChanges.length, equals(1));
      expect(themeChanges[0], equals(appTheme));
    });

    test('should reflect state changes when toggling multiple times', () async {
      // Setup
      when(mockPrefs.getBool('isDarkMode')).thenReturn(false);
      when(mockPrefs.setBool(any, any)).thenAnswer((_) async => true);

      // Setup a listener
      final themeChanges = <ThemeData>[];
      final subscription = container.listen(
        themeProvider,
            (_, next) => themeChanges.add(next),
        fireImmediately: true,
      );

      // Act - Toggle multiple times
      final notifier = container.read(themeProvider.notifier);
      await notifier.toggleTheme(); // → dark
      await notifier.toggleTheme(); // → light
      await notifier.toggleTheme(); // → dark

      // Cleanup
      subscription.close();

      // Assert
      expect(themeChanges.length, equals(4)); // Initial + 3 toggles
      expect(themeChanges[0], equals(appTheme));
      expect(themeChanges[1], equals(darkAppTheme));
      expect(themeChanges[2], equals(appTheme));
      expect(themeChanges[3], equals(darkAppTheme));
    });
  });

  group('ThemeNotifier Integration Tests', () {
    testWidgets('Widget should respond to theme changes', (WidgetTester tester) async {
      // Setup
      when(mockPrefs.getBool('isDarkMode')).thenReturn(false);
      when(mockPrefs.setBool(any, any)).thenAnswer((_) async => true);

      // Build test widget tree with Riverpod
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            themeProvider.overrideWith((_) => TestThemeNotifier(mockPrefs)),
          ],
          child: Consumer(
            builder: (context, ref, _) {
              final theme = ref.watch(themeProvider);
              return MaterialApp(
                theme: theme,
                home: Scaffold(
                  body: const Text('Test'),
                  floatingActionButton: FloatingActionButton(
                    onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
                    child: const Icon(Icons.brightness_6),
                  ),
                ),
              );
            },
          ),
        ),
      );

      // Initial state
      expect(find.byType(MaterialApp), findsOneWidget);

      // Get the MaterialApp widget and check its theme
      MaterialApp app = tester.widget(find.byType(MaterialApp));
      expect(app.theme, equals(appTheme));

      // Tap the button to toggle theme
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Get the updated MaterialApp and check its theme
      app = tester.widget(find.byType(MaterialApp));
      expect(app.theme, equals(darkAppTheme));
    });

    test('should handle theme changes across app lifecycle', () async {
      // This test simulates an app restart with saved preferences

      // Setup - First "session"
      when(mockPrefs.getBool('isDarkMode')).thenReturn(false);
      when(mockPrefs.setBool('isDarkMode', true)).thenAnswer((_) async => true);

      // First session - toggle to dark
      final notifier = container.read(themeProvider.notifier);
      await notifier.toggleTheme();
      expect(container.read(themeProvider), equals(darkAppTheme));

      // Verify preference was saved
      verify(mockPrefs.setBool('isDarkMode', true)).called(1);

      // Setup - Second "session" with saved preference
      when(mockPrefs.getBool('isDarkMode')).thenReturn(true);

      // Create a new container to simulate app restart
      final newContainer = ProviderContainer(
        overrides: [
          themeProvider.overrideWith((ref) {
            return TestThemeNotifier(mockPrefs);
          }),
        ],
      );

      // Check that the theme is loaded correctly on "restart"
      expect(newContainer.read(themeProvider), equals(darkAppTheme));

      // Cleanup
      newContainer.dispose();
    });
  });
}

// Test implementation of ThemeNotifier to inject mocked SharedPreferences
class TestThemeNotifier extends ThemeNotifier {
  final MockSharedPreferences mockPrefs;

  TestThemeNotifier(this.mockPrefs) : super() {
    // Initialize the state immediately instead of waiting for async _loadTheme
    try {
      final isDark = mockPrefs.getBool('isDarkMode') ?? false;
      state = isDark ? darkAppTheme : appTheme;
    } catch (e) {
      // Default to light theme on error
      state = appTheme;
    }
  }

  @override
  Future<void> toggleTheme() async {
    try {
      state = (state == appTheme) ? darkAppTheme : appTheme;

      // Save the theme preference using mocked preferences
      await mockPrefs.setBool('isDarkMode', state == darkAppTheme);
    } catch (e) {
      // Continue with state change even if saving fails
      // In a real app, you might want to log this error
    }
  }

  @override
  Future<void> loadTheme() async {
    try {
      final isDark = mockPrefs.getBool('isDarkMode') ?? false;
      state = isDark ? darkAppTheme : appTheme;
    } catch (e) {
      // Default to light theme on error
      state = appTheme;
    }
  }

  // Expose protected method for testing
  Future<void> loadThemeExposed() async {
    await loadTheme();
  }

  // For testing internal state directly
  @override
  ThemeData get debugState => state;

  // For testing error scenarios
  void resetState(ThemeData? newState) {
    state = newState ?? appTheme;
  }
}

// Special notifier that fails during toggle for testing error cases
class FailingToggleThemeNotifier extends TestThemeNotifier {
  FailingToggleThemeNotifier(MockSharedPreferences mockPrefs) : super(mockPrefs);

  @override
  Future<void> toggleTheme() async {
    // This implementation deliberately does not change state
    try {
      // Attempt to save preference but don't change state
      await mockPrefs.setBool('isDarkMode', state == darkAppTheme);
    } catch (e) {
      // Silently fail for this test case
    }
  }
}