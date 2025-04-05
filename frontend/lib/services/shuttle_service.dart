class ShuttleStopLocation {
  final String name;
  final String coordinates;

  ShuttleStopLocation({required this.name, required this.coordinates});
}

class ShuttleSchedule {
  final List<String> loyDepartures;
  final List<String> sgwDepartures;
  final Map<String, String> lastBus;
  final Map<String, ShuttleStopLocation> stops;

  ShuttleSchedule({
    required this.loyDepartures,
    required this.sgwDepartures,
    required this.lastBus,
    required this.stops,
  });
}

class ShuttleService {
  static final Map<String, dynamic> _scheduleData = {
    "friday": {
      "LOY_departures": [
        "9:15", "9:30", "9:45", "10:15", "10:45", "11:00", "11:15",
        "12:00", "12:15", "12:45", "13:00", "13:15", "13:45", "14:15",
        "14:30", "14:45", "15:15", "15:30", "15:45", "16:45", "17:15",
        "17:45", "18:15"
      ],
      "SGW_departures": [
        "9:45", "10:00", "10:15", "10:45", "11:15", "11:30", "12:15",
        "12:30", "12:45", "13:15", "13:45", "14:00", "14:15", "14:45",
        "15:00", "15:15", "15:45", "16:00", "16:45", "17:15", "17:45",
        "18:15"
      ],
      "last_bus": {
        "LOY": "18:15",
        "SGW": "18:15"
      }
    },
    "monday_thursday": {
      "LOY_departures": [
        "9:15", "9:30", "9:45", "10:00", "10:15", "10:30", "10:45", "11:00", "11:15", "11:30", "11:45", "12:30",
        "12:45", "13:00", "13:15", "13:30", "13:45", "14:00", "14:15", "14:30", "14:45", "15:00", "15:15",
        "15:30", "15:45", "16:30", "16:45", "17:00", "17:15", "17:30", "17:45", "18:00", "18:15", "18:30"
      ],
      "SGW_departures": [
        "9:30", "9:45", "10:00", "10:15", "10:30", "10:45", "11:00", "11:15", "11:30", "12:15", "12:30", "12:45",
        "13:00", "13:15", "13:30", "13:45", "14:00", "14:15", "14:30", "14:45", "15:00", "15:15", "15:30",
        "16:00", "16:15", "16:45", "17:00", "17:15", "17:30", "17:45", "18:00", "18:15", "18:30"
      ],
      "last_bus": {
        "LOY": "18:30",
        "SGW": "18:30"
      }
    }
  };

  static final Map<String, String> _stops = {
    "LOY": "45°27'28.2\"N 73°38'20.3\"W",
    "SGW": "45°29'49.6\"N 73°34'42.5\"W"
  };

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