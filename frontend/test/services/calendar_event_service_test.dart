import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:soen_390/screens/calendar/calendar_event_service.dart';
import 'package:googleapis/calendar/v3.dart' as gcal;
import 'package:soen_390/repositories/calendar_repository.dart';

class MockCalendarRepository extends Mock implements CalendarRepository {}

void main() {
  late CalendarEventService calendarEventService;
  late MockCalendarRepository mockCalendarRepository;

  setUp(() {
    mockCalendarRepository = MockCalendarRepository();
    calendarEventService =
        CalendarEventService(calendarRepository: mockCalendarRepository);
  });

  group('CalendarEventService', () {
    test('getEventsForDay returns events for a specific day', () async {
      final event1 = gcal.Event()
        ..start = gcal.EventDateTime(dateTime: DateTime(2025, 4, 15, 10, 0));
      final event2 = gcal.Event()
        ..start = gcal.EventDateTime(dateTime: DateTime(2025, 4, 15, 14, 0));
      final event3 = gcal.Event()
        ..start = gcal.EventDateTime(dateTime: DateTime(2025, 4, 16, 9, 0));

      final eventsByDay = {
        DateTime(2025, 4, 15): [event1, event2],
        DateTime(2025, 4, 16): [event3],
      };

      final eventsForDay = calendarEventService.getEventsForDay(
          DateTime(2025, 4, 15), eventsByDay);

      expect(eventsForDay, contains(event1));
      expect(eventsForDay, contains(event2));
      expect(eventsForDay, isNot(contains(event3)));
    });

    test('getEventsForDay returns events for a specific day', () async {
      final event1 = gcal.Event()
        ..start = gcal.EventDateTime(dateTime: DateTime(2025, 4, 15, 10, 0));
      final event2 = gcal.Event()
        ..start = gcal.EventDateTime(dateTime: DateTime(2025, 4, 15, 14, 0));
      final event3 = gcal.Event()
        ..start = gcal.EventDateTime(dateTime: DateTime(2025, 4, 16, 9, 0));

      final eventsByDay = {
        DateTime(2025, 4, 15): [event1, event2],
        DateTime(2025, 4, 16): [event3],
      };

      final eventsForDay = calendarEventService.getEventsForDay(
          DateTime(2025, 4, 15), eventsByDay);

      expect(eventsForDay, contains(event1));
      expect(eventsForDay, contains(event2));
      expect(eventsForDay, isNot(contains(event3)));
    });
  });
}
