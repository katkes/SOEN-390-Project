import 'package:latlong2/latlong.dart';
import 'package:osrm/osrm.dart';
import 'interfaces/route_service_interface.dart';

/// Implementation of [IRouteService] using the Open Source Routing Machine (OSRM).
///
/// This service provides routing capabilities by interfacing with an OSRM backend,
/// allowing route calculations based on different transportation profiles.
class OsrmRouteService implements IRouteService {
  /// The OSRM client used to interact with the OSRM API.
  final Osrm osrmClient;

  /// Creates an instance of [OsrmRouteService] with the given [osrmClient].
  OsrmRouteService(this.osrmClient);

  @override
  /// Fetches a route between the specified [from] and [to] locations using OSRM.
  ///
  /// Returns a [RouteResult] containing the computed route distance, duration,
  /// and a list of geographical points representing the route.
  /// If no route is found, a default [RouteResult] is returned.
  Future<RouteResult> getRoute({
    required LatLng from,
    required LatLng to,
  }) async {
    try {
      final options = RouteRequest(
        coordinates: [
          (from.longitude, from.latitude),
          (to.longitude, to.latitude),
        ],
        profile: OsrmRequestProfile.foot, // Defaults to walking profile
        overview: OsrmOverview.full,
      );

      final route = await osrmClient.route(options);

      // Ensure at least one route is found
      if (route.routes.isEmpty) {
        return RouteResult(distance: 0.0, duration: 0.0, routePoints: []);
      }

      final firstRoute = route.routes.first;
      final distance = firstRoute.distance?.toDouble() ?? 0.0;
      final duration = firstRoute.duration?.toDouble() ?? 0.0;

      // Convert route geometry into a list of LatLng points
      final routePoints =
          _convertCoordinates(firstRoute.geometry?.lineString?.coordinates);

      return RouteResult(
        distance: distance,
        duration: duration,
        routePoints: routePoints,
      );
    } catch (e) {
      print("Error fetching route: $e");
      return RouteResult(distance: 0.0, duration: 0.0, routePoints: []);
    }
  }

  /// Converts a list of OSRM [Coordinate] objects into a list of [LatLng] points.
  ///
  /// This method ensures better readability and reusability when processing route geometry.
  List<LatLng> _convertCoordinates(List<Coordinate>? coordinates) {
    return coordinates?.map((e) {
          final loc = e.toLocation();
          return LatLng(loc.lat, loc.lng);
        }).toList() ??
        [];
  }
}
