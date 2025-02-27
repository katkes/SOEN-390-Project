import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:latlong2/latlong.dart';
import 'package:soen_390/services/building_info_api.dart';
import 'package:soen_390/services/interfaces/route_service_interface.dart';
import 'package:http/http.dart' as http;
import 'package:soen_390/widgets/outdoor_map.dart';
import 'dart:typed_data';

// Generate mock classes

@GenerateNiceMocks([
  MockSpec<IRouteService>(),
  MockSpec<http.Client>(),
  MockSpec<BuildingPopUps>(),
  MockSpec<GoogleMapsApiClient>()
])
import 'outdoor_map_test.mocks.dart';

void main() {
  late MockIRouteService mockRouteService;
  late MockClient mockHttpClient;
  late LatLng testLocation;
  late MockGoogleMapsApiClient mockMapsApiClient;
  late MockBuildingPopUps mockBuildingPopUps;

  setUp(() {
    mockRouteService = MockIRouteService();
    mockHttpClient = MockClient();
    testLocation = const LatLng(45.5017, -73.5673);
    mockMapsApiClient =
        MockGoogleMapsApiClient(); // Initialize mockMapsApiClient
    mockBuildingPopUps = MockBuildingPopUps();

    // Mocking route service response
    when(mockRouteService.getRoute(from: anyNamed('from'), to: anyNamed('to')))
        .thenAnswer((_) async => RouteResult(
              distance: 5000.0,
              duration: 600.0,
              routePoints: [
                const LatLng(45.5017, -73.5673),
                const LatLng(45.508, -73.56)
              ],
            ));

    // Better approach: Return a complete 1x1 transparent PNG
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
    when(mockHttpClient.get(any, headers: anyNamed('headers')))
        .thenAnswer((_) async => http.Response.bytes(
              transparentPixelPng,
              200,
              headers: {'content-type': 'image/png'},
            ));

    when(mockHttpClient.readBytes(any, headers: anyNamed('headers')))
        .thenAnswer((_) async => transparentPixelPng);
  });

  testWidgets('MapWidget initializes with provided location',
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
          ),
        ),
      ),
    );

    await tester.pump();
    expect(find.byType(FlutterMap), findsOneWidget);
  });

  testWidgets('MapWidget fetches a route on init', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MapWidget(
            location: testLocation,
            httpClient: mockHttpClient,
            routeService: mockRouteService,
            mapsApiClient: mockMapsApiClient,
            buildingPopUps: mockBuildingPopUps,
          ),
        ),
      ),
    );

    await tester.pump();
    verify(mockRouteService.getRoute(
            from: anyNamed('from'), to: anyNamed('to')))
        .called(1);
  });

  testWidgets('MapWidget calls _fetchRoute when location is updated',
      (WidgetTester tester) async {
    // First, render with initial location
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MapWidget(
            location: testLocation,
            httpClient: mockHttpClient,
            routeService: mockRouteService,
            mapsApiClient: mockMapsApiClient,
            buildingPopUps: mockBuildingPopUps,
          ),
        ),
      ),
    );

    await tester.pump();

    // Verify initial route fetch
    verify(mockRouteService.getRoute(
            from: anyNamed('from'), to: anyNamed('to')))
        .called(1);

    // Reset mock to clearly verify next calls
    clearInteractions(mockRouteService);

    // Update with new location
    final newLocation = const LatLng(45.505, -73.565);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MapWidget(
            location: newLocation,
            httpClient: mockHttpClient,
            routeService: mockRouteService,
            mapsApiClient: mockMapsApiClient,
            buildingPopUps: mockBuildingPopUps,
          ),
        ),
      ),
    );

    await tester.pump();

    // Verify that getRoute was called again
    verify(mockRouteService.getRoute(
            from: anyNamed('from'), to: anyNamed('to')))
        .called(1);
  });

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
            httpClient: mockHttpClient,
            routeService: mockRouteService,
            mapsApiClient: mockMapsApiClient,
            buildingPopUps: mockBuildingPopUps,
          ),
        ),
      ),
    );

    await tester.pump();

    // Verify the widget doesn't crash
    expect(find.byType(FlutterMap), findsOneWidget);
  });

  group('MyPage Tests', () {
    testWidgets('MyPage renders MapWidget with correct props',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: MyPage(
          location: testLocation,
          httpClient: mockHttpClient,
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
  });
}
