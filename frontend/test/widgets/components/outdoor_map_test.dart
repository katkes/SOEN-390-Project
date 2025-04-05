import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:latlong2/latlong.dart';
import 'package:soen_390/models/route_result.dart';
import 'package:soen_390/models/step_result.dart';
import 'package:soen_390/services/google_maps_api_client.dart';
import 'package:soen_390/services/interfaces/http_client_interface.dart';
import 'package:soen_390/services/interfaces/route_service_interface.dart';
import 'package:http/http.dart' as http;
import 'package:soen_390/widgets/building_popup.dart';
import 'package:soen_390/widgets/outdoor_map.dart';
import 'dart:typed_data';

@GenerateNiceMocks([
  MockSpec<IRouteService>(),
  MockSpec<IHttpClient>(),
  MockSpec<BuildingPopUps>(),
  MockSpec<GoogleMapsApiClient>()
])
import 'outdoor_map_test.mocks.dart';

/// Unit tests for the [OutdoorMap] widget, testing route fetching and map rendering behavior.
void main() {
  late MockIRouteService mockRouteService;
  late MockIHttpClient mockHttpClient;
  late LatLng testLocation;
  late MockGoogleMapsApiClient mockMapsApiClient;
  late MockBuildingPopUps mockBuildingPopUps;

  setUp(() {
    mockRouteService = MockIRouteService();
    mockHttpClient = MockIHttpClient();
    testLocation = const LatLng(45.5017, -73.5673);
    mockMapsApiClient = MockGoogleMapsApiClient();
    mockBuildingPopUps = MockBuildingPopUps();

    // Mocking route service response
    when(mockRouteService.getRoute(
      from: anyNamed('from'),
      to: anyNamed('to'),
    )).thenAnswer((_) async {
      return RouteResult(
        distance: 1000.0,
        duration: 600.0,
        routePoints: [
          const LatLng(45.497856, -73.579588),
          const LatLng(45.498000, -73.580000),
        ],
        steps: [
          StepResult(
            distance: 500.0,
            duration: 300.0,
            instruction: "Turn left onto Main St.",
            maneuver: "turn-left",
            startLocation: const LatLng(45.497856, -73.579588),
            endLocation: const LatLng(45.498000, -73.580000),
          ),
        ],
      );
    });

    final transparentPixelPng = Uint8List.fromList([
      0x89,
      0x50,
      0x4E,
      0x47,
      0x0D,
      0x0A,
      0x1A,
      0x0A,
      0x00,
      0x00,
      0x00,
      0x0D,
      0x49,
      0x48,
      0x44,
      0x52,
      0x00,
      0x00,
      0x00,
      0x01,
      0x00,
      0x00,
      0x00,
      0x01,
      0x08,
      0x06,
      0x00,
      0x00,
      0x00,
      0x1F,
      0x15,
      0xC4,
      0x89,
      0x00,
      0x00,
      0x00,
      0x0A,
      0x49,
      0x44,
      0x41,
      0x54,
      0x78,
      0x9C,
      0x63,
      0x00,
      0x01,
      0x00,
      0x00,
      0x05,
      0x00,
      0x01,
      0x0D,
      0x0A,
      0x2D,
      0xB4,
      0x00,
      0x00,
      0x00,
      0x00,
      0x49,
      0x45,
      0x4E,
      0x44,
      0xAE,
      0x42,
      0x60,
      0x82
    ]);

    // Mock HTTP response for map tiles
    when(mockHttpClient.get(any)).thenAnswer((_) async => http.Response.bytes(
          transparentPixelPng,
          200,
          headers: {'content-type': 'image/png'},
        ));
  });
  final LatLng userLocation = const LatLng(45.495, -73.577);

  /// Test that the [MapWidget] initializes correctly with the provided location.
  testWidgets('MapWidget initializes with provided location',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MapWidget(
            location: testLocation,
            userLocation: userLocation,
            httpClient: mockHttpClient,
            routeService: mockRouteService,
            mapsApiClient: mockMapsApiClient,
            buildingPopUps: mockBuildingPopUps,
            routePoints: const [],
          ),
        ),
      ),
    );

    await tester.pump();
    expect(find.byType(FlutterMap), findsOneWidget);
  });

  /// Test that the [MapWidget] handles null route result gracefully without crashing.
  testWidgets('MapWidget handles null route result gracefully',
      (WidgetTester tester) async {
    // Modify the mock to return null for route
    when(mockRouteService.getRoute(from: anyNamed('from'), to: anyNamed('to')))
        .thenAnswer((_) async => null);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MapWidget(
            location: testLocation,
            userLocation: userLocation,
            httpClient: mockHttpClient,
            routeService: mockRouteService,
            mapsApiClient: mockMapsApiClient,
            buildingPopUps: mockBuildingPopUps,
            routePoints: const [],
          ),
        ),
      ),
    );

    await tester.pump();

    // Verify the widget doesn't crash
    expect(find.byType(FlutterMap), findsOneWidget);
  });

  group('MyPage Tests', () {
    final LatLng userLocation = const LatLng(45.495, -73.577);

    testWidgets('MyPage renders MapWidget with correct props',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: MyPage(
          location: testLocation,
          httpClient: mockHttpClient,
          userLocation: userLocation,
          routeService: mockRouteService,
          mapsApiClient: mockMapsApiClient,
          buildingPopUps: mockBuildingPopUps,
        ),
      ));

      // Find the specific Center widget that's the direct parent of MapWidget
      final centerWithMap = find.ancestor(
        of: find.byType(MapWidget),
        matching: find.byType(Center),
      );
      expect(centerWithMap, findsOneWidget);

      // Verify MapWidget is present and has correct props
      final mapWidget = tester.widget<MapWidget>(find.byType(MapWidget));
      expect(mapWidget.location, equals(testLocation));
      expect(mapWidget.httpClient, equals(mockHttpClient));
      expect(mapWidget.routeService, equals(mockRouteService));
    });
    testWidgets('MapWidget updates when user location changes',
        (WidgetTester tester) async {
      // Initial location
      final LatLng mapCenter = const LatLng(45.497, -73.579);
      final LatLng initialUserLocation = const LatLng(45.495, -73.577);

      // Create a key to find the widget
      final mapWidgetKey = GlobalKey();

      // Build widget with initial location
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MapWidget(
              key: mapWidgetKey,
              location: mapCenter,
              userLocation: initialUserLocation,
              httpClient: mockHttpClient,
              routeService: mockRouteService,
              mapsApiClient: mockMapsApiClient,
              buildingPopUps: mockBuildingPopUps,
              routePoints: const [],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Create a new location
      final LatLng newUserLocation = const LatLng(45.500, -73.570);

      // Rebuild with new user location
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MapWidget(
              key: mapWidgetKey,
              location: mapCenter,
              userLocation: newUserLocation,
              httpClient: mockHttpClient,
              routeService: mockRouteService,
              mapsApiClient: mockMapsApiClient,
              buildingPopUps: mockBuildingPopUps,
              routePoints: const [],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
    });

    //test that the map widget is rendered with empty route points initially
    testWidgets('MyPage renders MapWidget with empty routePoints initially',
        (WidgetTester tester) async {
      // Pump the MaterialApp with MyPage as the home widget.
      // This simulates the app starting and displaying MyPage.
      await tester.pumpWidget(MaterialApp(
        home: MyPage(
          location: testLocation,
          httpClient: mockHttpClient,
          routeService: mockRouteService,
          mapsApiClient: mockMapsApiClient,
          buildingPopUps: mockBuildingPopUps,
          userLocation: userLocation,
        ),
      ));

      // Find the MapWidget within the widget tree.
      // This locates the MapWidget that MyPage is expected to render.
      final mapWidget = tester.widget<MapWidget>(find.byType(MapWidget));

      // Assert that the routePoints property of the MapWidget is initially empty.
      // This verifies that MyPage initializes the MapWidget with no route points.
      expect(mapWidget.routePoints, isEmpty);
    });
  });

  testWidgets('MapWidget does not animate when routePoints is empty',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MapWidget(
            location: testLocation,
            httpClient: mockHttpClient,
            routeService: mockRouteService,
            mapsApiClient: mockMapsApiClient,
            buildingPopUps: mockBuildingPopUps,
            routePoints: const [],
            userLocation: userLocation,
          ),
        ),
      ),
    );

    // Give time for any possible animation
    await tester.pump(const Duration(milliseconds: 100));

    // Expect no PolylineLayer since no route exists
    expect(find.byType(PolylineLayer), findsNothing);
  });
  testWidgets('Polyline animation does not trigger with empty route points',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MapWidget(
            location: testLocation,
            userLocation: userLocation,
            httpClient: mockHttpClient,
            routeService: mockRouteService,
            mapsApiClient: mockMapsApiClient,
            buildingPopUps: mockBuildingPopUps,
            routePoints: const [], // Empty route points
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify PolylineLayer does not exist because there are no route points
    expect(find.byType(PolylineLayer), findsNothing);
  });

  testWidgets('MapWidget UI appearance test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MapWidget(
            location: testLocation,
            httpClient: mockHttpClient,
            routeService: mockRouteService,
            mapsApiClient: mockMapsApiClient,
            buildingPopUps: mockBuildingPopUps,
            routePoints: const [],
            userLocation: userLocation,
          ),
        ),
      ),
    );

    // Ensure all animations complete
    await tester.pumpAndSettle();

    // Check for ClipRRect with correct border radius
    final clipRRect = tester.widget<ClipRRect>(find.byType(ClipRRect));
    expect(clipRRect.borderRadius, equals(BorderRadius.circular(30)));
  });

  /// Test that the locate me button updates the map center to user's location.
  testWidgets('Locate Me button updates map center',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MapWidget(
            location: testLocation,
            userLocation: userLocation,
            httpClient: mockHttpClient,
            routeService: mockRouteService,
            mapsApiClient: mockMapsApiClient,
            buildingPopUps: mockBuildingPopUps,
            routePoints: const [],
          ),
        ),
      ),
    );

    await tester.pump();
    expect(find.byKey(const Key('indoor-navigation-buttons')), findsOneWidget);
    await tester.tap(find.byKey(const Key('indoor-navigation-buttons')));
    await tester.pump();
  });
  testWidgets('User location updates correctly on map',
      (WidgetTester tester) async {
    final updatedUserLocation = const LatLng(45.500, -73.570);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MapWidget(
            location: testLocation,
            userLocation: updatedUserLocation,
            httpClient: mockHttpClient,
            routeService: mockRouteService,
            mapsApiClient: mockMapsApiClient,
            buildingPopUps: mockBuildingPopUps,
            routePoints: const [],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Ensure the map has updated the user location (this depends on your map widget's behavior)
    final mapWidget = tester.widget<MapWidget>(find.byType(MapWidget));
    expect(mapWidget.userLocation, equals(updatedUserLocation));
  });
}
