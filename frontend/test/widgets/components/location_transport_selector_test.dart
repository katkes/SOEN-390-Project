// test/location_transport_selector_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soen_390/screens/outdoor_poi/place_search_screen.dart';
import 'package:soen_390/widgets/location_transport_selector.dart';
import 'package:mockito/annotations.dart';
import 'package:soen_390/services/google_poi_service.dart';
import 'package:soen_390/services/poi_factory.dart';
import 'package:soen_390/utils/location_service.dart';
import 'package:mockito/mockito.dart';
import 'package:soen_390/widgets/suggestions.dart';

@GenerateMocks([LocationService, GooglePOIService, PointOfInterestFactory])
import 'location_transport_selector_test.mocks.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  late MockLocationService mockLocationService;
  late MockGooglePOIService mockPoiService;
  late MockPointOfInterestFactory mockPoiFactory;
  TestWidgetsFlutterBinding.ensureInitialized();

  dotenv.testLoad(fileInput: '''
GOOGLE_PLACES_API_KEY=FAKE_API_KEY
''');

  setUp(() {
    mockLocationService = MockLocationService();
    mockPoiService = MockGooglePOIService();
    mockPoiFactory = MockPointOfInterestFactory();
  });

  Widget createWidgetUnderTest({
    String? initialDestination,
    Function(List<String>, String)? onConfirmRoute,
    Function(String)? onTransportModeChange,
    Function()? onLocationChanged,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: LocationTransportSelector(
          locationService: mockLocationService,
          poiService: mockPoiService,
          poiFactory: mockPoiFactory,
          initialDestination: initialDestination,
          onConfirmRoute: onConfirmRoute ?? (_, __) {},
          onTransportModeChange: onTransportModeChange,
          onLocationChanged: onLocationChanged,
        ),
      ),
    );
  }

  testWidgets('Initializes with initialDestination',
      (WidgetTester tester) async {
    await tester.pumpWidget(
        createWidgetUnderTest(initialDestination: 'Test Destination'));

    final state = tester.state(find.byType(LocationTransportSelector))
        as LocationTransportSelectorState;

    expect(state.destinationLocation, equals('Test Destination'));
    expect(state.itinerary.contains('Test Destination'), isTrue);
  });

  testWidgets('Confirm Route button shows SnackBar if itinerary < 2',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    await tester.tap(find.text('Confirm Route'));
    await tester.pump(); // pump for SnackBar to show

    expect(find.text('You must have at least a start and destination.'),
        findsOneWidget);
  });

  testWidgets('Transport mode changes when tapped',
      (WidgetTester tester) async {
    String? selectedMode;
    await tester.pumpWidget(createWidgetUnderTest(
      onTransportModeChange: (mode) {
        selectedMode = mode;
      },
    ));

    await tester.tap(find.text('Car'));
    await tester.pump();

    expect(selectedMode, equals('Car'));
  });

  testWidgets('Start and Destination locations can be set via public methods',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    final state = tester.state(find.byType(LocationTransportSelector))
        as LocationTransportSelectorState;

    state.setStartLocation('Start Location');
    state.setDestinationLocation('Destination Location');

    expect(state.itinerary[0], equals('Start Location'));
    expect(state.itinerary[1], equals('Destination Location'));
  });

  testWidgets('Remove stop updates itinerary and calls onLocationChanged',
      (WidgetTester tester) async {
    bool locationChangedCalled = false;
    await tester.pumpWidget(createWidgetUnderTest(
      onLocationChanged: () {
        locationChangedCalled = true;
      },
    ));

    final state = tester.state(find.byType(LocationTransportSelector))
        as LocationTransportSelectorState;
    state.setStartLocation('Start');
    state.setDestinationLocation('Destination');
    expect(state.itinerary.length, equals(2));

    state.removeStopForTest(0);
    expect(state.itinerary.length, equals(1));
    expect(locationChangedCalled, isTrue);
  });

  testWidgets('Dropdown time option changes correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Depart At').last);
    await tester.pump();

    final state = tester.state(find.byType(LocationTransportSelector))
        as LocationTransportSelectorState;
    expect(state.selectedTimeOption, equals('Depart At'));
  });

  testWidgets('_showLocationSuggestions displays SuggestionsPopup',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // Tap the start location field to trigger _showLocationSuggestions
    await tester.tap(find.text('Start Location'));
    await tester.pumpAndSettle(); // Wait for dialog to open

    expect(find.byType(SuggestionsPopup), findsOneWidget);
  });

  testWidgets('_handleLocationSelection updates itinerary for start location',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // Tap to open the suggestions dialog
    await tester.tap(find.text('Start Location'));
    await tester.pumpAndSettle(); // Ensure dialog is rendered

    // Tap on the first suggestion (e.g., "Restaurant")
    await tester.tap(find.text('Restaurant').first);
    await tester
        .pumpAndSettle(); // Wait for post-frame callback & dialog to close

    final state = tester.state(find.byType(LocationTransportSelector))
        as LocationTransportSelectorState;

    expect(state.startLocation, equals('Restaurant'));
    expect(state.itinerary.first, equals('Restaurant'));
  });

  testWidgets(
      '_setStartLocation inserts at position 0 when itinerary not empty',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    final state = tester.state(find.byType(LocationTransportSelector))
        as LocationTransportSelectorState;

    // Set initial destination to populate itinerary
    state.setDestinationLocation('Destination');
    expect(state.itinerary, ['Destination']);

    // Now set start location
    state.setStartLocation('Start');
    expect(state.itinerary, ['Start', 'Destination']);
  });

  testWidgets(
      'Transport mode fallback triggers onConfirmRoute when onTransportModeChange is null',
      (WidgetTester tester) async {
    List<String>? confirmedRoute;
    String? confirmedMode;

    await tester.pumpWidget(createWidgetUnderTest(
      onConfirmRoute: (route, mode) {
        confirmedRoute = route;
        confirmedMode = mode;
      },
    ));

    final state = tester.state(find.byType(LocationTransportSelector))
        as LocationTransportSelectorState;
    state.setStartLocation('Start');
    state.setDestinationLocation('Destination');

    await tester.tap(find.text('Bike'));
    await tester.pump();

    expect(confirmedRoute, containsAll(['Start', 'Destination']));
    expect(confirmedMode, equals('Bike'));
  });
  testWidgets(
      '_setDestinationLocation replaces second itinerary entry when length == 2',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    final state = tester.state(find.byType(LocationTransportSelector))
        as LocationTransportSelectorState;

    state.setStartLocation('Start');
    state.setDestinationLocation('Old Destination');
    state.setDestinationLocation('New Destination');

    expect(state.itinerary[1], equals('New Destination'));
  });

  testWidgets('"Search POIS" button navigates and updates destinationLocation',
      (WidgetTester tester) async {
    bool locationChangedCalled = false;
    final navigatorObserver = MockNavigatorObserver();

    await tester.pumpWidget(MaterialApp(
      navigatorObservers: [navigatorObserver],
      home: Scaffold(
        body: LocationTransportSelector(
          locationService: mockLocationService,
          poiService: mockPoiService,
          poiFactory: mockPoiFactory,
          onConfirmRoute: (_, __) {},
          onLocationChanged: () {
            locationChangedCalled = true;
          },
        ),
      ),
    ));

    // Tap the "Search POIS" button
    await tester.tap(find.text('Search POIS'));
    await tester.pumpAndSettle(); // Wait for navigation

    expect(find.byType(PlaceSearchScreen), findsOneWidget);

    // Call onSetDestination as user would
    final screenWidget =
        tester.widget<PlaceSearchScreen>(find.byType(PlaceSearchScreen));
    screenWidget.onSetDestination?.call('Selected Destination', 0.0, 0.0);

    // Pop the screen to trigger state update in LocationTransportSelector
    Navigator.pop(tester.element(find.byType(PlaceSearchScreen)));
    await tester.pumpAndSettle();

    // Now test state
    final state = tester.state(find.byType(LocationTransportSelector))
        as LocationTransportSelectorState;

    expect(state.destinationLocation, equals('Selected Destination'));
    expect(state.itinerary.contains('Selected Destination'), isTrue);
    expect(locationChangedCalled, isTrue);
  });
}
