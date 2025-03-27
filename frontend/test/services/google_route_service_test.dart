import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:soen_390/models/route_result.dart';
import 'dart:convert';

import 'package:soen_390/services/interfaces/http_client_interface.dart';
import 'package:soen_390/services/google_route_service.dart';
import 'package:soen_390/utils/location_service.dart';
import 'package:soen_390/utils/google_directions_url_builder.dart';
import 'package:soen_390/utils/route_result_parser.dart';

import 'google_route_service_test.mocks.dart';

@GenerateMocks([
  IHttpClient,
  LocationService,
])
void main() {
  late MockIHttpClient mockHttpClient;
  late MockLocationService mockLocationService;
  late GoogleRouteService googleRouteService;

  const apiKey = 'test_api_key';

  final mockResponseData = {
    "status": "OK",
    "routes": [
      {
        "legs": [
          {
            "distance": {"value": 4492496},
            "duration": {"value": 146645},
            "start_location": {"lat": 40.7128, "lng": -74.006},
            "end_location": {"lat": 34.0522, "lng": -118.2437},
            "steps": [
              {
                "distance": {"value": 82},
                "duration": {"value": 17},
                "start_location": {"lat": 40.7128, "lng": -74.006},
                "end_location": {"lat": 40.7131, "lng": -74.0072},
                "html_instructions": "Head southwest toward Murray St",
                "maneuver": "turn-right",
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

  setUp(() {
    mockHttpClient = MockIHttpClient();
    mockLocationService = MockLocationService();
    googleRouteService = GoogleRouteService(
      locationService: mockLocationService,
      httpClient: mockHttpClient,
      apiKey: apiKey,
      urlBuilder: GoogleDirectionsUrlBuilder(apiKey: apiKey),
      parser: RouteResultParser(),
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

      final emptyRoutes = {'status': 'OK', 'routes': []};

      when(mockHttpClient.get(any)).thenAnswer(
        (_) async => http.Response(jsonEncode(emptyRoutes), 200),
      );

      final result = await googleRouteService.getRoute(from: from, to: to);
      expect(result, isNull);
    });
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
      expect(routes.length, greaterThanOrEqualTo(4));
      expect(routes.containsKey('driving'), isTrue);
      expect(routes.containsKey('walking'), isTrue);
      expect(routes.containsKey('bicycling'), isTrue);
      expect(routes.containsKey('transit'), isTrue);
    });
  });

  group('GoogleRouteService - selectRoute', () {
    test('should select a valid route', () {
      final routes = [
        RouteResult(distance: 1000, duration: 600, routePoints: [], steps: []),
        RouteResult(distance: 2000, duration: 1200, routePoints: [], steps: [])
      ];

      final selected = googleRouteService.selectRoute(routes, 1);
      expect(selected, routes[1]);
    });

    test('should return null if index is out of range', () {
      final routes = [
        RouteResult(distance: 1000, duration: 600, routePoints: [], steps: [])
      ];

      final selected = googleRouteService.selectRoute(routes, 5);
      expect(selected, isNull);
    });
  });
}
