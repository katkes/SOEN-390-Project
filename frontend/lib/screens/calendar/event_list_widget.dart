import 'package:flutter/material.dart';
import 'package:googleapis/calendar/v3.dart' as gcal;
import 'package:intl/intl.dart';
import 'package:soen_390/services/calendar_service.dart';
import 'event_edit_popup.dart';
import 'calendar_event_service.dart';

/// This widget displays a list of events for a selected day.
/// The widget is used by the [CalendarScreen] to display events for a selected day.
/// The widget displays the event title, time, and location.
/// It also handles refreshing the event list after edits or deletions.
class EventListWidget extends StatelessWidget {
  final List<gcal.Event> events;
  final CalendarService calendarService;
  final VoidCallback? onEventChanged;
  final CalendarEventService calendarEventService;

  final String calendarId;

  const EventListWidget(
      {super.key,
      required this.events,
      required this.calendarService,
      required this.calendarEventService,
      this.onEventChanged,
      required this.calendarId});
  @override
  Widget build(BuildContext context) {
    return events.isEmpty
        ? const Center(child: Text("No events for selected day"))
        : Column(
            children: [
              ...events.map((event) {
                // Create a widget for each event here
                String timeString = '';
                if (event.start?.dateTime != null) {
                  timeString =
                      DateFormat('h:mm a').format(event.start!.dateTime!);
                }
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => EventEditPopup(
                          event: event,
                          calendarEventService: calendarEventService,
                          calendarId: calendarId,
                          calendarService: calendarService,
                          onEventUpdated: () {
                            if (onEventChanged != null) {
                              onEventChanged?.call();
                            }
                          },
                          onEventDeleted: () {
                            if (onEventChanged != null) {
                              onEventChanged?.call();
                            }
                          },
                        ),
                      );
                    },
                    child: ListTile(
                      leading: const Icon(Icons.event),
                      title: Text(event.summary ?? 'No Title'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (timeString.isNotEmpty) Text(timeString),
                          if (event.location != null &&
                              event.location!.isNotEmpty)
                            Text(event.location!,
                                style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          );
  }
}
