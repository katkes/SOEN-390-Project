import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:soen_390/styles/theme.dart';
import 'package:soen_390/providers/theme_provider.dart';
import 'package:soen_390/widgets/dark_mode_toggle_button.dart'; // Assuming this is where the widget is located

// Create a mock for the ThemeNotifier
class MockThemeNotifier extends Mock implements StateNotifier<ThemeData> {
  @override
  ThemeData get state => _isDark ? darkAppTheme : appTheme;

  bool _isDark = false;

  @override
  void toggleTheme() {
    _isDark = !_isDark;
  }
}

void main() {
  late MockThemeNotifier mockThemeNotifier;
  late StateNotifierProvider<StateNotifier<ThemeData>, ThemeData>
      mockThemeProvider;

  setUp(() {
    mockThemeNotifier = MockThemeNotifier();
    mockThemeProvider =
        StateNotifierProvider<StateNotifier<ThemeData>, ThemeData>((ref) {
      return mockThemeNotifier;
    });
  });

  testWidgets('DarkModeToggleButton shows correct text based on current theme',
      (WidgetTester tester) async {
    // Build our widget in light mode
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          themeProvider.overrideWithProvider(mockThemeProvider),
        ],
        child: const MaterialApp(
          home: DarkModeToggleButton(),
        ),
      ),
    );

    // Verify the button shows "Switch to Dark Mode" when in light mode
    expect(find.text('Switch to Dark Mode'), findsOneWidget);
    expect(find.text('Switch to Light Mode'), findsNothing);

    // Toggle to dark mode
    mockThemeNotifier.toggleTheme();
    await tester.pump();

    // Verify the button now shows "Switch to Light Mode"
    expect(find.text('Switch to Light Mode'), findsOneWidget);
    expect(find.text('Switch to Dark Mode'), findsNothing);
  });

  testWidgets('Tapping the button calls toggleTheme',
      (WidgetTester tester) async {
    // Build our widget
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          themeProvider.overrideWithProvider(mockThemeProvider),
        ],
        child: const MaterialApp(
          home: DarkModeToggleButton(),
        ),
      ),
    );

    // Store the initial theme state
    final initialIsDark = mockThemeNotifier._isDark;

    // Tap the button
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    // Verify the theme was toggled
    expect(mockThemeNotifier._isDark, !initialIsDark);

    // Tap again to toggle back
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    // Verify the theme was toggled again
    expect(mockThemeNotifier._isDark, initialIsDark);
  });

  testWidgets('Widget renders with Scaffold and ElevatedButton',
      (WidgetTester tester) async {
    // Build our widget
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          themeProvider.overrideWithProvider(mockThemeProvider),
        ],
        child: const MaterialApp(
          home: DarkModeToggleButton(),
        ),
      ),
    );

    // Verify the widget structure
    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byType(Center), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });
}
