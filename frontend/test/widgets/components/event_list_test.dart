import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:googleapis/calendar/v3.dart' as gcal;
import 'package:intl/intl.dart';
import 'package:soen_390/screens/calendar/event_list_widget.dart';
import 'package:soen_390/screens/calendar/event_edit_popup.dart';
import 'package:soen_390/repositories/calendar_repository.dart';

///This test file tests the EventListWidget class
///The EventListWidget is a widget that displays a list of events
///The widget is used in the CalendarScreen to display the events for a selected day
///The tests in this file test the EventListWidget by checking that the widget displays a message when the event list is empty,
///displays a list of events with the time, displays an event with "No Title" if the summary is null, and does not display the time if the start.dateTime is null
///The tests use the flutter_test package to test the widget
///The tests use the testWidgets function to test the widget
///
///

import 'package:mockito/mockito.dart';
import 'package:soen_390/services/calendar_service.dart';
import 'package:soen_390/screens/calendar/calendar_event_service.dart';

class MockCalendarService extends Mock implements CalendarService {
  @override
  Future<gcal.Event?> updateEvent(
      String calendarId, String eventId, gcal.Event event) async {
    return event;
  }
}

class MockCalendarEventService extends Mock implements CalendarEventService {}

class MockCalendarRepository extends Mock implements CalendarRepository {}

void main() {
  late MockCalendarService mockCalendarService;
  late MockCalendarEventService mockCalendarEventService;
  late MockCalendarRepository mockCalendarRepository;
  late List<gcal.Event> fakeEvents;
  final String testCalendarId = 'testCalendarId';
  setUp(() {
    mockCalendarService = MockCalendarService();
    mockCalendarEventService = MockCalendarEventService();
    mockCalendarRepository = MockCalendarRepository();

    fakeEvents = [
      gcal.Event()
        ..summary = 'Event 1'
        ..start = gcal.EventDateTime(dateTime: DateTime(2023, 3, 22, 10, 0))
        ..end = gcal.EventDateTime(dateTime: DateTime(2023, 3, 22, 11, 0))
        ..location = 'Test Location 1',
      gcal.Event()
        ..summary = 'Event 2'
        ..start = gcal.EventDateTime(dateTime: DateTime(2023, 3, 22, 14, 0))
        ..end = gcal.EventDateTime(dateTime: DateTime(2023, 3, 22, 15, 0))
        ..location = 'Test Location 2',
    ];
  });
  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: Scaffold(
        body: EventListWidget(
          events: fakeEvents,
          calendarService: mockCalendarService,
          calendarEventService: mockCalendarEventService,
          calendarId: testCalendarId,
          onEventChanged: () {},
        ),
      ),
    );
  }

  testWidgets('EventListWidget renders events correctly', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Event 1'), findsOneWidget);
    expect(find.text('Event 2'), findsOneWidget);
    expect(find.text('Test Location 1'), findsOneWidget);
    expect(find.text('Test Location 2'), findsOneWidget);
  });

  testWidgets('EventListWidget opens event edit popup when tapped',
      (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    await tester.tap(find.text('Event 1'));
    await tester.pumpAndSettle();

    expect(find.byType(EventEditPopup), findsOneWidget);
  });

// Write me a test to handle empty events
  testWidgets('handle empty events list', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EventListWidget(
            events: [],
            calendarService: mockCalendarService,
            calendarEventService: mockCalendarEventService,
            calendarId: testCalendarId,
            onEventChanged: () {},
          ),
        ),
      ),
    );

    // Check if the "No events for selected day" message is displayed when the events list is empty.
    expect(find.text('No events for selected day'), findsOneWidget);
  });

  group('EventListWidget', () {
    testWidgets('displays message when event list is empty',
        (WidgetTester tester) async {
      final calendarService = MockCalendarService();
      final calendarEventService = MockCalendarEventService();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EventListWidget(
              events: const [],
              calendarService: calendarService,
              calendarEventService: calendarEventService,
              calendarId: 'test',
            ),
          ),
        ),
      );

      expect(find.text('No events for selected day'), findsOneWidget);
    });

    testWidgets('displays list of events with time',
        (WidgetTester tester) async {
      final calendarService = MockCalendarService();
      final calendarEventService = MockCalendarEventService();

      final testDate = DateTime(2025, 3, 20, 14, 30);
      final testEvent = gcal.Event(
        summary: 'Test Event',
        start: gcal.EventDateTime(dateTime: testDate),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EventListWidget(
              events: [testEvent],
              calendarService: calendarService,
              calendarEventService: calendarEventService,
              calendarId: 'test',
            ),
          ),
        ),
      );

      expect(find.text('Test Event'), findsOneWidget);
      expect(find.text(DateFormat('h:mm a').format(testDate)), findsOneWidget);
      expect(find.byIcon(Icons.event), findsOneWidget);
    });

    testWidgets('displays event with "No Title" if summary is null',
        (WidgetTester tester) async {
      final calendarService = MockCalendarService();
      final calendarEventService = MockCalendarEventService();

      final testEvent = gcal.Event(
        summary: null,
        start: gcal.EventDateTime(dateTime: DateTime.now()),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EventListWidget(
              events: [testEvent],
              calendarService: calendarService,
              calendarEventService: calendarEventService,
              calendarId: 'test',
            ),
          ),
        ),
      );

      expect(find.text('No Title'), findsOneWidget);
    });

    testWidgets('does not display time if start.dateTime is null',
        (WidgetTester tester) async {
      final calendarService = MockCalendarService();
      final calendarEventService = MockCalendarEventService();

      final testEvent = gcal.Event(
        summary: 'No Time Event',
        start: gcal.EventDateTime(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EventListWidget(
              events: [testEvent],
              calendarService: calendarService,
              calendarEventService: calendarEventService,
              calendarId: 'test',
            ),
          ),
        ),
      );

      expect(find.text('No Time Event'), findsOneWidget);

      final listTile = tester.widget<ListTile>(find.byType(ListTile));
      final subtitle = listTile.subtitle as Column;

      expect(subtitle.children.isEmpty, isTrue);
    });
    testWidgets('does not display location if it is null or empty',
        (WidgetTester tester) async {
      // Mock Services
      final calendarService = MockCalendarService();
      final calendarEventService = MockCalendarEventService();

      final testEventNullLocation = gcal.Event(
        summary: 'Event with Null Location',
        start: gcal.EventDateTime(dateTime: DateTime.now()),
        location: null,
      );

      final testEventEmptyLocation = gcal.Event(
        summary: 'Event with Empty Location',
        start: gcal.EventDateTime(dateTime: DateTime.now()),
        location: '',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EventListWidget(
              events: [testEventNullLocation],
              calendarService: calendarService,
              calendarEventService: calendarEventService,
              calendarId: 'test',
            ),
          ),
        ),
      );

      expect(find.text('Event with Null Location'), findsOneWidget);
      expect(find.text('No Title'), findsNothing);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EventListWidget(
              events: [testEventEmptyLocation],
              calendarService: calendarService,
              calendarEventService: calendarEventService,
              calendarId: 'test',
            ),
          ),
        ),
      );

      expect(find.text('Event with Empty Location'), findsOneWidget);
      expect(find.text('No Title'), findsNothing);
    });
  });
}
