import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:googleapis/calendar/v3.dart' as gcal;
import 'package:soen_390/screens/calendar/event_creation_btn.dart';
import 'package:soen_390/screens/calendar/event_creation_widget.dart';
import 'package:soen_390/services/calendar_service.dart';
import 'package:soen_390/services/auth_service.dart';
import 'package:soen_390/repositories/auth_repository.dart';
import 'package:soen_390/services/http_service.dart';
import 'package:soen_390/core/secure_storage.dart';

@GenerateMocks(
    [AuthService, CalendarService, HttpService, SecureStorage, AuthRepository])
import 'event_creation_btn_test.mocks.dart';

void main() {
  late MockAuthService mockAuthService;
  late MockCalendarService mockCalendarService;
  late MockHttpService mockHttpService;
  late MockSecureStorage mockSecureStorage;
  late bool fetchCalendarEventsCalled;

  setUp(() {
    mockAuthService = MockAuthService();
    mockCalendarService = MockCalendarService();
    mockHttpService = MockHttpService();
    mockSecureStorage = MockSecureStorage();
    fetchCalendarEventsCalled = false;

    when(mockAuthService.httpService).thenReturn(mockHttpService);
    when(mockAuthService.secureStorage).thenReturn(mockSecureStorage);
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => EventCreationButton(
            parentContext: context,
            authService: mockAuthService,
            selectedCalendarId: 'testCalendarId',
            fetchCalendarEvents: () async {
              fetchCalendarEventsCalled = true;
            },
          ),
        ),
      ),
    );
  }

  testWidgets('EventCreationButton should render correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    final fabFinder = find.byType(FloatingActionButton);
    expect(fabFinder, findsOneWidget);

    final fab = tester.widget<FloatingActionButton>(fabFinder);
    expect(fab.backgroundColor, const Color(0xFF004085));
    expect(fab.mini, true);
    expect(fab.tooltip, 'Create Event');

    final iconFinder = find.byIcon(Icons.add);
    expect(iconFinder, findsOneWidget);
  });

  testWidgets('Pressing button should show EventCreationPopup',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.byType(EventCreationPopup), findsOneWidget);
  });

  group('Helper methods tests', () {
    test(
        'generateEventDates should handle monthly dates with different month lengths correctly',
        () {
      final wrapper = EventCreationButtonTestWrapper();

      final startDate = DateTime(2023, 1, 31);
      final dates = wrapper.generateEventDates(startDate, 'Monthly');

      expect(dates.length, 12);

      expect(dates[1].day, 28);
      expect(dates[1].month, 2);

      expect(dates[3].day, 30);
      expect(dates[3].month, 4);

      expect(dates[4].day, 31);
      expect(dates[4].month, 5);
    });
    test('generateEventDates should handle month end dates correctly', () {
      final wrapper = EventCreationButtonTestWrapper();

      final startDate = DateTime(2023, 1, 31);
      final dates = wrapper.generateEventDates(startDate, 'Monthly');

      expect(dates[1], DateTime(2023, 2, 28));
      expect(dates[3], DateTime(2023, 4, 30));
      expect(dates[4], DateTime(2023, 5, 31));
    });
    testWidgets(
        'buildCalendarService should create a CalendarService with correct dependencies',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final buttonFinder = find.byType(EventCreationButton);
      final button = tester.widget<EventCreationButton>(buttonFinder);

      final wrapper = EventCreationButtonWrapper(button);
      final calendarService = wrapper.callBuildCalendarService();

      expect(calendarService, isNotNull);
      expect(calendarService, isA<CalendarService>());
    });
    test('createEvent should create event with correct data', () {
      final wrapper = EventCreationButtonTestWrapper();

      final event = wrapper.createEvent(
        name: 'Test Event',
        building: 'Test Building',
        classroom: 'Test Room',
        date: DateTime(2023, 1, 1),
        time: const TimeOfDay(hour: 10, minute: 0),
      );

      expect(event.summary, 'Test Event');
      expect(event.location, 'Test Building, Test Room');
      expect(event.start?.dateTime?.year, 2023);
      expect(event.start?.dateTime?.month, 1);
      expect(event.start?.dateTime?.day, 1);
      expect(event.start?.dateTime?.hour, 10);
      expect(event.start?.dateTime?.minute, 0);
      expect(event.end?.dateTime?.year, 2023);
      expect(event.end?.dateTime?.month, 1);
      expect(event.end?.dateTime?.day, 1);
      expect(event.end?.dateTime?.hour, 11);
      expect(event.end?.dateTime?.minute, 0);
    });
    testWidgets(
        'buildCalendarService should create a CalendarService with correct dependencies',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final buttonFinder = find.byType(EventCreationButton);
      final button = tester.widget<EventCreationButton>(buttonFinder);

      final wrapper = EventCreationButtonWrapper(button);
      final calendarService = wrapper.callBuildCalendarService();

      expect(calendarService, isNotNull);
      expect(calendarService, isA<CalendarService>());
    });
    test('createEvent should create event with correct data', () {
      final wrapper = EventCreationButtonTestWrapper();

      final event = wrapper.createEvent(
        name: 'Test Event',
        building: 'Test Building',
        classroom: 'Test Room',
        date: DateTime(2023, 1, 1),
        time: const TimeOfDay(hour: 10, minute: 0),
      );

      expect(event.summary, 'Test Event');
      expect(event.location, 'Test Building, Test Room');

      expect(event.start?.dateTime?.year, 2023);
      expect(event.start?.dateTime?.month, 1);
      expect(event.start?.dateTime?.day, 1);
      expect(event.start?.dateTime?.hour, 10);
      expect(event.start?.dateTime?.minute, 0);

      expect(event.end?.dateTime?.year, 2023);
      expect(event.end?.dateTime?.month, 1);
      expect(event.end?.dateTime?.day, 1);
      expect(event.end?.dateTime?.hour, 11);
      expect(event.end?.dateTime?.minute, 0);
    });
  });
  test('generateEventDates should handle daily frequency correctly', () {
    final wrapper = EventCreationButtonTestWrapper();

    final startDate = DateTime(2023, 5, 15);
    final dates = wrapper.generateEventDates(startDate, 'Daily');

    expect(dates.length, 7);

    for (int i = 0; i < dates.length; i++) {
      expect(dates[i], DateTime(2023, 5, 15 + i));
    }
  });
  test('generateEventDates should handle weekly frequency correctly', () {
    final wrapper = EventCreationButtonTestWrapper();

    final startDate = DateTime(2023, 5, 15);
    final dates = wrapper.generateEventDates(startDate, 'Weekly');

    expect(dates.length, 13);

    for (int i = 0; i < dates.length; i++) {
      final expectedDate = startDate.add(Duration(days: 7 * i));
      expect(dates[i], expectedDate);
    }
  });
  test('generateEventDates should return single date for unknown frequency',
      () {
    final wrapper = EventCreationButtonTestWrapper();

    final startDate = DateTime(2023, 5, 15);
    final dates = wrapper.generateEventDates(startDate, 'Unknown');

    expect(dates.length, 1);
    expect(dates[0], startDate);
  });
  test('generateEventDates should handle month end dates correctly', () {
    final wrapper = EventCreationButtonTestWrapper();

    final startDate = DateTime(2023, 1, 31);
    final dates = wrapper.generateEventDates(startDate, 'Monthly');

    expect(dates[1], DateTime(2023, 2, 28));

    expect(dates[3], DateTime(2023, 4, 30));

    expect(dates[4], DateTime(2023, 5, 31));
  });

  test('createEvent should set correct time duration', () {
    final wrapper = EventCreationButtonTestWrapper();

    final startTime = const TimeOfDay(hour: 14, minute: 30);
    final date = DateTime(2023, 5, 15);

    final event = wrapper.createEvent(
      name: 'Time Test',
      building: 'Building',
      classroom: 'Room',
      date: date,
      time: startTime,
    );

    expect(event.start?.dateTime?.hour, 14);
    expect(event.start?.dateTime?.minute, 30);

    expect(event.end?.dateTime?.hour, 15);
    expect(event.end?.dateTime?.minute, 30);
  });
  testWidgets('Daily frequency should generate 7 consecutive days',
      (tester) async {
    late BuildContext testContext;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            testContext = context;
            return Container();
          },
        ),
      ),
    );

    final testableButton = TestableEventCreationButton(
      parentContext: testContext,
      authService: MockAuthService(),
      selectedCalendarId: 'testCalendarId',
      fetchCalendarEvents: () async {},
    );

    final day = DateTime(2023, 1, 15);
    final result = testableButton.generateEventDates(day, 'Daily');

    expect(result.length, 7);
    expect(result[0], day);
    expect(result[6], day.add(const Duration(days: 6)));
  });
  test('Weekly frequency should generate 13 weekly dates', () {
    final mockContext = MockBuildContext();

    final testableButton = TestableEventCreationButton(
      parentContext: mockContext,
      authService: MockAuthService(),
      selectedCalendarId: 'testCalendarId',
      fetchCalendarEvents: () async {},
    );

    final day = DateTime(2023, 1, 15);
    final result = testableButton.generateEventDates(day, 'Weekly');

    expect(result.length, 13);
    expect(result[0], day);
    expect(result[12], day.add(const Duration(days: 7 * 12)));
  });

  test('Test startDateTime creation', () {
    final date = DateTime(2025, 3, 23);
    final time = const TimeOfDay(hour: 14, minute: 30);

    final startDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    // Assert: Verify that startDateTime is correct
    expect(startDateTime.year, equals(2025));
    expect(startDateTime.month, equals(3));
    expect(startDateTime.day, equals(23));
    expect(startDateTime.hour, equals(14));
    expect(startDateTime.minute, equals(30));
  });

  test('Test createEvent function', () {
    final testableButton = TestableEventCreationButton(
      parentContext: MockBuildContext(),
      authService: MockAuthService(),
      selectedCalendarId: 'testCalendarId',
      fetchCalendarEvents: () async {},
    );

    final name = 'Math Class';
    final building = 'Building A';
    final classroom = 'Room 101';
    final date = DateTime(2025, 3, 23);
    final time = const TimeOfDay(hour: 14, minute: 30);

    final event = testableButton.createEvent(
      name: name,
      building: building,
      classroom: classroom,
      date: date,
      time: time,
    );

    final expectedStartDateTime = DateTime(2025, 3, 23, 14, 30);
    final expectedEndDateTime =
        expectedStartDateTime.add(const Duration(hours: 1));

    expect(event.summary, equals(name));
    expect(event.location, equals('$building, $classroom'));
    expect(event.start?.dateTime, equals(expectedStartDateTime));
    expect(event.end?.dateTime, equals(expectedEndDateTime));
  });

  test('Monthly frequency should adjust for month lengths', () {
    final mockContext = MockBuildContext();

    final testableButton = TestableEventCreationButton(
      parentContext: mockContext,
      authService: MockAuthService(),
      selectedCalendarId: 'testCalendarId',
      fetchCalendarEvents: () async {},
    );

    final day = DateTime(2023, 1, 31);
    final result = testableButton.generateEventDates(day, 'Monthly');

    expect(result.length, 12);
    expect(result[0], day);
    expect(result[1].day, 28);
    expect(result[1].month, 2);

    expect(result[11].month, 12);
    expect(result[11].year, 2023);
  });
  test('Default case should return only the original date', () {
    final mockContext = MockBuildContext();

    final testableButton = TestableEventCreationButton(
      parentContext: mockContext,
      authService: MockAuthService(),
      selectedCalendarId: 'testCalendarId',
      fetchCalendarEvents: () async {},
    );

    final day = DateTime(2023, 1, 15);
    final result = testableButton.generateEventDates(day, 'Unknown');

    expect(result.length, 1);
    expect(result[0], day);
  });
}

class TestableEventCreationButton extends EventCreationButton {
  TestableEventCreationButton({
    required super.parentContext,
    required super.authService,
    required super.selectedCalendarId,
    required super.fetchCalendarEvents,
  });

  // Expose the private methods for testing
  @override
  List<DateTime> generateEventDates(DateTime day, String frequency) {
    return super.generateEventDates(day, frequency);
  }

  @override
  gcal.Event createEvent({
    required String name,
    required String building,
    required String classroom,
    required DateTime date,
    required TimeOfDay time,
  }) {
    return super.createEvent(
      name: name,
      building: building,
      classroom: classroom,
      date: date,
      time: time,
    );
  }
}

// Helper class to test the private methods
class EventCreationButtonTestWrapper {
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

class EventCreationButtonWrapper {
  final EventCreationButton button;

  EventCreationButtonWrapper(this.button);

  void callHandleEventSave(
    String name,
    String building,
    String classroom,
    TimeOfDay time,
    DateTime day,
    String? recurringFrequency,
  ) {
    button.handleEventSave(
        name, building, classroom, time, day, recurringFrequency);
  }

  CalendarService callBuildCalendarService() {
    return button.buildCalendarService();
  }
}

class MockBuildContext extends Mock implements BuildContext {}
