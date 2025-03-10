// This file contains widget tests for the RouteCard widget.
// The tests verify that the RouteCard widget correctly displays the route information.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soen_390/widgets/route_card.dart';

void main() {
  testWidgets('RouteCard displays correct information',
      (WidgetTester tester) async {
    // Define the test data
    const String title = 'Test Route';
    const String timeRange = '10:00 AM - 11:00 AM';
    const String duration = '1h';
    const String description = 'This is a test route description.';
    final List<IconData> icons = [Icons.directions_walk, Icons.directions_bike];

    // Build the RouteCard widget inside a MaterialApp and Scaffold
    // This is necessary to provide the required context for the widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RouteCard(
            title: title,
            timeRange: timeRange,
            duration: duration,
            description: description,
            icons: icons,
            isCrossCampus: false,
            routeData: null,
            onCardTapped: () => {},
          ),
        ),
      ),
    );

    // Verify the RouteCard displays the correct information
    expect(find.text(title), findsOneWidget);
    expect(find.text(timeRange), findsOneWidget);
    expect(find.text(duration), findsOneWidget);
    expect(find.text(description), findsOneWidget);
    expect(find.byIcon(Icons.directions_walk), findsOneWidget);
    expect(find.byIcon(Icons.directions_bike), findsOneWidget);
    expect(find.text("Cross-campus route"), findsNothing);
  });
  testWidgets('RouteCard displays cross-campus text when isCrossCampus is true',
      (WidgetTester tester) async {
    // Define the test data
    const String title = 'Test Route';
    const String timeRange = '10:00 AM - 11:00 AM';
    const String duration = '1h';
    const String description = 'This is a test route description.';
    final List<IconData> icons = [Icons.directions_walk, Icons.directions_bike];

    // Build the RouteCard widget with isCrossCampus set to true
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RouteCard(
            title: title,
            timeRange: timeRange,
            duration: duration,
            description: description,
            icons: icons,
            isCrossCampus: true,
            routeData: null,
            onCardTapped: () => {},
          ),
        ),
      ),
    );

    // Verify the RouteCard displays the cross-campus text
    expect(find.text("Cross-campus route"), findsOneWidget);
    expect(find.text(title), findsOneWidget);
    expect(find.text(timeRange), findsOneWidget);
    expect(find.text(duration), findsOneWidget);
    expect(find.text(description), findsOneWidget);
    expect(find.byIcon(Icons.directions_walk), findsOneWidget);
    expect(find.byIcon(Icons.directions_bike), findsOneWidget);
  });
}
