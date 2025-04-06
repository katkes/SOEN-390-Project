import 'package:flutter/material.dart';
import 'package:soen_390/services/shuttle_service.dart';
import 'package:soen_390/styles/theme.dart';

// A widget that displays a list of shuttle schedule times with a title.
class ScheduleList extends StatelessWidget {
  final String title; // Title of the schedule (e.g., "Morning Schedule").
  final List<String> times; // List of times for the schedule.

  const ScheduleList({
    super.key,
    required this.title,
    required this.times,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Display the title with custom styling.
        Text(
          title,
          style: appTheme.textTheme.titleMedium?.copyWith(
              color: appTheme.colorScheme.primary, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6), // Add spacing below the title.
        // Display the times as a list of chips.
        Wrap(
          spacing: 10, // Horizontal spacing between chips.
          runSpacing: 6, // Vertical spacing between chips.
          children: times
              .map((time) => Chip(
                    label: Text(time), // Display each time as a chip label.
                    backgroundColor:
                        appTheme.colorScheme.surfaceContainerHighest,
                  ))
              .toList(),
        ),
      ],
    );
  }
}

// A widget that displays the stop locations for a shuttle schedule.
class StopLocations extends StatelessWidget {
  final ShuttleSchedule schedule; // Shuttle schedule containing stop locations.

  const StopLocations({super.key, required this.schedule});

  // Helper method to build a row for each stop with its coordinates.
  Widget _buildStop(String stop, String coordinates) {
    return Row(
      children: [
        // Icon to represent the location.
        Icon(Icons.location_on, color: appTheme.colorScheme.primary),
        const SizedBox(width: 6), // Add spacing between the icon and text.
        // Display the stop name and coordinates.
        Expanded(
            child: Text("$stop: $coordinates",
                style: const TextStyle(fontSize: 14))),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // If there are no stops, return an empty widget.
    if (schedule.stops.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Display the "Stop Locations" title with custom styling.
        Text("Stop Locations",
            style: appTheme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10), // Add spacing below the title.
        // Generate a list of stop rows from the schedule's stops.
        ...schedule.stops.entries
            .map((entry) => _buildStop(entry.key, entry.value.coordinates)),
      ],
    );
  }
}
