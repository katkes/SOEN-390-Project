// This file contains widget tests for the WaypointSelectionScreen widget.
// The tests verify that the WaypointSelectionScreen widget correctly displays the RouteCard widgets
// and interacts with the NavBar as expected.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soen_390/screens/waypoint/waypoint_selection_screens.dart';
import 'package:soen_390/widgets/nav_bar.dart';
import 'package:soen_390/widgets/route_card.dart';

void main() {
  testWidgets('WaypointSelectionScreen displays RouteCards',
      (WidgetTester tester) async {
    // Build the WaypointSelectionScreen widget inside a MaterialApp
    await tester.pumpWidget(
      const MaterialApp(
        home: WaypointSelectionScreen(),
      ),
    );

    // Wait for any asynchronous operations to complete
    await tester.pumpAndSettle();

    // Verify the WaypointSelectionScreen displays the RouteCards with correct information
    expect(find.byType(RouteCard), findsNWidgets(2));

    // Verify the first RouteCard (Concordia Shuttle)
    expect(find.text("Concordia Shuttle"), findsOneWidget);
    expect(find.text("10:00 - 10:30"), findsOneWidget);
    expect(find.text("30 min"), findsOneWidget);
    expect(find.text("10:00 from Sherbrooke"), findsOneWidget);
    expect(find.byIcon(Icons.accessible), findsOneWidget);
    expect(find.byIcon(Icons.train),
        findsNWidgets(3)); // 3 RouteCards with train icon

    // Verify the second RouteCard (Exo 11)
    expect(find.text("Exo 11"), findsOneWidget);
    expect(find.text("9:52 - 10:25"), findsOneWidget);
    expect(find.text("32 min"), findsOneWidget);
    expect(find.text("Walk 5 minutes to Montreal-West"), findsOneWidget);
    expect(find.byIcon(Icons.directions_walk),
        findsNWidgets(2)); // 2 RouteCards with walk icon
  });

  testWidgets('WaypointSelectionScreen interacts with NavBar',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: WaypointSelectionScreen(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify the NavBar is displayed
    expect(find.byType(NavBar), findsOneWidget);

    // Tap on the second item in the NavBar
    await tester.tap(find.byIcon(Icons.directions_walk).first);
    await tester.pumpAndSettle();

    // Verify the selected index is updated
    expect(find.byIcon(Icons.directions_walk),
        findsNWidgets(2)); // 2 RouteCards with walk icon
  });
}
