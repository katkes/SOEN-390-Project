import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soen_390/providers/theme_provider.dart';
import 'package:soen_390/styles/theme.dart';
import 'package:soen_390/widgets/dark_mode_toggle_button.dart'; // Adjust path as needed

// Create a mock ThemeNotifier class
class MockThemeNotifier extends StateNotifier<ThemeData>
    implements ThemeNotifier {
  // ignore:use_super_parameters
  MockThemeNotifier(ThemeData initialTheme) : super(initialTheme);

  bool toggleCalled = false;

  @override
  Future<void> toggleTheme() async {
    toggleCalled = true;
    state = state == appTheme ? darkAppTheme : appTheme;
  }
}

void main() {
  testWidgets('DarkModeToggleButton displays correct text in light mode',
      (WidgetTester tester) async {
    // Build our app with a mock provider
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          themeProvider.overrideWith((ref) => MockThemeNotifier(appTheme)),
        ],
        child: const MaterialApp(
          home: DarkModeToggleButton(),
        ),
      ),
    );

    // Verify light mode text is displayed
    expect(find.text('Switch to Dark Mode'), findsOneWidget);
    expect(find.text('Switch to Light Mode'), findsNothing);
  });

  testWidgets('DarkModeToggleButton displays correct text in dark mode',
      (WidgetTester tester) async {
    // Build our app with a mock provider in dark mode
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          themeProvider.overrideWith((ref) => MockThemeNotifier(darkAppTheme)),
        ],
        child: const MaterialApp(
          home: DarkModeToggleButton(),
        ),
      ),
    );

    // Verify dark mode text is displayed
    expect(find.text('Switch to Light Mode'), findsOneWidget);
    expect(find.text('Switch to Dark Mode'), findsNothing);
  });

  testWidgets(
      'DarkModeToggleButton calls toggleTheme when pressed in light mode',
      (WidgetTester tester) async {
    // Create a mock notifier we can reference later
    final mockNotifier = MockThemeNotifier(appTheme);

    // Build with our test provider
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          themeProvider.overrideWith((ref) => mockNotifier),
        ],
        child: const MaterialApp(
          home: DarkModeToggleButton(),
        ),
      ),
    );

    // Find and tap the button
    final buttonFinder = find.byType(ElevatedButton);
    expect(buttonFinder, findsOneWidget);

    await tester.tap(buttonFinder);
    await tester.pump();

    // Verify the theme was toggled
    expect(mockNotifier.toggleCalled, true);
    expect(mockNotifier.state, darkAppTheme);
  });

  testWidgets(
      'DarkModeToggleButton calls toggleTheme when pressed in dark mode',
      (WidgetTester tester) async {
    // Create a mock notifier we can reference later
    final mockNotifier = MockThemeNotifier(darkAppTheme);

    // Build with our test provider
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          themeProvider.overrideWith(
            (ref) => mockNotifier,
          ),
        ],
        child: const MaterialApp(
          home: DarkModeToggleButton(),
        ),
      ),
    );

    // Verify we're in dark mode
    expect(find.text('Switch to Light Mode'), findsOneWidget);

    // Find and tap the button
    final buttonFinder = find.byType(ElevatedButton);
    await tester.tap(buttonFinder);
    await tester.pump();

    // Verify the theme was toggled
    expect(mockNotifier.toggleCalled, true);
    expect(mockNotifier.state, appTheme);
  });

  testWidgets('DarkModeToggleButton has a Scaffold and is centered',
      (WidgetTester tester) async {
    // Build widget
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          themeProvider.overrideWith((ref) => MockThemeNotifier(appTheme)),
        ],
        child: const MaterialApp(
          home: DarkModeToggleButton(),
        ),
      ),
    );

    // Verify widget structure
    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byType(Center), findsOneWidget);

    // Verify the button is inside the Center widget
    final centerFinder = find.byType(Center);
    expect(tester.widget<Center>(centerFinder).child, isA<ElevatedButton>());
  });
}
