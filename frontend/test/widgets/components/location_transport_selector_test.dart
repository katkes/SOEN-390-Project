// This file contains widget tests for the LocationTransportSelector widget.
// The tests verify that the LocationTransportSelector widget correctly displays the location fields
// and transport modes, and interacts with the SuggestionsPopup as expected.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soen_390/widgets/location_transport_selector.dart';
import 'package:soen_390/widgets/suggestions.dart';

void main() {
  testWidgets(
      'LocationTransportSelector displays location fields and transport modes',
      (WidgetTester tester) async {
    // Build the LocationTransportSelector widget inside a MaterialApp
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LocationTransportSelector(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify the LocationTransportSelector displays the location fields with correct information
    expect(find.text("Current Location"), findsOneWidget);
    expect(find.text("Hall Building"), findsOneWidget);

    // Verify the LocationTransportSelector displays the transport modes with correct icons
    expect(find.byIcon(Icons.directions_car), findsOneWidget);
    expect(find.byIcon(Icons.directions_bike), findsOneWidget);
    expect(find.byIcon(Icons.train), findsOneWidget);
    expect(find.byIcon(Icons.directions_walk), findsOneWidget);
  });

  testWidgets('LocationTransportSelector interacts with SuggestionsPopup',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LocationTransportSelector(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Tap on the current location field to open the SuggestionsPopup
    await tester.tap(find.text("Current Location"));
    await tester.pumpAndSettle();

    // Verify the SuggestionsPopup is displayed
    expect(find.byType(SuggestionsPopup), findsOneWidget);

    // Select a location from the SuggestionsPopup
    await tester.tap(find.text("Restaurant"));
    await tester.pumpAndSettle();

    // Verify the current location is updated
    expect(find.text("Restaurant"), findsOneWidget);

    // Tap on the destination field to open the SuggestionsPopup
    await tester.tap(find.text("Hall Building"));
    await tester.pumpAndSettle();

    // Verify the SuggestionsPopup is displayed
    expect(find.byType(SuggestionsPopup), findsOneWidget);

    // Select a location from the SuggestionsPopup
    await tester.tap(find.text("Coffee"));
    await tester.pumpAndSettle();

    // Verify the destination is updated
    expect(find.text("Coffee"), findsOneWidget);
  });

  testWidgets('LocationTransportSelector updates selected transport mode',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LocationTransportSelector(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Tap on the "Bike" transport mode
    await tester.tap(find.text("Bike"));
    await tester.pumpAndSettle();

    // Verify the selected transport mode is updated to "Bike"
    expect(find.text("Bike"), findsOneWidget);
    expect(find.byIcon(Icons.directions_bike), findsOneWidget);
    final bikeIcon = tester.widget<Icon>(find.byIcon(Icons.directions_bike));
    expect(bikeIcon.color, Color(0xFF912338)); // Selected color

    // Tap on the "Walk" transport mode
    await tester.tap(find.text("Walk"));
    await tester.pumpAndSettle();

    // Verify the selected transport mode is updated to "Walk"
    expect(find.text("Walk"), findsOneWidget);
    expect(find.byIcon(Icons.directions_walk), findsOneWidget);
    expect(find.byIcon(Icons.directions_walk), findsOneWidget);
    final walkIcon = tester.widget<Icon>(find.byIcon(Icons.directions_walk));
    expect(walkIcon.color, Color(0xFF912338)); // Selected color
  });
}
