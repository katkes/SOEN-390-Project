import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:googleapis/calendar/v3.dart' as gcal;
import 'package:intl/intl.dart';
import 'package:soen_390/screens/calendar/event_list_widget.dart';

///This test file tests the EventListWidget class
///The EventListWidget is a widget that displays a list of events
///The widget is used in the CalendarScreen to display the events for a selected day
///The tests in this file test the EventListWidget by checking that the widget displays a message when the event list is empty,
///displays a list of events with the time, displays an event with "No Title" if the summary is null, and does not display the time if the start.dateTime is null
///The tests use the flutter_test package to test the widget
///The tests use the testWidgets function to test the widget
///
void main() {
  group('EventListWidget', () {
    testWidgets('displays message when event list is empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EventListWidget(events: []),
          ),
        ),
      );

      expect(find.text('No events for selected day'), findsOneWidget);
    });

    testWidgets('displays list of events with time',
        (WidgetTester tester) async {
      final testDate = DateTime(2025, 3, 20, 14, 30);
      final testEvent = gcal.Event(
        summary: 'Test Event',
        start: gcal.EventDateTime(dateTime: testDate),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EventListWidget(events: [testEvent]),
          ),
        ),
      );

      expect(find.text('Test Event'), findsOneWidget);
      expect(find.text(DateFormat('h:mm a').format(testDate)), findsOneWidget);
      expect(find.byIcon(Icons.event), findsOneWidget);
    });

    testWidgets('displays event with "No Title" if summary is null',
        (WidgetTester tester) async {
      final testEvent = gcal.Event(
        summary: null,
        start: gcal.EventDateTime(dateTime: DateTime.now()),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EventListWidget(events: [testEvent]),
          ),
        ),
      );

      expect(find.text('No Title'), findsOneWidget);
    });

    testWidgets('does not display time if start.dateTime is null',
        (WidgetTester tester) async {
      final testEvent = gcal.Event(
        summary: 'No Time Event',
        start: gcal.EventDateTime(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EventListWidget(events: [testEvent]),
          ),
        ),
      );

      expect(find.text('No Time Event'), findsOneWidget);
      // Should only find the title, not a time string
      final tiles = tester.widget<ListTile>(find.byType(ListTile));
      expect(tiles.subtitle, isNull);
    });
  });
}
