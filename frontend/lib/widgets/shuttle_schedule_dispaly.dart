import 'package:flutter/material.dart';
import 'package:soen_390/services/shuttle_service.dart';
import 'package:soen_390/styles/theme.dart';

class ShuttleScheduleDisplay extends StatelessWidget {
  final ShuttleSchedule fridaySchedule;

  const ShuttleScheduleDisplay({super.key, required this.fridaySchedule});

  Widget _buildScheduleList(BuildContext context, String title, List<String> times) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: appTheme.textTheme.titleMedium?.copyWith(
            color: appTheme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
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

  Widget _buildStop(BuildContext context, String stop, String coordinates) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(Icons.location_on, color: theme.colorScheme.primary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            "$stop: $coordinates",
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: appTheme.colorScheme.onPrimary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Shuttle Bus Schedule (Friday)",
            style: appTheme.textTheme.titleLarge?.copyWith(
              color: appTheme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _buildScheduleList(context, "LOY Departures", fridaySchedule.loyDepartures),
          const SizedBox(height: 20),
          _buildScheduleList(context, "SGW Departures", fridaySchedule.sgwDepartures),
          const SizedBox(height: 20),
          Text(
            "Stop Locations",
            style: appTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          ...fridaySchedule.stops.entries.map((entry) =>
              _buildStop(context, entry.key, entry.value.coordinates)),
        ],
      ),
    );
  }
}

