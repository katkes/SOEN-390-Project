import 'package:latlong2/latlong.dart';
import 'package:soen_390/utils/location_service.dart';

/// A utility class for identifying and interacting with Concordia University's campuses.
///
/// [CampusLocator] helps determine the closest campus to the user's current location
/// and provides coordinates for known campuses (SGW and Loyola).
///
/// It relies on [LocationService] to obtain the user's location and compute proximity.
class CampusLocator {
  /// Identifier key for the Sir George Williams (SGW) campus.
  static const String sgw = "SGW";

  /// Identifier key for the Loyola campus.
  static const String loyola = "Loyola";

  /// A map of campus keys to their corresponding geographic coordinates.
  static const Map<String, LatLng> campusLocations = {
    sgw: LatLng(45.497856, -73.579588),
    loyola: LatLng(45.4581, -73.6391),
  };

  /// Service used to fetch the user's current location and perform distance calculations.
  final LocationService locationService;

  /// Creates a [CampusLocator] instance with a required [locationService].
  CampusLocator({required this.locationService});

  /// Determines the closest campus (SGW or Loyola) to the user's current location.
  ///
  /// Returns:
  /// - `"SGW"` if SGW is closest or if location retrieval fails.
  /// - `"Loyola"` if Loyola is closer.
  ///
  /// Throws:
  /// - Returns a fallback (`"SGW"`) on any exception during location retrieval.
  Future<String> findClosestCampus() async {
    try {
      final currentLocation = await locationService.getCurrentLocation();
      final closest = LocationService.getClosestCampus(currentLocation);
      return closest == "LOY" ? loyola : sgw;
    } catch (e) {
      print("Error finding closest campus: $e");
      return sgw; // Fallback
    }
  }

  /// Returns the [LatLng] coordinates of the campus corresponding to [campusKey].
  ///
  /// Throws:
  /// - [StateError] if the [campusKey] is not found in [campusLocations].
  LatLng getCoordinates(String campusKey) => campusLocations[campusKey]!;
}
