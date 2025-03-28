import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';
import 'package:soen_390/models/route_result.dart';
import 'package:soen_390/utils/location_service.dart';
import 'package:soen_390/services/live_navigation_service.dart';
import 'package:soen_390/services/google_route_service.dart';

import 'live_navigation_service_test.mocks.dart';

@GenerateMocks([LocationService, GoogleRouteService])
void main() {
  late MockLocationService mockLocationService;
  late MockGoogleRouteService mockRouteService;
  late LiveNavigationService liveNavigationService;

  setUp(() {
    mockLocationService = MockLocationService();
    mockRouteService = MockGoogleRouteService();
    liveNavigationService = LiveNavigationService(
      locationService: mockLocationService,
      routeService: mockRouteService,
    );
  });

  final initialRoute = RouteResult(
    distance: 1000,
    duration: 600,
    routePoints: [const LatLng(45.5017, -73.5673)],
    steps: [],
  );

  final to = const LatLng(45.5087, -73.554);
  final mode = 'driving';

  test('should not start navigation if location services are disabled',
      () async {
    when(mockLocationService.isLocationEnabled())
        .thenAnswer((_) async => false);

    await liveNavigationService.startLiveNavigation(
      to: to,
      mode: mode,
      initialRoute: initialRoute,
      onUpdate: (_) {},
    );

    verifyNever(mockLocationService.createLocationStream());
  });

  test('should call onUpdate if user is on route', () async {
    when(mockLocationService.isLocationEnabled()).thenAnswer((_) async => true);

    when(mockLocationService.getPositionStream()).thenAnswer(
      (_) => Stream.fromIterable([
        Position(
          latitude: 45.5017,
          longitude: -73.5673, // exactly on route point
          timestamp: DateTime.now(),
          altitude: 0,
          accuracy: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        )
      ]),
    );

    when(mockLocationService.createLocationStream()).thenReturn(null);

    bool onUpdateCalled = false;

    await liveNavigationService.startLiveNavigation(
      to: to,
      mode: mode,
      initialRoute: initialRoute,
      onUpdate: (_) => onUpdateCalled = true,
    );

    await Future.delayed(const Duration(milliseconds: 100));
    expect(onUpdateCalled, isTrue);
  });

  test('should recalculate route if user is off route', () async {
    when(mockLocationService.isLocationEnabled()).thenAnswer((_) async => true);

    when(mockLocationService.getPositionStream()).thenAnswer(
      (_) => Stream.fromIterable([
        Position(
          latitude: 45.6000, // far from route
          longitude: -73.7000,
          timestamp: DateTime.now(),
          altitude: 0,
          accuracy: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        )
      ]),
    );

    final recalculatedRoute = RouteResult(
      distance: 1500,
      duration: 800,
      routePoints: [const LatLng(45.6000, -73.7000)],
      steps: [],
    );

    when(mockRouteService.getRoutesFromOptions(any))
        .thenAnswer((_) async => [recalculatedRoute]);
    when(mockLocationService.createLocationStream()).thenReturn(null);

    RouteResult? updatedRoute;

    await liveNavigationService.startLiveNavigation(
      to: to,
      mode: mode,
      initialRoute: initialRoute,
      onUpdate: (route) => updatedRoute = route,
    );

    await Future.delayed(const Duration(milliseconds: 100));
    expect(updatedRoute, isNotNull);
    expect(updatedRoute!.distance, 1500);
  });
}
