// This file contains widget tests for the LocationTransportSelector widget.
// The tests verify that the LocationTransportSelector widget correctly displays the location fields,
// allows selecting a transport mode, interacts with the SuggestionsPopup, and confirms the route.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soen_390/widgets/location_transport_selector.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:soen_390/widgets/suggestions.dart';
import 'package:google_places_autocomplete_text_field/google_places_autocomplete_text_field.dart';

class MockCallbacks {
  void onConfirmRoute(List<String> waypoints, String transportMode) {}
  void onTransportModeChange(String mode) {}
  void onLocationChanged() {}
}

void main() {
  late MockCallbacks mockCallbacks;

  dotenv.testLoad(fileInput: 'GOOGLE_PLACES_API_KEY=mock-api-key');

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
  testWidgets('Initializes with initialDestination value',
      (WidgetTester tester) async {
    final initialDestination = "Central Station";

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LocationTransportSelector(
            onConfirmRoute: mockCallbacks.onConfirmRoute,
            initialDestination: initialDestination,
          ),
        ),
      ),
    );

    // Verify the initialDestination is set properly in the state
    final state = tester.state<LocationTransportSelectorState>(
        find.byType(LocationTransportSelector));

    expect(state.destinationLocation, equals(initialDestination));
    expect(state.itinerary.length, greaterThanOrEqualTo(1));

    if (state.itinerary.length > 1) {
      expect(state.itinerary[1], equals(initialDestination));
    } else {
      expect(state.itinerary[0], equals(initialDestination));
    }
  });
  testWidgets(
      'Tests initialization of itinerary when initialDestination provided but itinerary is empty',
      (WidgetTester tester) async {
    final initialDestination = "Central Station";

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LocationTransportSelector(
            onConfirmRoute: mockCallbacks.onConfirmRoute,
            initialDestination: initialDestination,
          ),
        ),
      ),
    );

    final state = tester.state<LocationTransportSelectorState>(
        find.byType(LocationTransportSelector));

    // Verify the initialDestination is added to the empty itinerary
    expect(state.itinerary.length, 1);
    expect(state.itinerary[0], equals(initialDestination));
  });
  testWidgets('Tests location selection through text input in SuggestionsPopup',
      (WidgetTester tester) async {
    // ignore: unused_local_variable
    String selectedLocation = "";

    await tester.pumpWidget(
      MaterialApp(
        home: SuggestionsPopup(
          onSelect: (location) {
            selectedLocation = location;
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    final textFieldFinder = find.byType(GooglePlacesAutoCompleteTextFormField);
    expect(textFieldFinder, findsOneWidget);

    await tester.enterText(textFieldFinder, "Custom Location");
    await tester.pump();

    expect(find.text("Custom Location"), findsOneWidget);
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
    expect(find.byIcon(Icons.delete), findsNothing);
  });

  testWidgets('Tests time option selection updates state correctly',
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

    // Open the dropdown
    await tester.tap(find.text("Leave Now"));
    await tester.pumpAndSettle();

    // Select "Arrive By"
    await tester.tap(find.text("Arrive By").last);
    await tester.pumpAndSettle();

    // Verify state update
    final state = tester.state<LocationTransportSelectorState>(
        find.byType(LocationTransportSelector));
    expect(state.selectedTimeOption, "Arrive By");
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

    expect(find.text("Your Location"), findsOneWidget);
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

    expect(find.text("Your Location"), findsOneWidget);
    expect(find.text("Destination"), findsOneWidget);

    expect(find.byIcon(Icons.directions_car), findsOneWidget);
    expect(find.byIcon(Icons.directions_bike), findsOneWidget);
    expect(find.byIcon(Icons.train), findsOneWidget);
    expect(find.byIcon(Icons.directions_walk), findsOneWidget);
  });
  testWidgets('Opens SuggestionsPopup when tapping location fields',
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

    await tester.tap(find.text("Your Location"));
    await tester.pumpAndSettle();

    expect(find.byType(SuggestionsPopup), findsOneWidget);

    await tester.tap(find.text("Restaurant"));
    await tester.pumpAndSettle();

    expect(find.text("Restaurant"), findsOneWidget);

    await tester.tap(find.text("Destination"));
    await tester.pumpAndSettle();

    expect(find.byType(SuggestionsPopup), findsOneWidget);

    await tester.tap(find.text("Coffee"));
    await tester.pumpAndSettle();

    expect(find.text("Coffee"), findsOneWidget);
  });
  testWidgets('SuggestionsPopup calls onSuggestionClicked and closes dialog',
      (WidgetTester tester) async {
    dotenv.testLoad(fileInput: 'GOOGLE_PLACES_API_KEY=mock-api-key');

    await tester.pumpWidget(MaterialApp(
      home: SuggestionsPopup(onSelect: (value) {}),
    ));

    await tester.enterText(
        find.byType(GooglePlacesAutoCompleteTextFormField), 'coffee');
    await tester.pump();

    await tester.tap(find.text('Coffee'));
    await tester.pumpAndSettle();

    expect(find.byType(SuggestionsPopup), findsNothing);
  });
  testWidgets('Initial destination handling - empty itinerary',
      (WidgetTester tester) async {
    final List<String> confirmedWaypoints = [];
    // ignore: unused_local_variable
    String confirmedMode = '';

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: LocationTransportSelector(
          initialDestination: 'Test Destination',
          onConfirmRoute: (waypoints, mode) {
            confirmedWaypoints.clear();
            confirmedWaypoints.addAll(waypoints);
            confirmedMode = mode;
          },
        ),
      ),
    ));

    // Get the state object
    final state = tester.state<LocationTransportSelectorState>(
        find.byType(LocationTransportSelector));

    // Verify itinerary has the initial destination
    expect(state.itinerary.length, 1);
    expect(state.itinerary[0], 'Test Destination');
  });

  testWidgets('Remove stop - first item with callback',
      (WidgetTester tester) async {
    bool locationChangedCalled = false;
    bool transportModeChangeCalled = false;
    String transportModeValue = '';

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: LocationTransportSelector(
          onConfirmRoute: (waypoints, mode) {},
          onLocationChanged: () {
            locationChangedCalled = true;
          },
          onTransportModeChange: (mode) {
            transportModeChangeCalled = true;
            transportModeValue = mode;
          },
        ),
      ),
    ));

    final state = tester.state<LocationTransportSelectorState>(
        find.byType(LocationTransportSelector));

    state.removeStopForTest(0);
    state.itinerary.add('Start Location');
    state.itinerary.add('Destination');

    state.removeStopForTest(0);

    expect(state.itinerary.length, 1);
    expect(state.itinerary[0], 'Destination');
    expect(locationChangedCalled, true);
    expect(transportModeChangeCalled, true);
    expect(transportModeValue, 'clear_cache');
  });
  testWidgets('Remove stop - second item', (WidgetTester tester) async {
    bool locationChangedCalled = false;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: LocationTransportSelector(
          onConfirmRoute: (waypoints, mode) {},
          onLocationChanged: () {
            locationChangedCalled = true;
          },
        ),
      ),
    ));

    final state = tester.state<LocationTransportSelectorState>(
        find.byType(LocationTransportSelector));

    // Setup the initial state (add stops, etc.)

    state.itinerary.add('Start Location');
    state.itinerary.add('Destination Location');

    // Remove the second stop (destination)
    state.removeStopForTest(1);

    // Wait for the widget to update after the change
    await tester.pumpAndSettle();

    // Check if onLocationChanged was triggered
    expect(locationChangedCalled, isTrue); // or isFalse based on your logic
  });
  testWidgets('Set destination location - existing itinerary with one item',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: LocationTransportSelector(onConfirmRoute: (a, b) {}),
      ),
    ));

    final state = tester.state<LocationTransportSelectorState>(
      find.byType(LocationTransportSelector),
    );
    state.removeStopForTest(0);
    state.itinerary.add('Start');
    state.setDestinationLocation('New Destination');

    expect(state.destinationLocation, 'New Destination');
    expect(state.itinerary, ['Start', 'New Destination']);
  });
  testWidgets('Set destination location - existing itinerary with two items',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: LocationTransportSelector(onConfirmRoute: (a, b) {}),
      ),
    ));

    final state = tester.state<LocationTransportSelectorState>(
      find.byType(LocationTransportSelector),
    );
    state.removeStopForTest(0);
    state.itinerary.add('Start');
    state.itinerary.add('Stop');
    state.setDestinationLocation('New Destination');

    expect(state.destinationLocation, 'New Destination');
    expect(state.itinerary, ['Start', 'New Destination']);
  });
  testWidgets('Set start location - long string input',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: LocationTransportSelector(onConfirmRoute: (a, b) {}),
      ),
    ));

    final state = tester.state<LocationTransportSelectorState>(
      find.byType(LocationTransportSelector),
    );
    state.removeStopForTest(0);
    String longString = 'This is a very long start location string';
    state.setStartLocation(longString);

    expect(state.startLocation, longString);
    expect(state.itinerary, [longString]);
  });
  testWidgets('Set start location - empty string input',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: LocationTransportSelector(onConfirmRoute: (a, b) {}),
      ),
    ));

    final state = tester.state<LocationTransportSelectorState>(
      find.byType(LocationTransportSelector),
    );
    state.removeStopForTest(0);
    state.setStartLocation('');

    expect(state.startLocation, '');
    expect(state.itinerary, ['']);
  });
  testWidgets('Set start location - existing itinerary with multiple items',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: LocationTransportSelector(onConfirmRoute: (a, b) {}),
      ),
    ));

    final state = tester.state<LocationTransportSelectorState>(
      find.byType(LocationTransportSelector),
    );
    state.removeStopForTest(0);
    state.itinerary.add('Old Item 1');
    state.itinerary.add('Old Item 2');
    state.setStartLocation('New Start');

    expect(state.startLocation, 'New Start');
    expect(state.itinerary, ['New Start', 'Old Item 1', 'Old Item 2']);
  });
  testWidgets('Delete destination location', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: LocationTransportSelector(
          onConfirmRoute: (a, b) {},
        ),
      ),
    ));

    final state = tester.state<LocationTransportSelectorState>(
      find.byType(LocationTransportSelector),
    );

    // Set up initial state
    state.startLocation = 'Start Location';
    state.destinationLocation = 'Destination Location';
    state.itinerary = ['Start Location', 'Destination Location'];

    await tester.pumpAndSettle();

    state.removeStopForTest(1);
    state.destinationLocation = '';

    await tester.pumpAndSettle();

    expect(state.destinationLocation, '');
    expect(state.itinerary, ['Start Location']);
  });

  testWidgets('removeStop functionality test', (WidgetTester tester) async {
    bool locationChangedCalled = false;
    String transportModeChangeValue = '';

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: LocationTransportSelector(
          onConfirmRoute: (a, b) {},
          onLocationChanged: () {
            locationChangedCalled = true;
          },
          onTransportModeChange: (mode) {
            transportModeChangeValue = mode;
          },
        ),
      ),
    ));

    final state = tester.state<LocationTransportSelectorState>(
      find.byType(LocationTransportSelector),
    );

    state.itinerary = ['Start Location', 'Destination'];
    locationChangedCalled = false;
    transportModeChangeValue = '';

    state.removeStopForTest(0);

    expect(state.itinerary, ['Destination']);
    expect(locationChangedCalled, true);
    expect(transportModeChangeValue, 'clear_cache');

    state.itinerary = ['Start', 'Middle', 'End'];
    locationChangedCalled = false;
    transportModeChangeValue = '';

    state.removeStopForTest(1);

    expect(state.itinerary, ['Start', 'End']);
    expect(locationChangedCalled, true);
    expect(transportModeChangeValue, '');
  });
}
