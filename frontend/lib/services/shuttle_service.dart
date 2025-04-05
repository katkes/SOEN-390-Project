// Represents a shuttle stop location with a name and coordinates.
class ShuttleStopLocation {
  final String name;
  final String coordinates;

  ShuttleStopLocation({required this.name, required this.coordinates});
}

// Represents the shuttle schedule, including departure times, last bus times, and stop locations.
class ShuttleSchedule {
  final List<String> loyDepartures; // Departure times from Loyola campus.
  final List<String> sgwDepartures; // Departure times from SGW campus.
  final Map<String, String> lastBus; // Last bus times for each campus.
  final Map<String, ShuttleStopLocation> stops; // Shuttle stop locations.

  ShuttleSchedule({
    required this.loyDepartures,
    required this.sgwDepartures,
    required this.lastBus,
    required this.stops,
  });
}

// Service class to manage shuttle schedules and stop locations.
class ShuttleService {
  // Static data for shuttle schedules.
  static final Map<String, dynamic> _scheduleData = {
    "friday": {
      "LOY_departures": [
        "9:15",
        "9:30",
        "9:45",
        "10:15",
        "10:45",
        "11:00",
        "11:15",
        "12:00",
        "12:15",
        "12:45",
        "13:00",
        "13:15",
        "13:45",
        "14:15",
        "14:30",
        "14:45",
        "15:15",
        "15:30",
        "15:45",
        "16:45",
        "17:15",
        "17:45",
        "18:15"
      ],
      "SGW_departures": [
        "9:45",
        "10:00",
        "10:15",
        "10:45",
        "11:15",
        "11:30",
        "12:15",
        "12:30",
        "12:45",
        "13:15",
        "13:45",
        "14:00",
        "14:15",
        "14:45",
        "15:00",
        "15:15",
        "15:45",
        "16:00",
        "16:45",
        "17:15",
        "17:45",
        "18:15"
      ],
      "last_bus": {"LOY": "18:15", "SGW": "18:15"}
    },
    "monday_thursday": {
      "LOY_departures": [
        "9:15",
        "9:30",
        "9:45",
        "10:00",
        "10:15",
        "10:30",
        "10:45",
        "11:00",
        "11:15",
        "11:30",
        "11:45",
        "12:30",
        "12:45",
        "13:00",
        "13:15",
        "13:30",
        "13:45",
        "14:00",
        "14:15",
        "14:30",
        "14:45",
        "15:00",
        "15:15",
        "15:30",
        "15:45",
        "16:30",
        "16:45",
        "17:00",
        "17:15",
        "17:30",
        "17:45",
        "18:00",
        "18:15",
        "18:30"
      ],
      "SGW_departures": [
        "9:30",
        "9:45",
        "10:00",
        "10:15",
        "10:30",
        "10:45",
        "11:00",
        "11:15",
        "11:30",
        "12:15",
        "12:30",
        "12:45",
        "13:00",
        "13:15",
        "13:30",
        "13:45",
        "14:00",
        "14:15",
        "14:30",
        "14:45",
        "15:00",
        "15:15",
        "15:30",
        "16:00",
        "16:15",
        "16:45",
        "17:00",
        "17:15",
        "17:30",
        "17:45",
        "18:00",
        "18:15",
        "18:30"
      ],
      "last_bus": {"LOY": "18:30", "SGW": "18:30"}
    }
  };

  // Static data for shuttle stop locations.
  static final Map<String, String> _stops = {
    "LOY": "45°27'28.2\"N 73°38'20.3\"W", // Coordinates for Loyola campus.
    "SGW": "45°29'49.6\"N 73°34'42.5\"W" // Coordinates for SGW campus.
  };

  // Retrieves the shuttle schedule for Friday.
  ShuttleSchedule getFridaySchedule() {
    final data = _scheduleData['friday'];

    return ShuttleSchedule(
      loyDepartures: List<String>.from(data['LOY_departures']),
      sgwDepartures: List<String>.from(data['SGW_departures']),
      lastBus: Map<String, String>.from(data['last_bus']),
      stops: _stops.map((key, value) {
        return MapEntry(
          key,
          ShuttleStopLocation(name: key, coordinates: value),
        );
      }),
    );
  }

  // Retrieves the shuttle schedule for Monday to Thursday.
  ShuttleSchedule getMondayThursdaySchedule() {
    final data = _scheduleData['monday_thursday'];

    return ShuttleSchedule(
      loyDepartures: List<String>.from(data['LOY_departures']),
      sgwDepartures: List<String>.from(data['SGW_departures']),
      lastBus: Map<String, String>.from(data['last_bus']),
      stops: _stops.map((key, value) {
        return MapEntry(
          key,
          ShuttleStopLocation(name: key, coordinates: value),
        );
      }),
    );
  }
}
