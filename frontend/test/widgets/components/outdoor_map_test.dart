import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:latlong2/latlong.dart';
import 'package:soen_390/services/interfaces/route_service_interface.dart';
import 'package:http/http.dart' as http;
import 'package:soen_390/widgets/outdoor_map.dart';
import 'dart:typed_data';

// Generate mock classes
@GenerateNiceMocks([MockSpec<IRouteService>(), MockSpec<http.Client>()])
import 'outdoor_map_test.mocks.dart';

void main() {
  late MockIRouteService mockRouteService;
  late MockClient mockHttpClient;
  late LatLng testLocation;

  setUp(() {
    mockRouteService = MockIRouteService();
    mockHttpClient = MockClient();
    testLocation = LatLng(45.5017, -73.5673);

    // Mocking route service response
    when(mockRouteService.getRoute(from: anyNamed('from'), to: anyNamed('to')))
        .thenAnswer((_) async => RouteResult(
              distance: 5000.0,
              duration: 600.0,
              routePoints: [LatLng(45.5017, -73.5673), LatLng(45.508, -73.56)],
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
    final newLocation = LatLng(45.505, -73.565);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MapWidget(
            location: newLocation,
            httpClient: mockHttpClient,
            routeService: mockRouteService,
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

  group('MapWidget Tap Handler Tests', () {
    testWidgets('_handleMapTap updates from location on first tap',
        (WidgetTester tester) async {
      // Create widget
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: MapWidget(
            location: testLocation,
            httpClient: mockHttpClient,
            routeService: mockRouteService,
          ),
        ),
      ));

      await tester.pumpAndSettle();
      clearInteractions(mockRouteService);

      // Get the FlutterMap widget and its gesture detector
      final mapFinder = find.byType(FlutterMap);

      // Simulate tap using onTap callback directly
      final mapWidget = tester.widget<FlutterMap>(mapFinder);
      final mapOptions = mapWidget.options;

      // Call onTap directly to avoid timer issues
      mapOptions.onTap?.call(
        TapPosition(
          tester.getCenter(mapFinder),
          tester.getCenter(mapFinder),
        ),
        LatLng(45.5020, -73.5675),
      );

      // Pump the widget to process the tap
      await tester.pump();
      await tester.pumpAndSettle();

      // Verify two markers are present
      expect(find.byIcon(Icons.location_pin), findsNWidgets(2));

      // Verify route service was called exactly once after setup
      verify(mockRouteService.getRoute(
        from: anyNamed('from'),
        to: anyNamed('to'),
      )).called(1);
    });

    testWidgets('_handleMapTap updates to location on second tap',
        (WidgetTester tester) async {
      // Create widget and wait for initial setup
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: MapWidget(
            location: testLocation,
            httpClient: mockHttpClient,
            routeService: mockRouteService,
          ),
        ),
      ));

      await tester.pump();

      // Clear interactions after initial setup
      clearInteractions(mockRouteService);

      // First tap
      final firstGesture = await tester.createGesture();
      await firstGesture.down(tester.getCenter(find.byType(FlutterMap)));
      await firstGesture.up();
      await tester.pump();
      await tester.pumpAndSettle();

      // Second tap
      final secondGesture = await tester.createGesture();
      await secondGesture.down(
          tester.getCenter(find.byType(FlutterMap)) + const Offset(50, 50));
      await secondGesture.up();
      await tester.pump();
      await tester.pumpAndSettle();

      // Verify two markers are present
      expect(find.byIcon(Icons.location_pin), findsNWidgets(2));

      // Verify route service was called exactly twice after initial setup
      verify(mockRouteService.getRoute(
        from: anyNamed('from'),
        to: anyNamed('to'),
      )).called(2);
    });

    testWidgets('_handleMapTap alternates between from and to locations',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: MapWidget(
            location: testLocation,
            httpClient: mockHttpClient,
            routeService: mockRouteService,
          ),
        ),
      ));

      await tester.pump();
      clearInteractions(mockRouteService);

      // Should always have exactly 2 markers (from and to)
      expect(find.byIcon(Icons.location_pin), findsNWidgets(2));

      // Helper function to verify marker positions
      Future<void> verifyMarkerPositions(Offset tapOffset) async {
        final gesture = await tester.createGesture();
        await gesture
            .down(tester.getCenter(find.byType(FlutterMap)) + tapOffset);
        await gesture.up();
        await tester.pump();
        await tester.pumpAndSettle();

        // Still should have 2 markers
        expect(find.byIcon(Icons.location_pin), findsNWidgets(2));

        // Verify route was recalculated
        verify(mockRouteService.getRoute(
          from: anyNamed('from'),
          to: anyNamed('to'),
        )).called(1);

        clearInteractions(mockRouteService);
      }

      // Test three different tap positions
      await verifyMarkerPositions(const Offset(50, 50));
      await verifyMarkerPositions(const Offset(100, 100));
      await verifyMarkerPositions(const Offset(150, 150));
    });
  });
}
