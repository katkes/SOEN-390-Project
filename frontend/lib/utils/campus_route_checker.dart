import 'package:latlong2/latlong.dart';
import 'package:soen_390/utils/location_service.dart';

/// A utility class for checking whether a given route connects
/// Concordia University's two main campuses: SGW (Sir George Williams) and Loyola.
///
/// This can be used to apply special logic for inter-campus navigation,
/// such as suggesting shuttle options or alternate travel times.
class CampusRouteChecker {
  /// Service responsible for determining whether a point is within
  /// the bounds of a specific campus.
  final LocationService locationService;

  /// Creates a [CampusRouteChecker] with the required [locationService]
  /// used for spatial checks.
  CampusRouteChecker({required this.locationService});

  /// Determines whether the given route is an inter-campus trip (SGW ↔ LOY).
  ///
  /// Parameters:
  /// - [from]: The starting location as a [LatLng].
  /// - [to]: The destination location as a [LatLng].
  ///
  /// Returns:
  /// - `true` if the route goes between SGW and Loyola campuses in either direction.
  /// - `false` otherwise.
  ///
  /// Example:
  /// ```dart
  /// final isInterCampus = checker.isInterCampus(from: pointA, to: pointB);
  /// if (isInterCampus) {
  ///   // Suggest shuttle route
  /// }
  /// ```
  bool isInterCampus({
    required LatLng from,
    required LatLng to,
  }) {
    final fromSGW = locationService.checkIfPositionIsAtSGW(from);
    final fromLOY = locationService.checkIfPositionIsAtLOY(from);

    final toSGW = locationService.checkIfPositionIsAtSGW(to);
    final toLOY = locationService.checkIfPositionIsAtLOY(to);

    return (fromLOY && toSGW) || (fromSGW && toLOY);
  }
}
