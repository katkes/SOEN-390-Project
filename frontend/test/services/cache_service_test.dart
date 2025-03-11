import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:googleapis/calendar/v3.dart';
import 'package:soen_390/services/cache_service.dart'; // Update with the actual package path

import 'cache_service_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<SharedPreferences>(),
  MockSpec<CalendarApi>(),
])
void main() {
  late MockSharedPreferences mockPreferences;
  late MockCalendarApi mockCalendarApi;
  late CacheService cacheService;

  setUp(() {
    mockPreferences = MockSharedPreferences();
    mockCalendarApi = MockCalendarApi();
    cacheService = CacheService(mockPreferences, mockCalendarApi);
  });

  group('CacheService', () {
    test('should store events in SharedPreferences', () async {
      final events = [
        Event(summary: "Meeting", id: "1"),
        Event(summary: "Conference", id: "2"),
      ];
      final encodedEvents = events.map((e) => jsonEncode(e.toJson())).toList();

      when(mockPreferences.setStringList("cached_events", encodedEvents))
          .thenAnswer((_) async => true);

      await cacheService.storeEvents(events);

      verify(mockPreferences.setStringList("cached_events", encodedEvents))
          .called(1);
    });

    test('should retrieve stored events from SharedPreferences', () async {
      final storedData = [
        jsonEncode({"summary": "Meeting", "id": "1"}),
        jsonEncode({"summary": "Conference", "id": "2"}),
      ];

      when(mockPreferences.getStringList("cached_events"))
          .thenReturn(storedData);

      final events = await cacheService.getStoredEvents();

      expect(events, isA<List<Event>>());
      expect(events.length, 2);
      expect(events[0].summary, "Meeting");
      expect(events[1].summary, "Conference");

      verify(mockPreferences.getStringList("cached_events")).called(1);
    });

    test('should return empty list when no events are stored', () async {
      when(mockPreferences.getStringList("cached_events")).thenReturn(null);

      final events = await cacheService.getStoredEvents();

      expect(events, isEmpty);
      verify(mockPreferences.getStringList("cached_events")).called(1);
    });
  });
}
