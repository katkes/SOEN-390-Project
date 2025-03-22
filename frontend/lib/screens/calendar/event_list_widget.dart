/// This widget displays a list of events for a selected day.
/// The widget is used by the [CalendarScreen] to display events for a selected day.
/// The widget displays the event title, time, and location.
library;

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
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (timeString.isNotEmpty) Text(timeString),
                      if (event.location != null && event.location!.isNotEmpty)
                        Text(event.location!,
                            style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              );
            },
          );
  }
}
