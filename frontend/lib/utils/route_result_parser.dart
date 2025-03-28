import 'package:latlong2/latlong.dart';
import 'package:soen_390/models/route_result.dart';
import 'package:soen_390/models/step_result.dart';

/// A utility class responsible for parsing route data from the
/// Google Directions API response into structured [RouteResult] and [StepResult] objects.
///
/// This class extracts:
/// - Overall route distance and duration
/// - Route polyline (as a list of [LatLng] points)
/// - Step-by-step navigation instructions
///
/// Example usage:
/// ```dart
/// final parser = RouteResultParser();
/// final results = parser.parseRouteResults(apiResponseJson);
/// ```
class RouteResultParser {
  /// Parses a JSON response from the Google Directions API into a list of [RouteResult] objects.
  ///
  /// Parameters:
  /// - [data]: The raw JSON response from the Directions API.
  ///
  /// Returns:
  /// - A `List<RouteResult>` representing each leg of each route in the response.
  List<RouteResult> parseRouteResults(Map<String, dynamic> data) {
    List<RouteResult> results = [];

    for (var route in data['routes']) {
      for (var leg in route['legs']) {
        final distance = leg['distance']['value'].toDouble();
        final duration = leg['duration']['value'].toDouble();
        final polylinePoints = route.containsKey('overview_polyline')
            ? _decodePolyline(route['overview_polyline']['points'])
            : <LatLng>[];

        List<StepResult> steps = _extractSteps(leg['steps']);

        results.add(RouteResult(
          distance: distance,
          duration: duration,
          routePoints: polylinePoints,
          steps: steps,
        ));
      }
    }

    return results;
  }

  /// Extracts step-by-step navigation instructions from the leg's steps data.
  ///
  /// Parameters:
  /// - [stepsData]: A list of step objects from the API response.
  ///
  /// Returns:
  /// - A list of [StepResult] objects containing detailed step info.
  List<StepResult> _extractSteps(List<dynamic> stepsData) {
    return stepsData.map<StepResult>((step) {
      return StepResult(
        distance: step['distance']['value'].toDouble(),
        duration: step['duration']['value'].toDouble(),
        instruction: step['html_instructions'] ?? "No instruction available",
        maneuver: step.containsKey('maneuver') ? step['maneuver'] : "unknown",
        startLocation: LatLng(
          step['start_location']['lat'],
          step['start_location']['lng'],
        ),
        endLocation: LatLng(
          step['end_location']['lat'],
          step['end_location']['lng'],
        ),
      );
    }).toList();
  }

  /// Decodes a Google-encoded polyline string into a list of [LatLng] points.
  ///
  /// Parameters:
  /// - [encoded]: The encoded polyline string from the `overview_polyline.points` field.
  ///
  /// Returns:
  /// - A list of [LatLng] representing the path of the route.
  ///
  /// Reference: https://developers.google.com/maps/documentation/utilities/polylinealgorithm
  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    if (encoded.isEmpty) return points;

    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }
}
