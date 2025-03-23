
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:soen_390/screens/calendar/calendar_event_service.dart';
import 'package:soen_390/repositories/calendar_repository.dart';
import 'package:googleapis/calendar/v3.dart' as gcal;


@GenerateMocks([CalendarRepository])
import 'calendar_event_service_test.mocks.dart';
void main() {
  late CalendarEventService calendarEventService;
  late MockCalendarRepository mockCalendarRepository;

  setUp(() {
    mockCalendarRepository = MockCalendarRepository();
    calendarEventService = CalendarEventService(calendarRepository: mockCalendarRepository);
  });

  group('CalendarEventService', () {
    test('fetchCalendarEvents groups events by date correctly', () async {

      final today = DateTime.now();
      final tomorrow = today.add(const Duration(days: 1));
      
      final mockEvents = [


gcal.Event()
  ..id = 'event1'
  ..summary = 'Event 1'
  ..start = gcal.EventDateTime(dateTime: DateTime(today.year, today.month, today.day, 10, 0))
  ..end = gcal.EventDateTime(dateTime: DateTime(today.year, today.month, today.day, 11, 0)),


gcal.Event()
  ..id = 'event2'
  ..summary = 'Event 2'
  ..start = gcal.EventDateTime(dateTime: DateTime(today.year, today.month, today.day, 14, 0))
  ..end = gcal.EventDateTime(dateTime: DateTime(today.year, today.month, today.day, 15, 0)),


gcal.Event()
  ..id = 'event3'
  ..summary = 'Event 3'
  ..start = gcal.EventDateTime(dateTime: DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 9, 0))
  ..end = gcal.EventDateTime(dateTime: DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 10, 0)),

      ];
      

      when(mockCalendarRepository.getEvents(calendarId: 'testCalendar', useCache: true))
          .thenAnswer((_) async => mockEvents);
      

      final result = await calendarEventService.fetchCalendarEvents('testCalendar');
      

      expect(result.length, 2);
      
   
      final todayDate = DateTime(today.year, today.month, today.day);
      expect(result[todayDate]?.length, 2); 
      expect(result[todayDate]?[0].summary, 'Event 1');
      expect(result[todayDate]?[1].summary, 'Event 2');
      
   
      final tomorrowDate = DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
      expect(result[tomorrowDate]?.length, 1); 
      expect(result[tomorrowDate]?[0].summary, 'Event 3');
      
      verify(mockCalendarRepository.getEvents(calendarId: 'testCalendar', useCache: true)).called(1);
    });
    
    
    
    test('fetchCalendarEvents handles events with missing start time', () async {
   
      final mockEvents = [

        gcal.Event()
          ..id = 'event1'
          ..summary = 'Event with no start time',
      ];
      
     
      when(mockCalendarRepository.getEvents(calendarId: 'testCalendar', useCache: true))
          .thenAnswer((_) async => mockEvents);
      
      // Act
      final result = await calendarEventService.fetchCalendarEvents('testCalendar');
      
      // Assert
      expect(result.length, 0); 
    });
    
    test('fetchCalendarEvents throws exception when repository throws', () async {

      when(mockCalendarRepository.getEvents(calendarId: 'testCalendar', useCache: true))
          .thenThrow(Exception('Repository error'));
      

      expect(
        () => calendarEventService.fetchCalendarEvents('testCalendar'),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('An error occurred while fetching events')
        )),
      );
    });
    
    test('fetchCalendars returns calendars from repository', () async {
      // Arrange
      final mockCalendars = [
        gcal.CalendarListEntry()
          ..id = 'calendar1'
          ..summary = 'Test Calendar 1',
        gcal.CalendarListEntry()
          ..id = 'calendar2'
          ..summary = 'Test Calendar 2',
      ];
      
      when(mockCalendarRepository.getCalendars())
          .thenAnswer((_) async => mockCalendars);
      
    
      final result = await calendarEventService.fetchCalendars();
      

      expect(result.length, 2);
      expect(result[0].id, 'calendar1');
      expect(result[1].id, 'calendar2');
      
    
      verify(mockCalendarRepository.getCalendars()).called(1);
    });
    
    test('fetchCalendars throws exception when repository throws', () async {
   
      when(mockCalendarRepository.getCalendars())
          .thenThrow(Exception('Repository error'));
      
      expect(
        () => calendarEventService.fetchCalendars(),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('An error occurred while fetching calendars')
        )),
      );
    });
    
    test('deleteEventFromCache calls repository method', () async {

      when(mockCalendarRepository.removeEventFromCache('event1', 'calendar1'))
          .thenAnswer((_) async {});
      
      // Act
      await calendarEventService.deleteEventFromCache('event1', 'calendar1');
      
      // Assert
      verify(mockCalendarRepository.removeEventFromCache('event1', 'calendar1')).called(1);
    });
    
    test('deleteEventFromCache throws exception when repository throws', () async {

      when(mockCalendarRepository.removeEventFromCache('event1', 'calendar1'))
          .thenThrow(Exception('Repository error'));
      
      expect(
        () => calendarEventService.deleteEventFromCache('event1', 'calendar1'),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('An error occurred while deleting event from cache')
        )),
      );
    });
  });
}
