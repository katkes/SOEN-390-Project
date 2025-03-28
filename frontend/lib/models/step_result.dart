import 'package:latlong2/latlong.dart';

/// A model representing a single step within a route, such as a walking or driving instruction.
///
/// This class is typically used to describe one segment of a route provided
/// by a navigation API (e.g., Google Directions API). It contains distance,
/// duration, instructions, maneuver type, and start/end locations for the step.
///
/// Example usage:
/// ```dart
/// final step = StepResult(
///   distance: 150,
///   duration: 60,
///   instruction: "Turn left onto Main St.",
///   maneuver: "turn-left",
///   startLocation: LatLng(45.5017, -73.5673),
///   endLocation: LatLng(45.5020, -73.5650),
/// );
/// print(step.instruction);
/// ```
class StepResult {
  /// Distance of this step in meters.
  final double distance;

  /// Duration of this step in seconds.
  final double duration;

  /// Textual navigation instruction (e.g., "Turn right onto Sherbrooke St").
  final String instruction;

  /// The type of maneuver to perform (e.g., "turn-left", "fork-right").
  final String maneuver;

  /// Starting geographical coordinates of this step.
  final LatLng startLocation;

  /// Ending geographical coordinates of this step.
  final LatLng endLocation;

  /// Creates a [StepResult] representing one segment of a route.
  ///
  /// Parameters:
  /// - [distance]: Step length in meters.
  /// - [duration]: Step time in seconds.
  /// - [instruction]: Turn-by-turn instruction.
  /// - [maneuver]: Maneuver type (if provided by the API).
  /// - [startLocation]: Start point of this step.
  /// - [endLocation]: End point of this step.
  StepResult({
    required this.distance,
    required this.duration,
    required this.instruction,
    required this.maneuver,
    required this.startLocation,
    required this.endLocation,
  });
}
