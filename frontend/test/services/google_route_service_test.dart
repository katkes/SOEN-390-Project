import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:soen_390/utils/location_service.dart';
import 'package:soen_390/services/http_service.dart';
import 'package:soen_390/services/google_route_service.dart';
import 'package:soen_390/services/interfaces/route_service_interface.dart';

// Generate mock classes
@GenerateMocks([HttpService, LocationService, http.Client])
import 'google_route_service_test.mocks.dart';

void main() {
  late GoogleRouteService routeService;
  late MockHttpService mockHttpService;
  late MockLocationService mockLocationService;
  late MockClient mockHttpClient;

  setUp(() {
    mockHttpService = MockHttpService();
    mockLocationService = MockLocationService();
    mockHttpClient = MockClient();

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
}
