import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:soen_390/screens/calendar/calendar_event_service.dart';
import 'package:soen_390/repositories/calendar_repository.dart';
import 'package:googleapis/calendar/v3.dart' as gcal;

class MockCalendarRepository extends Mock implements CalendarRepository {}

void main() {
  late MockCalendarRepository mockCalendarRepository;
  late CalendarEventService calendarEventService;

  setUp(() {
    mockCalendarRepository = MockCalendarRepository();
    calendarEventService =
        CalendarEventService(calendarRepository: mockCalendarRepository);
  });

  test('should return events for a specific day', () {
    // Arrange: Mock events by date
    final mockEventsByDay = {
      DateTime(2025, 3, 20): [
        gcal.Event()..summary = 'Event 1',
        gcal.Event()..summary = 'Event 2',
      ],
      DateTime(2025, 3, 21): [
        gcal.Event()..summary = 'Event 3',
      ],
    };

    // Act: Call getEventsForDay for a specific day
    final eventsForMarch20 = calendarEventService.getEventsForDay(
        DateTime(2025, 3, 20), mockEventsByDay);

    // Assert: Verify that the correct events are returned for the day
    expect(eventsForMarch20, hasLength(2)); // Two events on 2025-03-20
    expect(eventsForMarch20[0].summary, 'Event 1');
    expect(eventsForMarch20[1].summary, 'Event 2');
  });
}
