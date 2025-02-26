import 'package:latlong2/latlong.dart';

/// An abstract class that defines the contract for a routing service.
///
/// This abstraction enables easy switching between different routing providers,
/// such as Google Maps, Mapbox, or OSRM, without modifying existing logic.
abstract class IRouteService {
  /// Retrieves a route between the specified [from] and [to] locations.
  ///
  /// Returns a [RouteResult] containing distance, duration, and route points
  /// or `null` if no route could be determined.
  Future<RouteResult?> getRoute({
    required LatLng from,
    required LatLng to,
  });
}

/// Represents the result of a route calculation.
class RouteResult {
  /// The total distance of the route in meters.
  final double distance;

  /// The estimated duration of the route in seconds.
  final double duration;

  /// A list of geographic points representing the route path.
  final List<LatLng> routePoints;

  /// Creates a new [RouteResult] with the given [distance], [duration], and [routePoints].
  RouteResult({
    required this.distance,
    required this.duration,
    required this.routePoints,
  });
}
