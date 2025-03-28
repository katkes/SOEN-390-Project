/// A utility class that manages an ordered list of locations for a route or trip itinerary.
///
/// This class is used to keep track of a start point, destination, and optional waypoints
/// in between. It provides methods to set or update the start and destination locations,
/// remove entries, and check if the itinerary is valid for routing.
///
/// Example usage:
/// ```dart
/// final manager = ItineraryManager(itinerary: []);
/// manager.setStart("Home");
/// manager.setDestination("Office");
/// print(manager.getWaypoints()); // ["Home", "Office"]
/// ```
class ItineraryManager {
  /// Index of the start location in the itinerary list.
  static const int startIndex = 0;

  /// Index of the destination location in the itinerary list.
  static const int destinationIndex = 1;

  /// Minimum number of waypoints required for a valid route (start + destination).
  static const int minimumWaypoints = 2;

  /// The internal list of itinerary locations.
  final List<String> _itinerary;

  /// The default value for the start location if none is set.
  final String defaultStart;

  /// Creates an [ItineraryManager] with an initial [itinerary] list and an optional [defaultStart].
  ///
  /// If the provided itinerary is empty, it automatically adds the [defaultStart] value.
  ItineraryManager({
    required List<String> itinerary,
    this.defaultStart = 'Your Location',
  }) : _itinerary = itinerary {
    if (_itinerary.isEmpty) {
      _itinerary.add(defaultStart);
    }
  }

  /// Sets or replaces the start location at index `0`.
  ///
  /// If the itinerary is empty, it simply adds the location.
  /// If a start already exists, it replaces it and shifts the previous start (if needed).
  void setStart(String location) {
    if (_itinerary.isEmpty) {
      _itinerary.add(location);
    } else {
      _itinerary.insert(startIndex, location);
      if (_itinerary.length > 1) {
        _itinerary.removeAt(1);
      }
    }
  }

  /// Sets or replaces the destination location.
  ///
  /// If the itinerary has fewer than [minimumWaypoints], it adds the location.
  /// If the itinerary already has a destination, it replaces it.
  void setDestination(String location) {
    if (_itinerary.length < minimumWaypoints) {
      _itinerary.add(location);
    } else if (_itinerary.length == minimumWaypoints) {
      _itinerary[destinationIndex] = location;
    }
  }

  /// Removes a location at the given [index], if it exists.
  void removeAt(int index) {
    if (index < _itinerary.length) {
      _itinerary.removeAt(index);
    }
  }

  /// Returns `true` if the itinerary has both a start and a destination.
  bool isValid() => _itinerary.length >= minimumWaypoints;

  /// Returns a copy of the current itinerary list.
  List<String> getWaypoints() => List.unmodifiable(_itinerary);

  int get length => _itinerary.length;

  String getStart() =>
      _itinerary.isNotEmpty ? _itinerary[startIndex] : defaultStart;

  String getDestination() =>
      _itinerary.length > 1 ? _itinerary[destinationIndex] : '';
}
