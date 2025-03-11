import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:googleapis/calendar/v3.dart';
import 'package:soen_390/services/calendar_service.dart';
import 'package:soen_390/services/cache_service.dart';
import 'package:soen_390/repositories/calendar_repository.dart';

import 'calendar_repository_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<CalendarService>(),
  MockSpec<CacheService>(),
])
void main() {
  late MockCalendarService mockCalendarService;
  late MockCacheService mockCacheService;
  late CalendarRepository calendarRepository;

  setUp(() {
    mockCalendarService = MockCalendarService();
    mockCacheService = MockCacheService();
    calendarRepository =
        CalendarRepository(mockCalendarService, mockCacheService);
  });

  group('getEvents', () {
    test('returns cached events when available', () async {
      final cachedEvents = [Event(summary: 'Cached Event')];

      when(mockCacheService.getStoredEvents())
          .thenAnswer((_) async => cachedEvents);

      final events = await calendarRepository.getEvents();

      expect(events, isNotEmpty);
      expect(events.first.summary, 'Cached Event');
      verify(mockCacheService.getStoredEvents()).called(1);
      verifyNever(mockCalendarService.fetchEvents());
    });

    test('fetches events from service if cache is empty', () async {
      final freshEvents = [Event(summary: 'Fresh Event')];

      when(mockCacheService.getStoredEvents()).thenAnswer((_) async => []);
      when(mockCalendarService.fetchEvents())
          .thenAnswer((_) async => freshEvents);
      when(mockCacheService.storeEvents(any)).thenAnswer((_) async {});

      final events = await calendarRepository.getEvents();

      expect(events, isNotEmpty);
      expect(events.first.summary, 'Fresh Event');
      verify(mockCacheService.getStoredEvents()).called(1);
      verify(mockCalendarService.fetchEvents()).called(1);
      verify(mockCacheService.storeEvents(freshEvents)).called(1);
    });

    test('returns events from service when useCache is false', () async {
      final freshEvents = [Event(summary: 'Fresh Event')];

      when(mockCalendarService.fetchEvents())
          .thenAnswer((_) async => freshEvents);
      when(mockCacheService.storeEvents(any)).thenAnswer((_) async {});

      final events = await calendarRepository.getEvents(useCache: false);

      expect(events, isNotEmpty);
      expect(events.first.summary, 'Fresh Event');
      verifyNever(mockCacheService.getStoredEvents());
      verify(mockCalendarService.fetchEvents()).called(1);
      verify(mockCacheService.storeEvents(freshEvents)).called(1);
    });

    test('returns an empty list if both cache and API return no data',
        () async {
      when(mockCacheService.getStoredEvents()).thenAnswer((_) async => []);
      when(mockCalendarService.fetchEvents()).thenAnswer((_) async => []);

      final events = await calendarRepository.getEvents();

      expect(events, isEmpty);
    });
  });

  group('getCalendars', () {
    test('fetches calendars from calendar service', () async {
      final calendars = [CalendarListEntry(summary: 'Work')];

      when(mockCalendarService.fetchCalendars())
          .thenAnswer((_) async => calendars);

      final result = await calendarRepository.getCalendars();

      expect(result, isNotEmpty);
      expect(result.first.summary, 'Work');
      verify(mockCalendarService.fetchCalendars()).called(1);
    });

    test('returns an empty list if no calendars are found', () async {
      when(mockCalendarService.fetchCalendars()).thenAnswer((_) async => []);

      final result = await calendarRepository.getCalendars();

      expect(result, isEmpty);
    });
  });
}
