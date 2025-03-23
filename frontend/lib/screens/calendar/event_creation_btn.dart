import 'package:flutter/material.dart';
import 'package:googleapis/calendar/v3.dart' as gcal;
import 'package:soen_390/screens/calendar/event_creation_widget.dart';
import 'package:soen_390/services/calendar_service.dart';
import 'package:soen_390/repositories/auth_repository.dart';
import 'package:soen_390/services/auth_service.dart';

class EventCreationButton extends StatelessWidget {
  final BuildContext parentContext;
  final AuthService authService;
  final String? selectedCalendarId;
  final Future<void> Function() fetchCalendarEvents;

  const EventCreationButton({
    super.key,
    required this.parentContext,
    required this.authService,
    required this.selectedCalendarId,
    required this.fetchCalendarEvents,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: handlePressed,
      tooltip: 'Create Event',
      child: const Icon(Icons.add),
      backgroundColor: const Color(0xFF004085),
      mini: true,
    );
  }

  void handlePressed() {
    showDialog(
      context: parentContext,
      builder: (context) => EventCreationPopup(
        onSave: handleEventSave,
      ),
    );
  }

  void handleEventSave(
    String name,
    String building,
    String classroom,
    TimeOfDay time,
    DateTime day,
    String? recurringFrequency,
  ) {
    () async {
      final eventDates = generateEventDates(day, recurringFrequency ?? 'None');

      final calendarService = buildCalendarService();

      for (final eventDate in eventDates) {
        final event = createEvent(
          name: name,
          building: building,
          classroom: classroom,
          date: eventDate,
          time: time,
        );

        try {
          await calendarService.createEvent(
            selectedCalendarId ?? 'primary',
            event,
          );
        } catch (e) {
          print("Error creating event on ${eventDate.toString()}: $e");
        }
      }

      await fetchCalendarEvents();

      if (parentContext.mounted) {
        Navigator.pop(parentContext);
      }
    }();
  }

  CalendarService buildCalendarService() {
    return CalendarService(
      AuthRepository(
        authService: authService,
        httpService: authService.httpService,
        secureStorage: authService.secureStorage,
      ),
    );
  }

  List<DateTime> generateEventDates(DateTime day, String frequency) {
    switch (frequency) {
      case "Daily":
        return List.generate(7, (i) => day.add(Duration(days: i)));
      case "Weekly":
        return List.generate(13, (i) => day.add(Duration(days: 7 * i)));
      case "Monthly":
        return List.generate(12, (i) {
          final newMonth = day.month + i;
          final yearOffset = (newMonth - 1) ~/ 12;
          final adjustedMonth = ((newMonth - 1) % 12) + 1;

          final daysInMonth =
              DateTime(day.year + yearOffset, adjustedMonth + 1, 0).day;
          final adjustedDay = day.day > daysInMonth ? daysInMonth : day.day;

          return DateTime(day.year + yearOffset, adjustedMonth, adjustedDay);
        });
      default:
        return [day];
    }
  }

  gcal.Event createEvent({
    required String name,
    required String building,
    required String classroom,
    required DateTime date,
    required TimeOfDay time,
  }) {
    final startDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    final endDateTime = startDateTime.add(const Duration(hours: 1));

    return gcal.Event()
      ..summary = name
      ..location = "$building, $classroom"
      ..start = gcal.EventDateTime(dateTime: startDateTime)
      ..end = gcal.EventDateTime(dateTime: endDateTime);
  }
}
