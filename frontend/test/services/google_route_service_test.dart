import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:soen_390/utils/location_service.dart';
import 'package:soen_390/services/http_service.dart';
import 'package:soen_390/services/google_route_service.dart';
import 'package:soen_390/services/interfaces/route_service_interface.dart';
import 'package:geolocator/geolocator.dart' as geo;

// Generate mock classes
@GenerateMocks([HttpService, LocationService, http.Client])
import 'google_route_service_test.mocks.dart';
geo.Position get mockPosition => geo.Position(
      latitude: 45.5017,
      longitude: -73.5673,
      timestamp: DateTime.now(),
      altitude: 0.0,
      altitudeAccuracy: 0.0,
      accuracy: 0.0,
      heading: 0.0,
      headingAccuracy: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0,
    );

/// Mock implementation of [geo.GeolocatorPlatform] for testing.
///
/// This class overrides methods from [geo.GeolocatorPlatform] to provide
/// controlled behavior for testing the [LocationService] class.
class MockGeolocatorPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements geo.GeolocatorPlatform {
  geo.LocationPermission _permission = geo.LocationPermission.whileInUse;
  bool _locationServicesEnabled = true;

  /// Sets the mock location permission for testing.
  void setLocationPermission(geo.LocationPermission permission) {
    _permission = permission;
  }

  /// Sets whether location services are enabled for testing.
  void setLocationServiceEnabled(bool enabled) {
    _locationServicesEnabled = enabled;
  }

  @override
  Future<geo.LocationPermission> checkPermission() => Future.value(_permission);

  @override
  Future<geo.LocationPermission> requestPermission() =>
      Future.value(_permission);

  @override
  Future<bool> isLocationServiceEnabled() =>
      Future.value(_locationServicesEnabled);

  @override
  Future<geo.Position?> getLastKnownPosition(
      {bool forceLocationManager = false}) async {
    return Future.value(mockPosition);
  }

  @override
  Future<geo.Position> getCurrentPosition(
          {geo.LocationSettings? locationSettings}) =>
      Future.value(mockPosition);

  @override
  Stream<geo.Position> getPositionStream(
      {geo.LocationSettings? locationSettings}) {
    return Stream.fromIterable([mockPosition]);
  }

  @override
  Future<bool> openAppSettings() => Future.value(true);

  @override
  Future<bool> openLocationSettings() => Future.value(true);
}
void main() {
  late GoogleRouteService routeService;
  late MockHttpService mockHttpService;
  late MockLocationService mockLocationService;
  late MockClient mockHttpClient;
  late MockGeolocatorPlatform mockGeolocator;

  setUp(() {
    mockHttpService = MockHttpService();
    mockLocationService = MockLocationService();
    mockHttpClient = MockClient();
    mockGeolocator = MockGeolocatorPlatform();

    // ✅ Ensure `mockLocationService.geolocator` returns `mockGeolocator`
    when(mockLocationService.geolocator).thenReturn(mockGeolocator);

    // Mock API response data
    final mockResponseData = {
      "status": "OK", // ✅ Add this field to fix the issue
      "routes": [
        {
          "legs": [
            {
              "distance": {"text": "2,792 mi", "value": 4492496},
              "duration": {"text": "1 day 17 hours", "value": 146645},
              "start_location": {"lat": 40.7128, "lng": -74.006},
              "end_location": {"lat": 34.0522, "lng": -118.2437},
              "steps": [
                {
                  "distance": {"text": "269 ft", "value": 82},
                  "duration": {"text": "1 min", "value": 17},
                  "start_location": {"lat": 40.7128, "lng": -74.006},
                  "end_location": {"lat": 40.7131, "lng": -74.0072},
                  "html_instructions":
                      "Head <b>southwest</b> toward <b>Murray St</b>",
                  "maneuver": "turn-right",
                  "polyline": {
                    "points": "wunwFtkubMB?@@FD@@?B?B?BABCFGNa@~@EJA@A@QL"
                  },
                  "travel_mode": "DRIVING"
                }
              ]
            }
          ],
          "overview_polyline": {
            "points": "wunwFtkubMB?@@FD@@?B?B?BABCFGNa@~@EJA@A@QL"
          }
        }
      ]
    };

    // Ensure the HttpService uses a mocked Client
    when(mockHttpService.client).thenReturn(mockHttpClient);

    routeService = GoogleRouteService(
      locationService: mockLocationService,
      httpService: mockHttpService,
      apiKey: 'test_api_key',
    );

    // Mock HTTP request to return the fake Google Maps API response
    when(mockHttpClient.get(any)).thenAnswer((Invocation invocation) async {
      final url = invocation.positionalArguments.first.toString();

      // Define different mock responses based on transport mode
      final mockResponses = {
        'driving': mockResponseData,
        'walking': mockResponseData,
        'bicycling': mockResponseData,
        'transit': mockResponseData,
      };

      // Identify the mode in URL and return the correct response
      for (var mode in mockResponses.keys) {
        if (url.contains("mode=$mode")) {
          return http.Response(jsonEncode(mockResponses[mode]), 200);
        }
      }

      // Default: Return empty if mode is unrecognized
      return http.Response(jsonEncode({'routes': []}), 200);
    });
  });


  group('GoogleRouteService Tests', () {
    test('Should throw exception when API key is missing', () {
      expect(
        () => GoogleRouteService(
          locationService: mockLocationService,
          httpService: mockHttpService,
          apiKey: '',
        ),
        throwsException,
      );
    });

    test('Should fetch and parse a route successfully', () async {
      final result = await routeService.getRoute(
        from: const LatLng(40.7128, -74.0060),
        to: const LatLng(34.0522, -118.2437),
      );

      expect(result, isNotNull);
      expect(result!.distance, equals(4492496.0));
      expect(result.duration, equals(146645.0));
      expect(result.steps, isNotNull); // ✅ Ensure steps exist

      final firstStep = result.steps.first;
      expect(firstStep.distance, equals(82.0));
      expect(firstStep.duration, equals(17.0));
      expect(firstStep.instruction, contains("Head <b>southwest</b>"));
      expect(firstStep.maneuver, equals("turn-right"));

      verify(mockHttpClient.get(any))
          .called(greaterThan(0)); // ✅ Ensures mock API was used
    });

    test('Should return null when no routes found', () async {
      final mockEmptyResponse = {'routes': []};

      when(mockHttpClient.get(any)).thenAnswer(
        (_) async => http.Response(jsonEncode(mockEmptyResponse), 200),
      );

      final result = await routeService.getRoute(
        from: const LatLng(45.5017, -73.5673),
        to: const LatLng(45.5038, -73.554),
      );

      expect(result, isNull);
    });

    test('Should get multiple routes for different transport modes', () async {
      final routes = await routeService.getRoutes(
        from: const LatLng(45.5017, -73.5673),
        to: const LatLng(45.5038, -73.554),
      );

      expect(
          routes.isNotEmpty, isTrue); // ✅ Ensure at least one mode returns data
      expect(routes.keys,
          containsAll(['driving', 'walking', 'bicycling', 'transit']));
    });

    test('Should select a route correctly', () {
      final routes = [
        RouteResult(distance: 1000, duration: 600, routePoints: [], steps: []),
        RouteResult(distance: 2000, duration: 900, routePoints: [], steps: [])
      ];

      final selected = routeService.selectRoute(routes, 0);

      expect(selected, isNotNull);
      expect(selected?.distance, equals(1000));
    });

    test('Should return null for an invalid route selection', () {
      final routes = [
        RouteResult(distance: 1000, duration: 600, routePoints: [], steps: [])
      ];

      final selected = routeService.selectRoute(routes, 1);

      expect(selected, isNull);
    });

    test('Should select a route correctly', () {
      final routes = [
        RouteResult(distance: 1000, duration: 600, routePoints: [], steps: []),
        RouteResult(distance: 2000, duration: 900, routePoints: [], steps: [])
      ];

      final selected = routeService.selectRoute(routes, 0);

      expect(selected, isNotNull);
      expect(selected?.distance, equals(1000));
    });

    test('Should return null for an invalid route selection', () {
      final routes = [
        RouteResult(distance: 1000, duration: 600, routePoints: [], steps: [])
      ];

      final selected = routeService.selectRoute(routes, 1);

      expect(selected, isNull);
    });
  });


  test('Should start live navigation with selected route', () async {
    // Setup test data
    final routes = [
      RouteResult(distance: 1000, duration: 600, routePoints: [], steps: [])
    ];
    routeService.selectRoute(routes, 0);

    // Mock location stream
    mockGeolocator.setLocationPermission(geo.LocationPermission.whileInUse);
    mockGeolocator.setLocationServiceEnabled(true);

    // Create a stream controller to emit positions
    final positionController = StreamController<geo.Position>();
    when(mockLocationService.geolocator
            .getPositionStream(locationSettings: anyNamed('locationSettings')))
        .thenAnswer((_) => positionController.stream);

    bool onUpdateCalled = false;
    await routeService.startLiveNavigation(
        to: const LatLng(45.5038, -73.554),
        mode: 'driving',
        onUpdate: (route) {
          onUpdateCalled = true;
          expect(route, isNotNull);
        });

    // Emit a position to trigger navigation update
    mockGeolocator.getCurrentPosition().then((position) {
      positionController.add(position);
    });

    // Wait for stream events to process
    await Future.delayed(const Duration(milliseconds: 100));

    expect(onUpdateCalled, isTrue);
    verify(mockLocationService.createLocationStream()).called(1);

    // Clean up
    await positionController.close();
  });
  test('Should not start navigation if location services are disabled',
      () async {
    // ✅ Ensure `mockLocationService.geolocator` returns `mockGeolocator`
    when(mockLocationService.geolocator).thenReturn(mockGeolocator);

    // ✅ Stub `isLocationServiceEnabled()` BEFORE calling `startLiveNavigation()`
    when(mockGeolocator.isLocationServiceEnabled())
        .thenAnswer((_) async => false);

    bool onUpdateCalled = false;

    await routeService.startLiveNavigation(
      to: const LatLng(45.5038, -73.554),
      mode: 'driving',
      onUpdate: (route) {
        onUpdateCalled = true;
      },
    );

    // ✅ Ensure the method was actually called
    verify(mockGeolocator.isLocationServiceEnabled()).called(1);

    // ✅ Ensure `onUpdate` was NOT triggered
    expect(onUpdateCalled, isFalse);

    // ✅ Ensure location stream was NEVER created
    verifyNever(mockLocationService.createLocationStream());
  });




}

