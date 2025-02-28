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


class StepResult {
  final double distance;
  final double duration;
  final String instruction;
  final String maneuver;
  final LatLng startLocation;
  final LatLng endLocation;

  StepResult({
    required this.distance,
    required this.duration,
    required this.instruction,
    required this.maneuver,
    required this.startLocation,
    required this.endLocation,
  });
}

class RouteResult {
  final double distance;
  final double duration;
  final List<LatLng> routePoints;
  final List<StepResult> steps; // ✅ Add this

  RouteResult({
    required this.distance,
    required this.duration,
    required this.routePoints,
    required this.steps, // ✅ Add this
  });
}

