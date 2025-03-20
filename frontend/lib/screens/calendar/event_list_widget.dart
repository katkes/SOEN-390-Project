import 'package:flutter/material.dart';
import 'package:googleapis/calendar/v3.dart' as gcal;
import 'package:intl/intl.dart';

class EventListWidget extends StatelessWidget {
  final List<gcal.Event> events;

  const EventListWidget({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    return events.isEmpty
        ? const Center(child: Text("No events for selected day"))
        : ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              String timeString = '';
              if (event.start?.dateTime != null) {
                timeString =
                    DateFormat('h:mm a').format(event.start!.dateTime!);
              }
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  leading: const Icon(Icons.event),
                  title: Text(event.summary ?? 'No Title'),
                  subtitle: timeString.isNotEmpty ? Text(timeString) : null,
                ),
              );
            },
          );
  }
}
