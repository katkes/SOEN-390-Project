import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:latlong2/latlong.dart';
import 'package:soen_390/services/interfaces/route_service_interface.dart';
import 'package:soen_390/utils/location_service.dart';
import 'package:soen_390/services/http_service.dart';
import 'package:soen_390/services/google_route_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

@GenerateMocks([
  http.Client,
  LocationService,
  HttpService,
])
import 'google_route_service_test.mocks.dart';

final mockResponseData = {
  "status": "OK",
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
void main() {
  late MockLocationService mockLocationService;
  late MockHttpService mockHttpService;
  late MockClient mockHttpClient;
  late GoogleRouteService googleRouteService;

  setUp(() {
    mockLocationService = MockLocationService();
    mockHttpService = MockHttpService();
    mockHttpClient = MockClient();
    when(mockHttpService.client).thenReturn(mockHttpClient);
    googleRouteService = GoogleRouteService(
      locationService: mockLocationService,
      httpService: mockHttpService,
      apiKey: 'test_api_key',
    );
  });

  group('GoogleRouteService - getRoute', () {
    test('should return a RouteResult when API call is successful', () async {
      final from = const LatLng(45.5017, -73.5673);
      final to = const LatLng(45.5087, -73.554);
      when(mockHttpClient.get(any)).thenAnswer(
        (_) async => http.Response(jsonEncode(mockResponseData), 200),
      );

      final routeResult = await googleRouteService.getRoute(from: from, to: to);
      expect(routeResult, isNotNull);
      expect(routeResult!.distance, 4492496);
      expect(routeResult.duration, 146645);
    });

    test('should return null when API response has no routes', () async {
      final from = const LatLng(45.5017, -73.5673);
      final to = const LatLng(45.5087, -73.554);

      final mockResponse = {'status': 'OK', 'routes': []};
      when(mockHttpClient.get(any)).thenAnswer(
        (_) async => http.Response(jsonEncode(mockResponse), 200),
      );
      final routeResult = await googleRouteService.getRoute(from: from, to: to);
      expect(routeResult, isNull);
    });
  });

  test('should not start navigation if no route is selected', () async {
    final destination = const LatLng(45.5087, -73.554);
    final mode = 'driving';

    await googleRouteService.startLiveNavigation(
      to: destination,
      mode: mode,
      onUpdate: (_) {},
    );

    verifyNever(mockLocationService.createLocationStream());
  });
  test('should not start navigation if location services are disabled',
      () async {
    final destination = const LatLng(45.5087, -73.554);
    final mode = 'driving';
    when(mockLocationService.isLocationEnabled())
        .thenAnswer((_) async => false);

    await googleRouteService.startLiveNavigation(
      to: destination,
      mode: mode,
      onUpdate: (_) {},
    );

    verifyNever(mockLocationService.createLocationStream());
  });
  test('should start navigation and trigger updates on location change',
      () async {
    final destination = const LatLng(45.5087, -73.554);
    final mode = 'driving';
    final route = RouteResult(
      distance: 1000,
      duration: 600,
      routePoints: [const LatLng(45.5017, -73.5673)],
      steps: [],
    );
    googleRouteService.selectRoute([route], 0);

    when(mockLocationService.isLocationEnabled()).thenAnswer((_) async => true);
    when(mockLocationService.getPositionStream())
        .thenAnswer((_) => Stream.fromIterable([
              Position(
                latitude: 45.5025, // Off-route position
                longitude: -73.5700,
                timestamp: DateTime.now(),
                altitude: 0.0,
                accuracy: 0.0,
                heading: 0.0,
                speed: 0.0,
                speedAccuracy: 0.0,
                altitudeAccuracy: 0.0,
                headingAccuracy: 0.0,
              )
            ]));

    // ✅ Stub the recalculation API call
    when(mockHttpClient.get(
            Uri.parse("https://maps.googleapis.com/maps/api/directions/json?"
                "origin=45.5025,-73.57"
                "&destination=45.5087,-73.554"
                "&mode=driving"
                "&key=test_api_key")))
        .thenAnswer(
            (_) async => http.Response(jsonEncode(mockResponseData), 200));

    bool updateCalled = false;
    await googleRouteService.startLiveNavigation(
      to: destination,
      mode: mode,
      onUpdate: (_) {
        updateCalled = true;
      },
    );

    await Future.delayed(const Duration(milliseconds: 100));

    expect(updateCalled, isTrue);
  });

  group('GoogleRouteService - getRoutes', () {
    test('should return multiple routes for different transport modes',
        () async {
      final from = const LatLng(45.5017, -73.5673);
      final to = const LatLng(45.5087, -73.554);
      when(mockHttpClient.get(any)).thenAnswer(
        (_) async => http.Response(jsonEncode(mockResponseData), 200),
      );

      final routes = await googleRouteService.getRoutes(from: from, to: to);
      expect(routes, isNotEmpty);
      expect(routes.containsKey('driving'), isTrue);
      expect(routes.containsKey('walking'), isTrue);
      expect(routes.containsKey('bicycling'), isTrue);
      expect(routes.containsKey('transit'), isTrue);
    });
  });

  group('GoogleRouteService - selectRoute', () {
    test('should select a valid route', () {
      final route1 = RouteResult(
          distance: 1000, duration: 600, routePoints: [], steps: []);
      final route2 = RouteResult(
          distance: 2000, duration: 1200, routePoints: [], steps: []);

      final selectedRoute = googleRouteService.selectRoute([route1, route2], 1);
      expect(selectedRoute, route2);
    });

    test('should return null if index is out of range', () {
      final route1 = RouteResult(
          distance: 1000, duration: 600, routePoints: [], steps: []);
      final selectedRoute = googleRouteService.selectRoute([route1], 2);
      expect(selectedRoute, isNull);
    });
  });
}
