import 'package:latlong2/latlong.dart';
import 'package:soen_390/models/route_query_options.dart';

/// A utility class for constructing request URLs to the Google Directions API.
///
/// The [GoogleDirectionsUrlBuilder] helps build properly formatted request URLs
/// with configurable parameters like origin, destination, mode of transportation,
/// departure/arrival times, and whether to include alternative routes.
///
/// Example usage:
/// ```dart
/// final builder = GoogleDirectionsUrlBuilder(apiKey: 'YOUR_API_KEY');
/// final url = builder.buildRequestUrl(
///   from: LatLng(45.5017, -73.5673),
///   to: LatLng(45.4581, -73.6391),
///   mode: 'transit',
///   departureTime: DateTime.now(),
/// );
/// ```
class GoogleDirectionsUrlBuilder {
  /// The API key used to authenticate requests to the Google Directions API.
  final String apiKey;

  /// Creates a [GoogleDirectionsUrlBuilder] with the given [apiKey].
  GoogleDirectionsUrlBuilder({required this.apiKey});

  /// Constructs a complete URL for a Google Directions API request.
  ///
  /// Parameters:
  /// - [from]: The origin location as a [LatLng].
  /// - [to]: The destination location as a [LatLng].
  /// - [mode]: The travel mode (`driving`, `walking`, `bicycling`, or `transit`).
  /// - [departureTime]: (Optional) When the user intends to depart.
  ///   Ignored for `walking` mode. Supersedes [arrivalTime] unless null.
  /// - [arrivalTime]: (Optional) When the user intends to arrive (used only with `transit` mode).
  /// - [alternatives]: Whether to return multiple route options. Defaults to `false`.
  ///
  /// Returns:
  /// - A fully formatted URL string for making a Google Directions API call.
  ///
  /// Notes:
  /// - If [departureTime] is provided (and mode is not walking), it's used.
  /// - If [departureTime] is null and [arrivalTime] is provided (and mode is `transit`), it's used instead.
  String buildRequestUrl(RouteQueryOptions options) {
    String url = "https://maps.googleapis.com/maps/api/directions/json?"
        "origin=${options.from.latitude},${options.from.longitude}"
        "&destination=${options.to.latitude},${options.to.longitude}"
        "&mode=${options.mode}"
        "&key=$apiKey";

    if (options.alternatives) {
      url += "&alternatives=true";
    }

    if (options.departureTime != null && options.mode != "walking") {
      url +=
          "&departure_time=${options.departureTime!.millisecondsSinceEpoch ~/ 1000}";
    } else if (options.arrivalTime != null && options.mode == "transit") {
      url +=
          "&arrival_time=${options.arrivalTime!.millisecondsSinceEpoch ~/ 1000}";
    }

    return url;
  }
}
