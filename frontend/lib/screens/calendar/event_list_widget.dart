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

  const EventListWidget({
    super.key,
    required this.events,
    required this.calendarService,
    required this.calendarEventService,
    this.onEventChanged,
    required this.calendarId,
  });

  @override
  Widget build(BuildContext context) {
    return events.isEmpty
        ? const Center(child: Text("No events for selected day"))
        : Column(
            children:
                events.map((event) => buildEventCard(context, event)).toList(),
          );
  }

  Card buildEventCard(BuildContext context, gcal.Event event) {
    String timeString = formatEventTime(event);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: () => onEventTapped(context, event),
        child: ListTile(
          leading: const Icon(Icons.event),
          title: Text(event.summary ?? 'No Title'),
          subtitle: buildEventSubtitle(event, timeString),
        ),
      ),
    );
  }

  String formatEventTime(gcal.Event event) {
    if (event.start?.dateTime != null) {
      return DateFormat('h:mm a').format(event.start!.dateTime!);
    }
    return '';
  }

  Column buildEventSubtitle(gcal.Event event, String timeString) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (timeString.isNotEmpty) Text(timeString),
        if (event.location != null && event.location!.isNotEmpty)
          Text(event.location!, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  void onEventTapped(BuildContext context, gcal.Event event) {
    showDialog(
      context: context,
      builder: (context) => EventEditPopup(
        event: event,
        calendarEventService: calendarEventService,
        calendarId: calendarId,
        calendarService: calendarService,
        onEventUpdated: () => onEventChanged?.call(),
        onEventDeleted: () => onEventChanged?.call(),
      ),
    );
  }
}
