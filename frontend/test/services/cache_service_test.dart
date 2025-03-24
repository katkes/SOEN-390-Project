import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:googleapis/calendar/v3.dart';
import 'package:soen_390/services/cache_service.dart'; // Update with actual package path

import 'cache_service_test.mocks.dart';

/// Generates mock classes for `SharedPreferences` and `CalendarApi`.
@GenerateNiceMocks([
  MockSpec<SharedPreferences>(),
  MockSpec<CalendarApi>(),
])

/// Main function for testing the `CacheService` class.
void main() {
  late MockSharedPreferences mockPreferences;
  late MockCalendarApi mockCalendarApi;
  late CacheService cacheService;

  const testCalendarId = 'primary';
  const expectedCacheKey = 'cached_events_primary';

  /// Initializes dependencies before each test.
  setUp(() {
    mockPreferences = MockSharedPreferences();
    mockCalendarApi = MockCalendarApi();
    cacheService = CacheService(mockPreferences, mockCalendarApi);
  });

  /// Group of tests for `CacheService` functionality.
  group('CacheService', () {
    /// Tests if `storeEvents` correctly stores events in `SharedPreferences`.
    test('should store events in SharedPreferences for specific calendar',
        () async {
      final events = [
        Event(summary: "Meeting", id: "1"),
        Event(summary: "Conference", id: "2"),
      ];

      // Encodes events to JSON format for storage.
      final encodedEvents = events.map((e) => jsonEncode(e.toJson())).toList();

      // Mocks `setStringList` method to simulate storing events.
      when(mockPreferences.setStringList(expectedCacheKey, encodedEvents))
          .thenAnswer((_) async => true);

      await cacheService.storeEvents(events, calendarId: testCalendarId);

      // Verifies that `setStringList` was called once with correct parameters.
      verify(mockPreferences.setStringList(expectedCacheKey, encodedEvents))
          .called(1);
    });

    /// Tests if `getStoredEvents` retrieves stored events from `SharedPreferences`.
    test(
        'should retrieve stored events from SharedPreferences for specific calendar',
        () async {
      // Simulated stored JSON event data.
      final storedData = [
        jsonEncode({"summary": "Meeting", "id": "1"}),
        jsonEncode({"summary": "Conference", "id": "2"}),
      ];

      // Mocks `getStringList` to return stored event data.
      when(mockPreferences.getStringList(expectedCacheKey))
          .thenReturn(storedData);

      final events =
          await cacheService.getStoredEvents(calendarId: testCalendarId);

      expect(events, isA<List<Event>>());
      expect(events.length, 2);
      expect(events[0].summary, "Meeting");
      expect(events[1].summary, "Conference");

      // Verifies that `getStringList` was called once.
      verify(mockPreferences.getStringList(expectedCacheKey)).called(1);
    });

    /// Tests if `getStoredEvents` returns an empty list when no events are stored.
    test(
        'should return empty list when no events are stored for specific calendar',
        () async {
      // Mocks `getStringList` to return `null`, simulating no stored events.
      when(mockPreferences.getStringList(expectedCacheKey)).thenReturn(null);

      final events =
          await cacheService.getStoredEvents(calendarId: testCalendarId);

      expect(events, isEmpty);

      // Verifies that `getStringList` was called once.
      verify(mockPreferences.getStringList(expectedCacheKey)).called(1);
    });

    /// Tests removeEventFromCache method
    test('should handle event not found in cache', () async {
      final storedData = [
        jsonEncode({"summary": "Meeting", "id": "1"}),
        jsonEncode({"summary": "Conference", "id": "2"}),
      ];

      when(mockPreferences.getStringList(expectedCacheKey))
          .thenReturn(storedData);

      when(mockPreferences.setStringList(expectedCacheKey, any))
          .thenAnswer((_) async => true);

      await cacheService.removeEventFromCache('3', calendarId: testCalendarId);

      verify(mockPreferences.setStringList(expectedCacheKey, storedData))
          .called(1);
    });
  });
}
