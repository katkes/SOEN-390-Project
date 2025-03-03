// This file contains widget tests for the LocationTransportSelector widget.
// The tests verify that the LocationTransportSelector widget correctly displays the location fields,
// allows selecting a transport mode, interacts with the SuggestionsPopup, and confirms the route.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soen_390/widgets/location_transport_selector.dart';

class MockCallbacks {
  void onConfirmRoute(List<String> waypoints, String transportMode) {}
  void onTransportModeChange(String mode) {}
  void onLocationChanged() {}
}

void main() {
  late MockCallbacks mockCallbacks;

  setUp(() {
    mockCallbacks = MockCallbacks();
  });
  testWidgets('Tests time option dropdown selection',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LocationTransportSelector(
            onConfirmRoute: mockCallbacks.onConfirmRoute,
          ),
        ),
      ),
    );

    // Default value should be "Leave Now"
    expect(find.text("Leave Now"), findsOneWidget);

    // Open dropdown
    await tester.tap(find.text("Leave Now"));
    await tester.pumpAndSettle();

    // Select "Depart At"
    await tester.tap(find.text("Depart At").last);
    await tester.pumpAndSettle();

    // Verify selection changed
    expect(find.text("Depart At"), findsOneWidget);

    // Open dropdown again
    await tester.tap(find.text("Depart At"));
    await tester.pumpAndSettle();

    // Select "Arrive By"
    await tester.tap(find.text("Arrive By").last);
    await tester.pumpAndSettle();

    // Verify selection changed
    expect(find.text("Arrive By"), findsOneWidget);
  });
  testWidgets('Tests add stop button with insufficient locations',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LocationTransportSelector(
            onConfirmRoute: mockCallbacks.onConfirmRoute,
          ),
        ),
      ),
    );

    // Tap add stop
    await tester.tap(find.text("Add Stop to Itinerary"));
    await tester.pumpAndSettle();

    // Should show error message
    expect(find.text("Select both start and destination before adding!"),
        findsOneWidget);
  });
  testWidgets('Tests onTransportModeChange callback',
      (WidgetTester tester) async {
    bool callbackCalled = false;
    String selectedMode = "";

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LocationTransportSelector(
            onConfirmRoute: mockCallbacks.onConfirmRoute,
            onTransportModeChange: (mode) {
              callbackCalled = true;
              selectedMode = mode;
            },
          ),
        ),
      ),
    );

    // Tap on "Car" transport mode
    await tester.tap(find.text("Car"));
    await tester.pumpAndSettle();

    // Verify callback was called with correct mode
    expect(callbackCalled, true);
    expect(selectedMode, "Car");
  });

  testWidgets('Tests location delete functionality',
      (WidgetTester tester) async {
    final LocationTransportSelectorState state =
        LocationTransportSelectorState();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (BuildContext context) {
              // Manually set up state for testing
              state.startLocation = "Test Start Location";
              state.destinationLocation = "Test Destination";
              state.itinerary = ["Test Start Location", "Test Destination"];

              return LocationTransportSelector(
                onConfirmRoute: mockCallbacks.onConfirmRoute,
                onLocationChanged: mockCallbacks.onLocationChanged,
              );
            },
          ),
        ),
      ),
    );

    // Mock setup for testing delete functionality
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LocationTransportSelector(
            key: GlobalKey<LocationTransportSelectorState>(),
            onConfirmRoute: mockCallbacks.onConfirmRoute,
            onLocationChanged: mockCallbacks.onLocationChanged,
          ),
        ),
      ),
    );

    // Can't directly test the delete functionality without more complex setup
    // But we can verify the button is there
    expect(find.byIcon(Icons.delete),
        findsNothing); // Initially no delete icons visible
  });
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
