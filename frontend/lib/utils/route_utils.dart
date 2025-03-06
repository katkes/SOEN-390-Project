import 'package:flutter/material.dart';

// Constants
const int secondsInMinute = 60;
const int minutesInHour = 60;
const int pmThreshold = 12;
const int minPartsForAddress = 2;

// Helper function to shorten address (remove unnecessary components)
String shortenAddress(String address) {
  final parts = address.split(", ");
  if (parts.length > minPartsForAddress) {
    return parts.take(parts.length - minPartsForAddress).join(", ");
  }
  return address;
}

// Helper function to format duration in seconds to a human-readable format
String formatDuration(double seconds) {
  final int minutes = (seconds / secondsInMinute).round();
  if (minutes < minutesInHour) {
    return "$minutes min";
  } else {
    final int hours = (minutes / minutesInHour).floor();
    final int remainingMinutes = minutes % minutesInHour;
    return "$hours h $remainingMinutes min";
  }
}

// Helper function to format time range based on current time and duration
String formatTimeRange(double seconds) {
  final now = DateTime.now();
  final arrival = now.add(Duration(seconds: seconds.round()));

  String formatTime(DateTime time) {
    final hour = time.hour > pmThreshold ? time.hour - pmThreshold : time.hour;
    final period = time.hour >= pmThreshold ? "PM" : "AM";
    return "${hour == 0 ? 12 : hour}:${time.minute.toString().padLeft(2, '0')} $period";
  }

  return "${formatTime(now)} - ${formatTime(arrival)}";
}

// Helper function to get icons based on transport mode
List<IconData> getIconsForTransport(String mode) {
  switch (mode) {
    case "Car":
      return [Icons.directions_car];
    case "Bike":
      return [Icons.directions_bike];
    case "Train or Bus":
      return [Icons.train];
    case "Walk":
      return [Icons.directions_walk];
    default:
      return [Icons.help_outline];
  }
}

// Helper function to map transport mode from UI to API-compatible mode
String mapTransportModeToApiMode(String uiMode) {
  switch (uiMode) {
    case "Car":
      return "driving";
    case "Bike":
      return "bicycling";
    case "Train or Bus":
      return "transit";
    case "Walk":
      return "walking";
    default:
      return "transit";
  }
}
