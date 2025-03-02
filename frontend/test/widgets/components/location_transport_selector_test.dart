// This file contains widget tests for the LocationTransportSelector widget.
// The tests verify that the LocationTransportSelector widget correctly displays the location fields,
// allows selecting a transport mode, interacts with the SuggestionsPopup, and confirms the route.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soen_390/widgets/location_transport_selector.dart';


void main() {
  testWidgets('Displays location fields and transport modes',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LocationTransportSelector(
            onConfirmRoute: (List<String> waypoints, String transportMode) {},
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text("Start Location"), findsOneWidget);
    expect(find.text("Destination"), findsOneWidget);

    expect(find.byIcon(Icons.directions_car), findsOneWidget);
    expect(find.byIcon(Icons.directions_bike), findsOneWidget);
    expect(find.byIcon(Icons.train), findsOneWidget);
    expect(find.byIcon(Icons.directions_walk), findsOneWidget);
  });

  
  testWidgets('Updates selected transport mode', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LocationTransportSelector(
            onConfirmRoute: (List<String> waypoints, String transportMode) {},
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text("Bike"));
    await tester.pumpAndSettle();

    expect(find.text("Bike"), findsOneWidget);
    final bikeIcon = tester.widget<Icon>(find.byIcon(Icons.directions_bike));
    expect(bikeIcon.color, const Color(0xFF912338)); // Selected color

    await tester.tap(find.text("Walk"));
    await tester.pumpAndSettle();

    expect(find.text("Walk"), findsOneWidget);
    final walkIcon = tester.widget<Icon>(find.byIcon(Icons.directions_walk));
    expect(walkIcon.color, const Color(0xFF912338)); // Selected color
  });


  testWidgets('Shows error when confirming route with incomplete itinerary',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LocationTransportSelector(
            onConfirmRoute: (List<String> waypoints, String transportMode) {},
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text("Confirm Route"));
    await tester.pumpAndSettle();

    expect(find.text("You must have at least a start and destination."),
        findsOneWidget);
  });

  
}
