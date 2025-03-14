import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:googleapis/calendar/v3.dart';
import 'package:soen_390/services/calendar_service.dart';
import 'package:soen_390/services/cache_service.dart';
import 'package:soen_390/repositories/calendar_repository.dart';

import 'calendar_repository_test.mocks.dart';

/// Generates mock classes for `CalendarService` and `CacheService`.
@GenerateNiceMocks([
  MockSpec<CalendarService>(),
  MockSpec<CacheService>(),
])

/// Main function for testing `CalendarRepository`.
void main() {
  late MockCalendarService mockCalendarService;
  late MockCacheService mockCacheService;
  late CalendarRepository calendarRepository;

  /// Sets up test dependencies before each test.
  setUp(() {
    mockCalendarService = MockCalendarService();
    mockCacheService = MockCacheService();
    calendarRepository =
        CalendarRepository(mockCalendarService, mockCacheService);
  });

  /// Group of tests for `getEvents` method.
  group('getEvents', () {
    /// Tests that `getEvents` returns cached events when available.
    test('returns cached events when available', () async {
      final cachedEvents = [Event(summary: 'Cached Event')];

      // Mocks the behavior of cache service to return stored events.
      when(mockCacheService.getStoredEvents())
          .thenAnswer((_) async => cachedEvents);

      final events = await calendarRepository.getEvents();

      expect(events, isNotEmpty);
      expect(events.first.summary, 'Cached Event');

      // Ensures the cache service is called but the API is not used.
      verify(mockCacheService.getStoredEvents()).called(1);
      verifyNever(mockCalendarService.fetchEvents());
    });

    /// Tests that `getEvents` fetches events from the service if the cache is empty.
    test('fetches events from service if cache is empty', () async {
      final freshEvents = [Event(summary: 'Fresh Event')];

      // Mocks an empty cache and a successful fetch from the API.
      when(mockCacheService.getStoredEvents()).thenAnswer((_) async => []);
      when(mockCalendarService.fetchEvents())
          .thenAnswer((_) async => freshEvents);
      when(mockCacheService.storeEvents(any)).thenAnswer((_) async {});

      final events = await calendarRepository.getEvents();

      expect(events, isNotEmpty);
      expect(events.first.summary, 'Fresh Event');

      // Ensures that cache service is checked first, then API is used, and results are stored.
      verify(mockCacheService.getStoredEvents()).called(1);
      verify(mockCalendarService.fetchEvents()).called(1);
      verify(mockCacheService.storeEvents(freshEvents)).called(1);
    });

    /// Tests that `getEvents` returns events from the API when `useCache` is false.
    test('returns events from service when useCache is false', () async {
      final freshEvents = [Event(summary: 'Fresh Event')];

      // Mocks fetching events directly from the service.
      when(mockCalendarService.fetchEvents())
          .thenAnswer((_) async => freshEvents);
      when(mockCacheService.storeEvents(any)).thenAnswer((_) async {});

      final events = await calendarRepository.getEvents(useCache: false);

      expect(events, isNotEmpty);
      expect(events.first.summary, 'Fresh Event');

      // Ensures cache is not checked and API is directly queried.
      verifyNever(mockCacheService.getStoredEvents());
      verify(mockCalendarService.fetchEvents()).called(1);
      verify(mockCacheService.storeEvents(freshEvents)).called(1);
    });

    /// Tests that `getEvents` returns an empty list when both cache and API return no data.
    test('returns an empty list if both cache and API return no data',
        () async {
      // Mocks both cache and API returning empty lists.
      when(mockCacheService.getStoredEvents()).thenAnswer((_) async => []);
      when(mockCalendarService.fetchEvents()).thenAnswer((_) async => []);

      final events = await calendarRepository.getEvents();

      expect(events, isEmpty);
    });
  });

  /// Group of tests for `getCalendars` method.
  group('getCalendars', () {
    /// Tests that `getCalendars` fetches calendars from the calendar service.
    test('fetches calendars from calendar service', () async {
      final calendars = [CalendarListEntry(summary: 'Work')];

      // Mocks fetching calendars from the service.
      when(mockCalendarService.fetchCalendars())
          .thenAnswer((_) async => calendars);

      final result = await calendarRepository.getCalendars();

      expect(result, isNotEmpty);
      expect(result.first.summary, 'Work');

      // Ensures the service is queried once.
      verify(mockCalendarService.fetchCalendars()).called(1);
    });

    /// Tests that `getCalendars` returns an empty list if no calendars are found.
    test('returns an empty list if no calendars are found', () async {
      // Mocks an empty response from the service.
      when(mockCalendarService.fetchCalendars()).thenAnswer((_) async => []);

      final result = await calendarRepository.getCalendars();

      expect(result, isEmpty);
    });
  });
}
