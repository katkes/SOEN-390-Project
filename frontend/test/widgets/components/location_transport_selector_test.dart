// test/location_transport_selector_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soen_390/screens/outdoor_poi/place_search_screen.dart';
import 'package:soen_390/screens/shuttle_bus/shuttle_schedule_screen.dart';
import 'package:soen_390/services/location_updater.dart';
import 'package:soen_390/widgets/location_transport_selector.dart';
import 'package:mockito/annotations.dart';
import 'package:soen_390/services/google_poi_service.dart';
import 'package:soen_390/services/poi_factory.dart';
import 'package:soen_390/utils/location_service.dart';
import 'package:soen_390/widgets/suggestions.dart';
import 'package:soen_390/screens/indoor/mappedin_map_controller.dart';

import 'package:mockito/mockito.dart';
import 'package:geolocator/geolocator.dart';
import 'package:soen_390/widgets/location_field.dart';

@GenerateNiceMocks([
  MockSpec<LocationService>(),
  MockSpec<GooglePOIService>(),
  MockSpec<PointOfInterestFactory>(),
  MockSpec<LocationUpdater>(),
  MockSpec<NavigatorObserver>(),
])
import 'location_transport_selector_test.mocks.dart';

// Manual mock for MappedinMapController
class MockMappedinMapController extends Mock implements MappedinMapController {
  @override
  Future<bool> selectBuildingByName(String buildingName) async {
    return super.noSuchMethod(
      Invocation.method(#selectBuildingByName, [buildingName]),
      returnValue: Future.value(true),
      returnValueForMissingStub: Future.value(true),
    );
  }

  @override
  Future<bool> navigateToRoom(String roomName, bool isStart) async {
    return super.noSuchMethod(
      Invocation.method(#navigateToRoom, [roomName, isStart]),
      returnValue: Future.value(true),
      returnValueForMissingStub: Future.value(true),
    );
  }
}

class TestLocationTransportSelectorState
    extends LocationTransportSelectorState {
  void updateStartLocationForTest(String newLocation) {
    setState(() {
      startLocation = newLocation;
    });
  }
}

class TestLocationTransportSelector extends LocationTransportSelector {
  TestLocationTransportSelector({
    required super.locationService,
    required super.poiService,
    required super.poiFactory,
    required super.locationUpdater,
    required super.onConfirmRoute,
    super.onTransportModeChange,
    super.onLocationChanged,
    super.initialDestination,
    super.hallController,
    super.libraryController,
  });

  @override
  LocationTransportSelectorState createState() =>
      TestLocationTransportSelectorState();
}

void main() {
  late MockLocationService mockLocationService;
  late MockGooglePOIService mockPoiService;
  late MockPointOfInterestFactory mockPoiFactory;
  late MockLocationUpdater mockLocationUpdater;
  TestWidgetsFlutterBinding.ensureInitialized();

  dotenv.testLoad(fileInput: '''
GOOGLE_PLACES_API_KEY=FAKE_API_KEY
''');

  setUp(() {
    mockLocationService = MockLocationService();
    mockPoiService = MockGooglePOIService();
    mockPoiFactory = MockPointOfInterestFactory();
    mockLocationUpdater = MockLocationUpdater();
  });

  Widget createWidgetUnderTest({
    String? initialDestination,
    Function(List<String>, String)? onConfirmRoute,
    Function(String)? onTransportModeChange,
    Function()? onLocationChanged,
    MappedinMapController? hallController,
    MappedinMapController? libraryController,
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
          locationUpdater: mockLocationUpdater,
          hallController: hallController,
          libraryController: libraryController,
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
    expect(state.itineraryManager.getWaypoints(), contains('Test Destination'));
  });

  testWidgets('Confirm Route button shows SnackBar if itinerary < 2',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    await tester.tap(find.text('Confirm Route'));
    await tester.pump();

    expect(find.text('You must have at least a start and destination.'),
        findsOneWidget);
  });

  testWidgets('_confirmRoute executes default behavior for other routes',
      (WidgetTester tester) async {
    // Arrange
    List<String>? confirmedWaypoints;
    String? confirmedMode;

    await tester.pumpWidget(createWidgetUnderTest(
      onConfirmRoute: (waypoints, mode) {
        confirmedWaypoints = waypoints;
        confirmedMode = mode;
      },
    ));

    final state = tester.state(find.byType(LocationTransportSelector))
        as LocationTransportSelectorState;

    // Set start and destination locations to a non-specific case
    state.setStartLocation('Start Location');
    state.setDestinationLocation('Destination Location');

    // Act - Call _confirmRoute
    await tester.tap(find.text('Confirm Route'));
    await tester.pumpAndSettle();

    // Assert - Verify default behavior
    expect(confirmedWaypoints,
        containsAll(['Start Location', 'Destination Location']));
    expect(confirmedMode, equals('Train or Bus'));
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

    final waypoints = state.itineraryManager.getWaypoints();

    expect(waypoints[0], equals('Start Location'));
    expect(waypoints[1], equals('Destination Location'));
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
    expect(state.itineraryManager.getWaypoints().length, equals(2));

    state.removeStopForTest(0);
    expect(state.itineraryManager.getWaypoints().length, equals(1));
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

    await tester.tap(find.text('Your Location'));
    await tester.pumpAndSettle();

    expect(find.byType(SuggestionsPopup), findsOneWidget);
  });

  testWidgets(
      '_setStartLocation inserts at position 0 when itinerary not empty',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    final state = tester.state(find.byType(LocationTransportSelector))
        as LocationTransportSelectorState;

    final manager = state.itineraryManager;

    // Reinitialize by setting only destination — this will append to default 'Your Location'
    manager.setDestination('Destination');
    // This results in: ['Your Location', 'Destination']

    // Now replace start with custom value
    state.setStartLocation('Start');

    expect(manager.getWaypoints(), ['Start', 'Destination']);
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
    final manager = state.itineraryManager;

    state.setStartLocation('Start');
    state.setDestinationLocation('Old Destination');
    state.setDestinationLocation('New Destination');

    expect(manager.getWaypoints()[1], equals('New Destination'));
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
          locationUpdater: mockLocationUpdater,
        ),
      ),
    ));

    await tester.tap(find.text("What's Nearby?"));
    await tester.pumpAndSettle();

    expect(find.byType(PlaceSearchScreen), findsOneWidget);

    final screenWidget =
        tester.widget<PlaceSearchScreen>(find.byType(PlaceSearchScreen));
    screenWidget.onSetDestination?.call('Selected Destination', 0.0, 0.0);

    Navigator.pop(tester.element(find.byType(PlaceSearchScreen)));
    await tester.pumpAndSettle();

    final state = tester.state(find.byType(LocationTransportSelector))
        as LocationTransportSelectorState;

    expect(state.destinationLocation, equals('Selected Destination'));
    expect(state.itineraryManager.getWaypoints(),
        contains('Selected Destination'));
    expect(locationChangedCalled, isTrue);
  });

  testWidgets('LocationField onDelete resets start location to Your Location',
      (WidgetTester tester) async {
    final mockPosition = Position(
        latitude: 45.0,
        longitude: -73.0,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0);

    when(mockLocationService.getCurrentLocation())
        .thenAnswer((_) => Future.value(mockPosition));

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: TestLocationTransportSelector(
          locationService: mockLocationService,
          poiService: mockPoiService,
          poiFactory: mockPoiFactory,
          onConfirmRoute: (_, __) {},
          locationUpdater: mockLocationUpdater,
        ),
      ),
    ));

    final state = tester.state(find.byType(TestLocationTransportSelector))
        as TestLocationTransportSelectorState;

    state.updateStartLocationForTest('Custom Start Location');
    await tester.pumpAndSettle();

    expect(state.startLocation, equals('Custom Start Location'));

    final startLocationField = find.byType(LocationField).first;

    final deleteButton = find.descendant(
      of: startLocationField,
      matching: find.byType(IconButton),
    );

    expect(deleteButton, findsOneWidget);

    await tester.tap(deleteButton);
    await tester.pumpAndSettle();

    verify(mockLocationService.getCurrentLocation()).called(1);

    expect(state.startLocation, equals('Your Location'));
  });

  testWidgets('Shuttle Bus button navigates to ShuttleScheduleScreen',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // Tap the Shuttle Bus button
    await tester.tap(find.text('Shuttle Bus'));
    await tester.pumpAndSettle();

    // Verify navigation to ShuttleScheduleScreen
    expect(find.byType(ShuttleScheduleScreen), findsOneWidget);
  });

  testWidgets('Destination field shows SuggestionsPopup on tap',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // Tap the destination field
    await tester.tap(find.text('Destination'));
    await tester.pumpAndSettle();

    // Verify SuggestionsPopup is displayed
    expect(find.byType(SuggestionsPopup), findsOneWidget);
  });

  testWidgets('Destination field shows SuggestionsPopup on tap',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // Tap the destination field
    await tester.tap(find.text('Destination'));
    await tester.pumpAndSettle();

    // Verify SuggestionsPopup is displayed
    expect(find.byType(SuggestionsPopup), findsOneWidget);
  });

  testWidgets('_showLocationSuggestions displays SuggestionsPopup',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // Tap the start location field
    await tester.tap(find.text('Your Location'));
    await tester.pumpAndSettle();

    // Verify SuggestionsPopup is displayed
    expect(find.byType(SuggestionsPopup), findsOneWidget);

    // Simulate selecting a location
    final state = tester.state(find.byType(LocationTransportSelector))
        as LocationTransportSelectorState;
    state.setStartLocation('H843');
    state.setDestinationLocation('LB322');

    // Verify that the start and destination locations are updated
    expect(state.startLocation, equals('H843'));
    expect(state.destinationLocation, equals('LB322'));
  });

  group('H843 to LB322 special case', () {
    testWidgets('Shows error SnackBar when Hall Building selection fails',
        (WidgetTester tester) async {
      // Arrange
      final hallController = MockMappedinMapController();
      when(hallController.selectBuildingByName("Hall Building"))
          .thenAnswer((_) => Future.value(false));

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: LocationTransportSelector(
            locationService: mockLocationService,
            poiService: mockPoiService,
            poiFactory: mockPoiFactory,
            onConfirmRoute: (_, __) {},
            locationUpdater: mockLocationUpdater,
            hallController: hallController,
          ),
        ),
      ));

      // Set up the route
      final state = tester.state(find.byType(LocationTransportSelector))
          as LocationTransportSelectorState;
      state.setStartLocation('H843');
      state.setDestinationLocation('LB322');

      // Act - Call _confirmRoute
      await tester.tap(find.text('Confirm Route'));
      await tester.pumpAndSettle();

      // Assert - Verify error SnackBar is shown
      expect(find.text('Failed to switch to Hall Building'), findsOneWidget);
    });
  });
}
