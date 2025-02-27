// This file contains widget tests for the WaypointSelectionScreen widget.
// The tests verify that the WaypointSelectionScreen widget correctly displays the RouteCard widgets
// and interacts with the NavBar.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soen_390/screens/waypoint/waypoint_selection_screens.dart';
import 'package:soen_390/widgets/nav_bar.dart';
import 'package:soen_390/widgets/route_card.dart';

void main() {
  // Test to verify that RouteCards are displayed after adding a route
  testWidgets('Displays RouteCards after adding a route', (WidgetTester tester) async {
    // Build the WaypointSelectionScreen widget inside a MaterialApp
    await tester.pumpWidget(
      const MaterialApp(
        home: WaypointSelectionScreen(),
      ),
    );

    // Wait for any asynchronous operations to complete
    await tester.pumpAndSettle();

    // Get the state of the WaypointSelectionScreen widget
    final state = tester.state<WaypointSelectionScreenState>(
        find.byType(WaypointSelectionScreen));

    // Add a test route to the confirmedRoutes list
    // ignore: invalid_use_of_protected_member
    state.setState(() {
      state.confirmedRoutes.add({
        "title": "Test Route",
        "timeRange": "10:00 - 10:30",
        "duration": "30 min",
        "description": "Start → Destination",
        "icons": [Icons.train],
      });
    });

    // Wait for the widget to rebuild
    await tester.pumpAndSettle();

    // Verify that the RouteCard is displayed with the correct information
    expect(find.byType(RouteCard), findsOneWidget);
    expect(find.text("Test Route"), findsOneWidget);
  });

  // Test to verify that the WaypointSelectionScreen interacts with the NavBar
  testWidgets('WaypointSelectionScreen interacts with NavBar', (WidgetTester tester) async {
    // Build the WaypointSelectionScreen widget inside a MaterialApp
    await tester.pumpWidget(
      const MaterialApp(
        home: WaypointSelectionScreen(),
      ),
    );

    // Wait for any asynchronous operations to complete
    await tester.pumpAndSettle();

    // Verify that the NavBar is displayed
    expect(find.byType(NavBar), findsOneWidget);

    // Tap on the second item in the NavBar (index 1)
    final walkIcon = find.byIcon(Icons.directions_walk);
    expect(walkIcon, findsOneWidget);
    await tester.tap(walkIcon);
    await tester.pumpAndSettle();

    // Verify that the WaypointSelectionScreen is still displayed
    expect(find.byType(WaypointSelectionScreen), findsOneWidget);
  });
}