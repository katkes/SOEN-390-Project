import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:latlong2/latlong.dart';
import 'package:osrm/osrm.dart'; // Ensure this import includes OsrmRoute, OsrmGeometry, etc.
import 'package:soen_390/services/osrm_route_service.dart';

// Generate a mock class for Osrm
@GenerateMocks([Osrm])
import 'osrm_route_service_test.mocks.dart';

void main() {
  late MockOsrm mockOsrm;
  late OsrmRouteService service;

  setUp(() {
    mockOsrm = MockOsrm();
    service = OsrmRouteService(mockOsrm);
  });

  test('getRoute should return a valid route', () async {
    // Arrange
    const from = LatLng(45.5017, -73.5673);
    const to = LatLng(45.5087, -73.554);

    final mockOsrmResponse = RouteResponse(
      code: OsrmResponseCode.ok,
      routes: [
        OsrmRoute(
          distance: 1000.0,
          duration: 600.0,
          geometry: OsrmGeometry(
            lineString: OsrmLineString(
              coordinates: [
                (-73.5673, 45.5017), // Use the correct tuple notation
                (-73.554, 45.5087),
              ],
            ),
          ),
        ),
      ],
    );

    when(mockOsrm.route(any)).thenAnswer((_) async => mockOsrmResponse);

    // Act
    final result = await service.getRoute(from: from, to: to);
    print("Test execution reached assertion phase");

    // Assert
    expect(result, isNotNull);
    expect(result!.distance, equals(1000.0));
    expect(result.duration, equals(600.0));
    expect(result.routePoints.length, equals(2));
    expect(result.routePoints.first.latitude, equals(from.latitude));
    expect(result.routePoints.first.longitude, equals(from.longitude));
    expect(result.routePoints.last.latitude, equals(to.latitude));
    expect(result.routePoints.last.longitude, equals(to.longitude));
    print("Test execution finished successfully");
  });

  test('getRoute should return default route when no routes are found',
      () async {
    // Arrange
    const from = LatLng(45.5017, -73.5673);
    const to = LatLng(45.5087, -73.554);

    final emptyRouteResponse = RouteResponse(
      code: OsrmResponseCode.ok,
      routes: [],
    );

    when(mockOsrm.route(any)).thenAnswer((_) async => emptyRouteResponse);

    // Act
    final result = await service.getRoute(from: from, to: to);
    print("Test execution reached assertion phase");
    // Assert
    expect(result, isNotNull);
    expect(result!.distance, equals(0.0));
    expect(result.duration, equals(0.0));
    expect(result.routePoints, isEmpty);
    print("Test execution finished successfully");
  });

  test('getRoute should return null when an exception occurs', () async {
    // Arrange
    const from = LatLng(45.5017, -73.5673);
    const to = LatLng(45.5087, -73.554);

    when(mockOsrm.route(any)).thenThrow(Exception('OSRM Error'));

    // Act
    final result = await service.getRoute(from: from, to: to);
    print("Test execution reached assertion phase");
    // Assert
    expect(result, isNull);
    print("Test execution finished successfully");
  });
}
