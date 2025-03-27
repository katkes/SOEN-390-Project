import 'package:latlong2/latlong.dart';

/// A data model representing configurable options for querying a route
/// from a directions or navigation API.
///
/// This class encapsulates origin, destination, travel mode,
/// timing preferences, and whether to request alternate routes.
///
/// Example usage:
/// ```dart
/// final options = RouteQueryOptions(
///   from: LatLng(45.5017, -73.5673),
///   to: LatLng(45.4581, -73.6391),
///   mode: 'transit',
///   departureTime: DateTime.now(),
///   alternatives: true,
/// );
/// ```
class RouteQueryOptions {
  /// Starting location of the route.
  final LatLng from;

  /// Destination location of the route.
  final LatLng to;

  /// Mode of travel (e.g., `driving`, `walking`, `bicycling`, `transit`).
  final String mode;

  /// Optional departure time. Used to calculate time-sensitive routes.
  ///
  /// If both [departureTime] and [arrivalTime] are null, the current time is assumed.
  final DateTime? departureTime;

  /// Optional arrival time. Only applicable when [mode] is `transit`.
  ///
  /// Ignored if [departureTime] is provided.
  final DateTime? arrivalTime;

  /// Whether to request alternative route options from the directions API.
  ///
  /// Defaults to `false`.
  final bool alternatives;

  /// Creates a [RouteQueryOptions] object with the given route configuration.
  ///
  /// - [from], [to], and [mode] are required.
  /// - [departureTime] or [arrivalTime] can be optionally provided.
  /// - Set [alternatives] to `true` to request multiple route suggestions.
  RouteQueryOptions({
    required this.from,
    required this.to,
    required this.mode,
    this.departureTime,
    this.arrivalTime,
    this.alternatives = false,
  });
}
