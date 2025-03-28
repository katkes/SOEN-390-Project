import 'package:latlong2/latlong.dart';
import 'package:soen_390/models/step_result.dart';

/// A model that represents the result of a calculated route.
///
/// This class is typically used to store the data returned from
/// routing services such as the Google Directions API after parsing.
///
/// It includes total distance and duration, the full list of route
/// coordinates (polyline), and step-by-step navigation instructions.
///
/// Example usage:
/// ```dart
/// final route = RouteResult(
///   distance: 1200,
///   duration: 600,
///   routePoints: [...],
///   steps: [...],
/// );
/// print("Distance: ${route.distance}m, Duration: ${route.duration}s");
/// ```
class RouteResult {
  /// Total distance of the route in meters.
  final double distance;

  /// Total duration of the route in seconds.
  final double duration;

  /// List of geographical points representing the route path (polyline).
  final List<LatLng> routePoints;

  /// Step-by-step navigation instructions along the route.
  final List<StepResult> steps;

  /// Creates a [RouteResult] with the given route information.
  ///
  /// - [distance]: Total distance of the route in meters.
  /// - [duration]: Estimated total time to complete the route in seconds.
  /// - [routePoints]: Polyline coordinates representing the route.
  /// - [steps]: Individual steps or instructions along the route.
  RouteResult({
    required this.distance,
    required this.duration,
    required this.routePoints,
    required this.steps,
  });
}
