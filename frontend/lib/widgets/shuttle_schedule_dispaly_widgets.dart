import 'package:flutter/material.dart';
import 'package:soen_390/services/shuttle_service.dart';
import 'package:soen_390/styles/theme.dart';

class ScheduleList extends StatelessWidget {
  final String title;
  final List<String> times;

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
        Text(
          title,
          style: appTheme.textTheme.titleMedium?.copyWith(
              color: appTheme.colorScheme.primary, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 10,
          runSpacing: 6,
          children: times
              .map((time) => Chip(
                    label: Text(time),
                    backgroundColor: appTheme.colorScheme.surfaceContainerHighest,
                  ))
              .toList(),
        ),
      ],
    );
  }
}

class StopLocations extends StatelessWidget {
  final ShuttleSchedule schedule;

  const StopLocations({super.key, required this.schedule});

  Widget _buildStop(String stop, String coordinates) {
    return Row(
      children: [
        Icon(Icons.location_on, color: appTheme.colorScheme.primary),
        const SizedBox(width: 6),
        Expanded(
            child: Text("$stop: $coordinates",
                style: const TextStyle(fontSize: 14))),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (schedule.stops.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Stop Locations",
            style: appTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ...schedule.stops.entries
            .map((entry) => _buildStop(entry.key, entry.value.coordinates)),
      ],
    );
  }
}