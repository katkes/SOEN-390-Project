import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soen_390/models/route_result.dart';
import 'package:soen_390/models/step_result.dart';
import 'package:soen_390/services/google_route_service.dart';
import 'package:soen_390/services/geocoding_service.dart';
import 'package:soen_390/utils/campus_route_checker.dart';
import 'package:soen_390/utils/location_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:latlong2/latlong.dart';
import 'package:soen_390/screens/waypoint/waypoint_selection_screens.dart';
import 'package:soen_390/utils/route_cache_manager.dart';
import 'package:soen_390/utils/waypoint_validator.dart';
import 'package:soen_390/widgets/location_transport_selector.dart';
import 'package:soen_390/widgets/route_card.dart';
import 'package:soen_390/screens/indoor_accessibility/indoor_accessibility_preference.dart';

/// This test file, `waypoint_selection_screens_test.dart`, contains unit and widget tests for the
/// `WaypointSelectionScreen` widget in the Flutter application. These tests aim to verify the
/// functionality of the `WaypointSelectionScreen`, including its interactions with services like
/// `GoogleRouteService`, `GeocodingService`, and `LocationService`, as well as its UI behavior.
///
///
/// - `WaypointSelectionScreen`: The main widget responsible for allowing users to select waypoints,
///    choose transport modes, and display route information.
/// - `LocationTransportSelector`: A widget used within `WaypointSelectionScreen` to handle user
///    input for locations and transport modes.
/// - `RouteCard`: A widget used to display route information.
///

@GenerateNiceMocks([
  MockSpec<GoogleRouteService>(),
  MockSpec<GeocodingService>(),
  MockSpec<LocationService>(),
  MockSpec<CampusRouteChecker>()
])
import 'waypoint_selection_screens_test.mocks.dart';

void main() {
  late MockGoogleRouteService mockGoogleRouteService;
  late MockGeocodingService mockGeocodingService;
  late MockLocationService mockLocationService;
  late MockCampusRouteChecker mockCampusRouteChecker;
  TestWidgetsFlutterBinding.ensureInitialized();

  dotenv.testLoad(fileInput: '''
GOOGLE_PLACES_API_KEY=FAKE_API_KEY
''');
  setUp(() {
    // Initialize mocks before each test
    mockGoogleRouteService = MockGoogleRouteService();
    mockGeocodingService = MockGeocodingService();
    mockLocationService = MockLocationService();
    mockCampusRouteChecker = MockCampusRouteChecker();
  });
  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: WaypointSelectionScreen(
        routeService: mockGoogleRouteService,
        geocodingService: mockGeocodingService,
        locationService: mockLocationService,
        campusRouteChecker: mockCampusRouteChecker,
        waypointValidator: WaypointValidator(),
        routeCacheManager: RouteCacheManager(),
      ),
    );
  }

  RouteResult createMockRouteResult({
    required double distance,
    required double duration,
    List<LatLng>? routePoints,
    List<StepResult>? steps,
  }) {
    return RouteResult(
      distance: distance,
      duration: duration,
      routePoints: routePoints ??
          [
            const LatLng(45.5017, -73.5673), // Montreal
            const LatLng(45.4, -73.5), // Intermediate point
            const LatLng(46.8139, -71.2080), // Quebec City
          ],
      steps: steps ??
          [
            StepResult(
              distance: distance,
              duration: duration,
              instruction: 'Go north on Example St',
              maneuver: 'turn-right',
              startLocation: const LatLng(45.5017, -73.5673),
              endLocation: const LatLng(46.8139, -71.2080),
            ),
          ],
    );
  }

  testWidgets('WaypointSelectionScreen displays error on invalid route input',
      (WidgetTester tester) async {
    // Arrange
    when(mockGeocodingService.getCoordinates(any))
        .thenAnswer((_) async => const LatLng(45.5017, -73.5673));

    when(mockGoogleRouteService.getRoutes(
            from: anyNamed('from'), to: anyNamed('to')))
        .thenAnswer((_) async => {});

    await tester.pumpWidget(MaterialApp(
      home: WaypointSelectionScreen(
        routeService: mockGoogleRouteService,
        geocodingService: mockGeocodingService,
        locationService: mockLocationService,
        campusRouteChecker: mockCampusRouteChecker,
        waypointValidator: WaypointValidator(),
        routeCacheManager: RouteCacheManager(),
      ),
    ));

    // Act
    final finder = find.byType(LocationTransportSelector);
    final locationTransportSelector =
        tester.widget<LocationTransportSelector>(finder);
    locationTransportSelector.onConfirmRoute(['Start', 'End'], 'Car');
    await tester.pumpAndSettle();

    // Assert
    expect(
        find.text(
            'Error finding route: Exception: No routes found for the selected transport mode'),
        findsOneWidget);
  });
  testWidgets('WaypointSelectionScreen displays error on empty route response',
      (WidgetTester tester) async {
    // Arrange
    when(mockGeocodingService.getCoordinates(any))
        .thenAnswer((_) async => const LatLng(45.5017, -73.5673));
    when(mockGoogleRouteService.getRoutes(
            from: anyNamed('from'), to: anyNamed('to')))
        .thenAnswer((_) async => {}); // Empty route response

    await tester.pumpWidget(createWidgetUnderTest());

    // Act - Find and tap the confirm button after entering locations
    // First we need to find the LocationTransportSelector widget
    final selectorFinder = find.byType(LocationTransportSelector);
    expect(selectorFinder, findsOneWidget);

    // Extract the widget to get access to its state
    final selectorWidget =
        tester.widget<LocationTransportSelector>(selectorFinder);

    // Trigger the callback directly
    selectorWidget.onConfirmRoute(['Start Location', 'End Location'], 'Car');

    // Allow the async operations to complete
    await tester.pump();
    await tester
        .pump(const Duration(seconds: 1)); // Additional pump for animations

    // Assert - Error message should be shown
    expect(find.textContaining('Error finding route'), findsOneWidget);
  });
  testWidgets('WaypointSelectionScreen requires at least start and destination',
      (WidgetTester tester) async {
    // Arrange
    await tester.pumpWidget(createWidgetUnderTest());

    // Act - Call onConfirmRoute with insufficient waypoints
    final selectorFinder = find.byType(LocationTransportSelector);
    final selectorWidget =
        tester.widget<LocationTransportSelector>(selectorFinder);
    selectorWidget
        .onConfirmRoute(['Start Location'], 'Car'); // Only one waypoint

    // Allow the async operations and animations to complete
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Assert - Should show error message about requiring start and destination
    expect(find.text('You must have at least a start and destination.'),
        findsOneWidget);
  });
  testWidgets('WaypointSelectionScreen shows route cards when routes are found',
      (WidgetTester tester) async {
    // Arrange
    final mockRouteResult = createMockRouteResult(
      distance: 5000, // 5 km
      duration: 1200, // 20 minutes
    );

    final mockRoutesResponse = {
      'driving': [mockRouteResult],
    };

    when(mockGeocodingService.getCoordinates(any))
        .thenAnswer((_) async => const LatLng(45.5017, -73.5673));
    when(mockGoogleRouteService.getRoutes(
            from: anyNamed('from'), to: anyNamed('to')))
        .thenAnswer((_) async => mockRoutesResponse);

    await tester.pumpWidget(createWidgetUnderTest());

    // Act - Find selector and call onConfirmRoute
    final selectorFinder = find.byType(LocationTransportSelector);
    final selectorWidget =
        tester.widget<LocationTransportSelector>(selectorFinder);
    selectorWidget.onConfirmRoute(['Montreal', 'Quebec City'], 'Car');

    // Allow the async operations to complete
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Assert - RouteCard should be displayed
    expect(find.byType(RouteCard), findsOneWidget);
    // Verify expected route details are displayed
    expect(find.textContaining('Montreal to Quebec City'), findsOneWidget);
    expect(find.textContaining('20 min'), findsOneWidget);
  });

  testWidgets('WaypointSelectionScreen handles location coordinates error',
      (WidgetTester tester) async {
    when(mockGeocodingService.getCoordinates(any))
        .thenAnswer((_) async => null);

    await tester.pumpWidget(createWidgetUnderTest());

    final selectorFinder = find.byType(LocationTransportSelector);
    final selectorWidget =
        tester.widget<LocationTransportSelector>(selectorFinder);
    selectorWidget
        .onConfirmRoute(['Invalid Location', 'Another Location'], 'Car');

    // Let async code and SnackBar animation settle
    await tester.pumpAndSettle();
    // Assert: Flexible match for robustness
    expect(find.textContaining('Error finding route'), findsOneWidget);
  });

  testWidgets('WaypointSelectionScreen handles transport mode changes',
      (WidgetTester tester) async {
    // Arrange - Mock different responses for different transport modes
    final carRouteResult = createMockRouteResult(
      distance: 10000,
      duration: 1200, // 20 minutes
    );

    final walkRouteResult = createMockRouteResult(
      distance: 10000,
      duration: 7200, // 2 hours
    );

    when(mockGeocodingService.getCoordinates(any))
        .thenAnswer((_) async => const LatLng(45.5017, -73.5673));

    // First return car routes
    when(mockGoogleRouteService.getRoutes(
            from: anyNamed('from'), to: anyNamed('to')))
        .thenAnswer((_) async => {
              'driving': [carRouteResult]
            });

    await tester.pumpWidget(createWidgetUnderTest());

    // Act - Request car routes
    final selectorFinder = find.byType(LocationTransportSelector);
    final selectorWidget =
        tester.widget<LocationTransportSelector>(selectorFinder);
    selectorWidget.onConfirmRoute(['Start', 'End'], 'Car');

    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Assert - Should see car route
    expect(find.text('20 min'), findsOneWidget);

    // Change mock to return walking routes
    when(mockGoogleRouteService.getRoutes(
            from: anyNamed('from'), to: anyNamed('to')))
        .thenAnswer((_) async => {
              'walking': [walkRouteResult]
            });

    // Act - Request walking routes
    selectorWidget.onConfirmRoute(['Start', 'End'], 'Walk');

    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Assert - Should see walking route
    expect(find.text('2 h 0 min'), findsOneWidget);
  });

  testWidgets('WaypointSelectionScreen uses cache for repeated requests',
      (WidgetTester tester) async {
    // Arrange
    final mockRouteResult = createMockRouteResult(
      distance: 5000,
      duration: 1200, // 20 minutes
    );

    final mockRoutesResponse = {
      'driving': [mockRouteResult],
    };

    when(mockGeocodingService.getCoordinates(any))
        .thenAnswer((_) async => const LatLng(45.5017, -73.5673));
    when(mockGoogleRouteService.getRoutes(
            from: anyNamed('from'), to: anyNamed('to')))
        .thenAnswer((_) async => mockRoutesResponse);

    await tester.pumpWidget(createWidgetUnderTest());

    // Act - First request
    final selectorFinder = find.byType(LocationTransportSelector);
    final selectorWidget =
        tester.widget<LocationTransportSelector>(selectorFinder);
    selectorWidget.onConfirmRoute(['Montreal', 'Quebec City'], 'Car');

    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Make second identical request (should use cache)
    selectorWidget.onConfirmRoute(['Montreal', 'Quebec City'], 'Car');

    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Verify route service was only called once
    verify(mockGoogleRouteService.getRoutes(
            from: anyNamed('from'), to: anyNamed('to')))
        .called(1);
  });
  testWidgets(
      'WaypointSelectionScreen clears routes when transport mode changes',
      (WidgetTester tester) async {
    // Arrange
    final carRouteResult = createMockRouteResult(
      distance: 10000,
      duration: 1200, // 20 minutes
    );

    final walkRouteResult = createMockRouteResult(
      distance: 10000,
      duration: 7200, // 2 hours
    );

    when(mockGeocodingService.getCoordinates(any))
        .thenAnswer((_) async => const LatLng(45.5017, -73.5673));

    // First return car routes
    when(mockGoogleRouteService.getRoutes(
            from: anyNamed('from'), to: anyNamed('to')))
        .thenAnswer((_) async => {
              'driving': [carRouteResult]
            });

    await tester.pumpWidget(createWidgetUnderTest());

    // Act - Request car routes
    final selectorFinder = find.byType(LocationTransportSelector);
    final selectorWidget =
        tester.widget<LocationTransportSelector>(selectorFinder);
    selectorWidget.onConfirmRoute(['Start', 'End'], 'Car');

    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Assert - Should see car route card
    expect(find.byType(RouteCard), findsOneWidget);

    // Change mock to return walking routes
    when(mockGoogleRouteService.getRoutes(
            from: anyNamed('from'), to: anyNamed('to')))
        .thenAnswer((_) async => {
              'walking': [walkRouteResult]
            });

    // Act - Request walking routes (should clear previous car routes)
    selectorWidget.onConfirmRoute(['Start', 'End'], 'Walk');

    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Assert - Should see only one route card (old one should be gone)
    expect(find.byType(RouteCard), findsOneWidget);
  });

  testWidgets('WaypointSelectionScreen correctly shortens addresses',
      (WidgetTester tester) async {
    // Arrange
    final mockRouteResult = createMockRouteResult(
      distance: 5000,
      duration: 1200,
    );

    final mockRoutesResponse = {
      'driving': [mockRouteResult],
    };

    when(mockGeocodingService.getCoordinates(any))
        .thenAnswer((_) async => const LatLng(45.5017, -73.5673));
    when(mockGoogleRouteService.getRoutes(
            from: anyNamed('from'), to: anyNamed('to')))
        .thenAnswer((_) async => mockRoutesResponse);

    await tester.pumpWidget(createWidgetUnderTest());

    // Use full addresses with province and country
    final longStartAddress = "123 Main St, Montreal, Quebec, Canada";
    final longEndAddress = "456 Elm St, Quebec City, Quebec, Canada";

    // Expected shortened versions
    final shortStartAddress = "123 Main St, Montreal";
    final shortEndAddress = "456 Elm St, Quebec City";

    // Act
    final selectorFinder = find.byType(LocationTransportSelector);
    final selectorWidget =
        tester.widget<LocationTransportSelector>(selectorFinder);
    selectorWidget.onConfirmRoute([longStartAddress, longEndAddress], 'Car');

    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Assert - Should see shortened addresses
    expect(find.textContaining("$shortStartAddress to $shortEndAddress"),
        findsOneWidget);
    expect(find.textContaining("$shortStartAddress → $shortEndAddress"),
        findsOneWidget);
  });

  testWidgets('Shuttle Bus button updates mode and shows snackbar',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: WaypointSelectionScreen(
        routeService: mockGoogleRouteService,
        geocodingService: mockGeocodingService,
        locationService: mockLocationService,
        campusRouteChecker: mockCampusRouteChecker,
        waypointValidator: WaypointValidator(),
        routeCacheManager: RouteCacheManager(),
      ),
    ));

    expect(find.text('Use Shuttle Bus?'), findsOneWidget);

    await tester.tap(find.text('Use Shuttle Bus?'));
    await tester.pump();

    expect(find.text('Shuttle Bus selected!'), findsOneWidget);
  });

  testWidgets('Specify Disability button navigates to IndoorAccessibilityPage',
      (WidgetTester tester) async {
    // Arrange
    await tester.pumpWidget(MaterialApp(
      home: WaypointSelectionScreen(
        routeService: mockGoogleRouteService,
        geocodingService: mockGeocodingService,
        locationService: mockLocationService,
        campusRouteChecker: mockCampusRouteChecker,
        waypointValidator: WaypointValidator(),
        routeCacheManager: RouteCacheManager(),
      ),
    ));

    // Act
    final buttonFinder = find.text('Specify Disability');
    expect(buttonFinder, findsOneWidget);

    // Find the ElevatedButton widget (not the Text widget)
    final ElevatedButton elevatedButton =
        tester.widget<ElevatedButton>(find.byType(ElevatedButton).first);

    final ButtonStyle style = elevatedButton.style!;

    // Assert button background color is white
    expect(style.backgroundColor?.resolve({}), equals(Colors.white));

    // Assert button text color is the specific color
    expect(style.foregroundColor?.resolve({}), equals(const Color(0xff912338)));

    // Check the text style for font size and weight
    final Text textWidget =
        tester.widget<Text>(find.text('Specify Disability'));
    final TextStyle textStyle = textWidget.style!;
    expect(textStyle.fontSize, equals(14));
    expect(textStyle.fontWeight, equals(FontWeight.bold));

    // Tap the button and check navigation
    await tester.tap(buttonFinder);
    await tester.pumpAndSettle();

    // Assert navigation to IndoorAccessibilityPage
    expect(find.byType(IndoorAccessibilityPage), findsOneWidget);
  });
}
