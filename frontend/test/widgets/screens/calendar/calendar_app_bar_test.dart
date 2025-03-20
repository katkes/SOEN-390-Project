import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soen_390/screens/calendar/calendar_app_bar.dart';
import 'package:soen_390/styles/theme.dart';

/// Test the CustomAppBar widget
/// The CustomAppBar is a custom AppBar widget that displays the title "My Calendar"
/// The CustomAppBar is used in the CalendarScreen to display the app bar
/// The tests in this file test the CustomAppBar by checking that the title is displayed correctly and has the proper styles
/// The tests use the flutter_test package to test the widget
/// The tests use the testWidgets function to test the widget
void main() {
  group('CustomAppBar', () {
    testWidgets('displays correct title and has proper styles',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            appBar: CustomAppBar(),
          ),
        ),
      );

      expect(find.text('My Calendar'), findsOneWidget);

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.foregroundColor, appTheme.colorScheme.onPrimary);

      expect(appBar.backgroundColor, appTheme.primaryColor);

      expect(appBar.iconTheme?.color, Colors.white);
    });

    testWidgets('has correct preferred size', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            appBar: CustomAppBar(),
          ),
        ),
      );

      final appBar = tester.widget<CustomAppBar>(find.byType(CustomAppBar));
      expect(appBar.preferredSize, const Size.fromHeight(kToolbarHeight));
    });
  });
}
