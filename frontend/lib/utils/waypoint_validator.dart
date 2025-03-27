import 'package:flutter/material.dart';

/// A utility class for validating waypoint input before route generation.
///
/// Typically used to ensure that the user has selected at least the
/// required number of waypoints (e.g., a start and a destination)
/// before proceeding with navigation or directions.
///
/// Shows a [SnackBar] message in the given [BuildContext] if the validation fails.
class WaypointValidator {
  /// Validates whether the provided [waypoints] list contains at least [minRoutes] entries.
  ///
  /// Parameters:
  /// - [context]: Used to show an error message via [ScaffoldMessenger] if validation fails.
  /// - [waypoints]: The list of user-entered or selected waypoints.
  /// - [minRoutes]: Minimum number of waypoints required (usually 2 for start and destination).
  ///
  /// Returns:
  /// - `true` if the number of waypoints is valid (≥ [minRoutes]).
  /// - `false` if not, and shows a snackbar warning the user.
  ///
  /// Example:
  /// ```dart
  /// final isValid = WaypointValidator().validate(context, itinerary, 2);
  /// if (isValid) {
  ///   // Proceed with route generation
  /// }
  /// ```
  bool validate(BuildContext context, List<String> waypoints, int minRoutes) {
    if (waypoints.length < minRoutes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("You must have at least a start and destination."),
        ),
      );
      return false;
    }
    return true;
  }
}
