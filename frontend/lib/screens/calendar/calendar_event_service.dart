/// A service class that handles calendar event operations.
/// This class provides methods to fetch and group calendar events by date.
/// The class uses a [CalendarRepository] to fetch calendar events.
/// The class is used by the [CalendarScreen] to fetch and display calendar events.
library;

import 'package:googleapis/calendar/v3.dart' as gcal;
import 'package:soen_390/repositories/calendar_repository.dart';

class CalendarEventService {
  final CalendarRepository calendarRepository;

  CalendarEventService({required this.calendarRepository});

  Future<Map<DateTime, List<gcal.Event>>> fetchCalendarEvents(
    String calendarId, {
    bool useCache = true,
  }) async {
    try {
      // Fetch events using the CalendarRepository
      final events = await calendarRepository.getEvents(
          calendarId: calendarId, useCache: useCache);

      // Group events by date
      final eventsByDay = <DateTime, List<gcal.Event>>{};

      for (final event in events) {
        final startTime = event.start?.dateTime ??
            (event.start?.date != null
                ? DateTime.parse(event.start!.date!.toString())
                : null);

        if (startTime != null) {
          final dateOnly =
              DateTime(startTime.year, startTime.month, startTime.day);
          if (eventsByDay[dateOnly] == null) {
            eventsByDay[dateOnly] = [];
          }
          eventsByDay[dateOnly]!.add(event);
        }
      }

      return eventsByDay;
    } catch (e) {
      throw Exception("An error occurred while fetching events: $e");
    }
  }

  // Function to get events for a specific day
  List<gcal.Event> getEventsForDay(
      DateTime day, Map<DateTime, List<gcal.Event>> eventsByDay) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return eventsByDay[normalizedDay] ?? [];
  }

  //Function to get calendars using the CalendarRepository
  Future<List<gcal.CalendarListEntry>> fetchCalendars() async {
    try {
      return await calendarRepository.getCalendars();
    } catch (e) {
      throw Exception("An error occurred while fetching calendars: $e");
    }
  }
}
