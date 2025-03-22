import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:googleapis/calendar/v3.dart' as gcal;
import 'package:intl/intl.dart';
import 'package:mockito/mockito.dart';
import 'package:soen_390/services/calendar_service.dart';
import 'package:soen_390/screens/calendar/calendar_event_service.dart';
import 'package:soen_390/screens/calendar/event_edit_popup.dart';

class MockCalendarService extends Mock implements CalendarService {}

class MockCalendarEventService extends Mock implements CalendarEventService {}

void main() {
  late MockCalendarService mockCalendarService;
  late MockCalendarEventService mockCalendarEventService;
  late gcal.Event testEvent;
  final String testCalendarId = 'testCalendarId';

  setUp(() {
    mockCalendarService = MockCalendarService();
    mockCalendarEventService = MockCalendarEventService();
    testEvent = gcal.Event()
      ..id = 'testId'
      ..summary = 'Test Event'
      ..location = 'Test Building, Test Classroom'
      ..description = 'Test Description'
      ..start = gcal.EventDateTime(dateTime: DateTime(2023, 1, 1, 10, 0))
      ..end = gcal.EventDateTime(dateTime: DateTime(2023, 1, 1, 11, 0));
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => EventEditPopup(
                  event: testEvent,
                  calendarService: mockCalendarService,
                  calendarEventService: mockCalendarEventService,
                  calendarId: testCalendarId,
                ),
              );
            },
            child: const Text('Open Dialog'),
          ),
        ),
      ),
    );
  }

  testWidgets('EventEditPopup displays event details',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    expect(find.text('Edit Event'), findsOneWidget);
    expect(find.text('Test Event'), findsOneWidget);
    expect(find.text('Test Building'), findsOneWidget);
    expect(find.text('Test Classroom'), findsOneWidget);
    expect(
        find.text(
            DateFormat('yyyy-MM-dd HH:mm').format(DateTime(2023, 1, 1, 10, 0))),
        findsOneWidget);
    expect(
        find.text(
            DateFormat('yyyy-MM-dd HH:mm').format(DateTime(2023, 1, 1, 11, 0))),
        findsOneWidget);
  });

  testWidgets('EventEditPopup updates date and time',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Start Time'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('End Time'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(
        find.text(
            DateFormat('yyyy-MM-dd HH:mm').format(DateTime(2023, 1, 1, 10, 0))),
        findsOneWidget);
    expect(
        find.text(
            DateFormat('yyyy-MM-dd HH:mm').format(DateTime(2023, 1, 1, 11, 0))),
        findsOneWidget);
  });
}
