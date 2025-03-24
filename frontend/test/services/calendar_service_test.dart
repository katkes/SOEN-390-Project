import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:googleapis/calendar/v3.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:soen_390/repositories/auth_repository.dart';
import 'package:soen_390/services/calendar_service.dart';

import 'calendar_service_test.mocks.dart';

/// Generates mock classes for `AuthRepository`, `AuthClient`, `CalendarApi`, `EventsResource`, and `CalendarListResource`.
@GenerateNiceMocks([
  MockSpec<AuthRepository>(),
  MockSpec<auth.AuthClient>(),
  MockSpec<CalendarApi>(),
  MockSpec<EventsResource>(),
  MockSpec<CalendarListResource>()
])

/// Main function for testing the `CalendarService` class.
void main() {
  late MockAuthRepository mockAuthRepository;
  late MockAuthClient mockAuthClient;
  late MockCalendarApi mockCalendarApi;
  late MockEventsResource mockEventsResource;
  late MockCalendarListResource mockCalendarListResource;
  late CalendarService calendarService;

  /// Sets up the test environment before each test case.
  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockAuthClient = MockAuthClient();
    mockCalendarApi = MockCalendarApi();
    mockEventsResource = MockEventsResource();
    mockCalendarListResource = MockCalendarListResource();

    // Mocks authentication repository to return a valid AuthClient.
    when(mockAuthRepository.getAuthClient())
        .thenAnswer((_) async => mockAuthClient);

    // Mocks Calendar API resources.
    when(mockCalendarApi.events).thenReturn(mockEventsResource);
    when(mockCalendarApi.calendarList).thenReturn(mockCalendarListResource);

    // Simulates API responses for fetching events and calendars.
    when(mockAuthClient.send(any)).thenAnswer((invocation) async {
      final request = invocation.positionalArguments.first as http.BaseRequest;

      if (request.url
          .toString()
          .contains("calendar/v3/calendars/primary/events")) {
        final response = jsonEncode({
          "items": [
            {"summary": "Test Event"}
          ]
        });

        return http.StreamedResponse(
          Stream.value(utf8.encode(response)),
          200, // OK status
          headers: {'content-type': 'application/json'},
        );
      }

      if (request.url
          .toString()
          .contains("calendar/v3/users/me/calendarList")) {
        final response = jsonEncode({
          "items": [
            {"summary": "Test Calendar"}
          ]
        });

        return http.StreamedResponse(
          Stream.value(utf8.encode(response)),
          200, // OK status
          headers: {'content-type': 'application/json'},
        );
      }

      return http.StreamedResponse(Stream.value([]), 404);
    });

    // Initializes `CalendarService` with mocked dependencies.
    calendarService = CalendarService(mockAuthRepository,
        calendarApiProvider: (_) => mockCalendarApi);
  });

  /// Group of tests for the `fetchEvents` method.
  group('fetchEvents', () {
    /// Tests if `fetchEvents` returns a list of events when authentication succeeds.
    test('returns a list of events when authentication succeeds', () async {
      final mockEvent = Event(summary: 'Test Event');
      final eventsList = Events(items: [mockEvent]);

      when(mockEventsResource.list(
        'primary',
        singleEvents: true,
        orderBy: 'startTime',
        timeMin: anyNamed('timeMin'),
      )).thenAnswer((_) async => eventsList);

      final events = await calendarService.fetchEvents();

      expect(events, isNotEmpty);
      expect(events.first.summary, equals('Test Event'));
    });

    /// Tests if `fetchEvents` returns an empty list when authentication fails.
    test('returns an empty list when authentication fails', () async {
      when(mockAuthRepository.getAuthClient()).thenAnswer((_) async => null);

      final events = await calendarService.fetchEvents();

      expect(events, isEmpty);
    });
  });

  /// Group of tests for the `fetchCalendars` method.
  group('fetchCalendars', () {
    /// Tests if `fetchCalendars` returns a list of calendars when authentication succeeds.
    test('returns a list of calendars when authentication succeeds', () async {
      final mockCalendar = CalendarListEntry(summary: 'Test Calendar');
      final calendarList = CalendarList(items: [mockCalendar]);

      when(mockCalendarListResource.list())
          .thenAnswer((_) async => calendarList);

      final calendars = await calendarService.fetchCalendars();

      expect(calendars, isNotEmpty);
      expect(calendars.first.summary, equals('Test Calendar'));
    });

    /// Tests if `fetchCalendars` returns an empty list when authentication fails.
    test('returns an empty list when authentication fails', () async {
      when(mockAuthRepository.getAuthClient()).thenAnswer((_) async => null);

      final calendars = await calendarService.fetchCalendars();

      expect(calendars, isEmpty);
    });
  });

  /// Group of tests for the `createEvent` method.
  group('createEvent', () {
    /// Tests if `createEvent` returns the created event when authentication succeeds.
    test('returns the created event when authentication succeeds', () async {
      final event = Event(summary: 'New Event');

      when(mockEventsResource.insert(any, any)).thenAnswer((_) async => event);

      final createdEvent = await calendarService.createEvent('primary', event);

      expect(createdEvent, isNotNull);
      expect(createdEvent?.summary, equals('New Event'));
    });

    /// Tests if `createEvent` returns `null` when authentication fails.
    test('returns null when authentication fails', () async {
      when(mockAuthRepository.getAuthClient()).thenAnswer((_) async => null);

      final createdEvent =
          await calendarService.createEvent('primary', Event());

      expect(createdEvent, isNull);
    });
  });

  /// Group of tests for the `updateEvent` method.
  group('updateEvent', () {
    /// Tests if `updateEvent` returns the updated event when authentication succeeds.
    test('returns the updated event when authentication succeeds', () async {
      final updatedEvent = Event(summary: 'Updated Event');

      when(mockEventsResource.update(any, any, any))
          .thenAnswer((_) async => updatedEvent);

      final result =
          await calendarService.updateEvent('primary', 'eventId', updatedEvent);

      expect(result, isNotNull);
      expect(result?.summary, equals('Updated Event'));
    });

    /// Tests if `updateEvent` returns `null` when authentication fails.
    test('returns null when authentication fails', () async {
      when(mockAuthRepository.getAuthClient()).thenAnswer((_) async => null);

      final result =
          await calendarService.updateEvent('primary', 'eventId', Event());

      expect(result, isNull);
    });
  });

  /// Group of tests for the `deleteEvent` method.
  group('deleteEvent', () {
    /// Tests if `deleteEvent` calls delete on the events resource when authentication succeeds.
    test('calls delete on the events resource when authentication succeeds',
        () async {
      when(mockEventsResource.delete(any, any)).thenAnswer((_) async {});

      await calendarService.deleteEvent('primary', 'eventId');

      verify(mockEventsResource.delete('primary', 'eventId')).called(1);
    });

    /// Tests if `deleteEvent` does nothing when authentication fails.
    test('does nothing when authentication fails', () async {
      when(mockAuthRepository.getAuthClient()).thenAnswer((_) async => null);

      await calendarService.deleteEvent('primary', 'eventId');

      verifyNever(mockEventsResource.delete('primary', 'eventId'));
    });
  });
}
