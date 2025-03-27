import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:soen_390/models/route_query_options.dart';
import 'package:soen_390/models/route_result.dart';
import 'package:soen_390/utils/location_service.dart';
import 'package:soen_390/services/google_route_service.dart';

/// A service that manages live turn-by-turn navigation and dynamic rerouting.
///
/// [LiveNavigationService] listens to real-time location updates and checks
/// if the user deviates from the planned route. If a deviation is detected,
/// it recalculates the route and provides the updated path through a callback.
///
/// This service is useful for implementing live navigation in mapping applications.
///
/// Example usage:
/// ```dart
/// liveNavigationService.startLiveNavigation(
///   to: destination,
///   mode: 'walking',
///   initialRoute: plannedRoute,
///   onUpdate: (newRoute) => updateRouteOnMap(newRoute),
/// );
/// ```
class LiveNavigationService {
  /// A service used to get current location and continuous updates.
  final LocationService locationService;

  /// A service used to fetch or recalculate routes using the Google Directions API.
  final GoogleRouteService routeService;

  /// Constructs a [LiveNavigationService] with the required [locationService] and [routeService].
  LiveNavigationService({
    required this.locationService,
    required this.routeService,
  });

  /// Starts monitoring the user's location to perform live navigation.
  ///
  /// If the user deviates from the given [initialRoute], the route will be recalculated
  /// using [routeService] and passed to [onUpdate]. Otherwise, [onUpdate] will be called
  /// periodically with the current route to allow for UI updates or tracking.
  ///
  /// Parameters:
  /// - [to]: The destination coordinates.
  /// - [mode]: The travel mode (e.g., `'walking'`, `'driving'`, `'transit'`).
  /// - [initialRoute]: The original planned route.
  /// - [onUpdate]: A callback that receives updated [RouteResult]s.
  ///
  /// Notes:
  /// - Requires location services to be enabled.
  /// - Uses a proximity threshold of 30 meters to determine route deviation.
  Future<void> startLiveNavigation({
    required LatLng to,
    required String mode,
    required RouteResult initialRoute,
    required Function(RouteResult) onUpdate,
  }) async {
    final isLocationEnabled = await locationService.isLocationEnabled();
    if (!isLocationEnabled) {
      print("ERROR: Location services are disabled. Cannot start navigation.");
      return;
    }

    RouteResult route = initialRoute;
    locationService.createLocationStream();

    locationService.getPositionStream().listen((Position position) async {
      final userLocation = LatLng(position.latitude, position.longitude);

      if (!_isUserOnRoute(userLocation, route.routePoints)) {
        print("User off route! Recalculating...");
        final newOptions = RouteQueryOptions(
          from: userLocation,
          to: to,
          mode: mode,
        );

        final newRoutes = await routeService.getRoutesFromOptions(newOptions);
        if (newRoutes != null && newRoutes.isNotEmpty) {
          route = newRoutes.first;
          onUpdate(route);
        }
      } else {
        onUpdate(route);
      }
    });
  }

  /// Determines whether the user is still on the current route path.
  ///
  /// Uses a fixed [deviationThreshold] (in meters) to check proximity
  /// to any of the [routePoints].
  ///
  /// Returns:
  /// - `true` if the user is within [deviationThreshold] meters of any route point.
  /// - `false` if the user is considered to be off the route.
  bool _isUserOnRoute(LatLng userLocation, List<LatLng> routePoints) {
    const double deviationThreshold = 30;
    return routePoints.any((point) =>
        Geolocator.distanceBetween(
          userLocation.latitude,
          userLocation.longitude,
          point.latitude,
          point.longitude,
        ) <
        deviationThreshold);
  }
}
