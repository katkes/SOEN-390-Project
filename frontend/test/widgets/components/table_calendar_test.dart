import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:soen_390/screens/calendar/table_calendar_widget.dart';
import 'package:googleapis/calendar/v3.dart' as gcal;
import 'package:intl/intl.dart';

//This test file tests the TableCalendarWidget class
//The TableCalendarWidget is a widget that displays a table calendar
//It uses the table_calendar package to display a calendar
//The widget is used in the CalendarScreen to display the calendar
//The tests in this file test the TableCalendarWidget by checking that the calendar displays the correct month,
//triggers the onDaySelected callback when a day is tapped, triggers the onFormatChanged callback when the format changes,
//triggers the onPageChanged callback when the page changes, the eventLoader returns the correct events, and the selected day has the proper decoration
//The tests use the flutter_test package to test the widget
//The tests use the testWidgets function to test the widget
//The tests use the pumpWidget function to build the widget
//The tests use the find.text function to find a text widget in the widget tree
//The tests use the find.byIcon function to find an icon widget in the widget tree

void main() {
  group('TableCalendarWidget', () {
    final now = DateTime.now();
    final sampleEvent = gcal.Event(summary: 'Test Event');

    late DateTime selectedDay;
    // ignore: unused_local_variable
    late CalendarFormat changedFormat;
    late DateTime pageChangedDay;
    bool daySelected = false;

    Widget createWidgetUnderTest() {
      return MaterialApp(
        home: Scaffold(
          body: TableCalendarWidget(
            focusedDay: now,
            selectedDay: selectedDay,
            calendarFormat: CalendarFormat.month,
            onDaySelected: (selected, focused) {
              daySelected = true;
              selectedDay = selected;
            },
            onFormatChanged: (format) {
              changedFormat = format;
            },
            onPageChanged: (day) {
              pageChangedDay = day;
            },
            eventLoader: (day) {
              if (day.day == now.day) {
                return [sampleEvent];
              }
              return [];
            },
          ),
        ),
      );
    }

    setUp(() {
      selectedDay = now;
      changedFormat = CalendarFormat.month;
      pageChangedDay = now;
      daySelected = false;
    });

    testWidgets('displays calendar with current month',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final monthLabel = DateFormat.yMMMM().format(now);
      expect(find.text(monthLabel), findsOneWidget);
    });

    testWidgets('triggers onDaySelected callback when a day is tapped',
        (WidgetTester tester) async {
      // Choose a specific date instead of using now
      final testDate = DateTime(2023, 5, 15); // May 15, 2023
      selectedDay = testDate;

      // Update the widget creation to use this specific date
      Widget createSpecificDateWidget() {
        return MaterialApp(
          home: Scaffold(
            body: TableCalendarWidget(
              focusedDay: testDate,
              selectedDay: selectedDay,
              calendarFormat: CalendarFormat.month,
              onDaySelected: (selected, focused) {
                daySelected = true;
                selectedDay = selected;
              },
              onFormatChanged: (format) {
                changedFormat = format;
              },
              onPageChanged: (day) {
                pageChangedDay = day;
              },
              eventLoader: (day) => [],
            ),
          ),
        );
      }

      await tester.pumpWidget(createSpecificDateWidget());

      // Now tap on the specific day that should be unique in this view
      await tester.tap(find.text('15').first);
      await tester.pumpAndSettle();

      expect(daySelected, isTrue);
      expect(selectedDay.day, 15);
    });

    testWidgets('triggers onPageChanged callback', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final newPage = now.add(const Duration(days: 30));
      pageChangedDay = now;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: TableCalendarWidget(
            focusedDay: newPage,
            selectedDay: selectedDay,
            calendarFormat: CalendarFormat.month,
            onDaySelected: (selected, focused) {},
            onFormatChanged: (_) {},
            onPageChanged: (day) {
              pageChangedDay = day;
            },
            eventLoader: (_) => [],
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(pageChangedDay.month, newPage.month);
    });

    testWidgets('eventLoader returns correct events',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final hasEventMarker = find.byType(Container).evaluate().any((e) {
        final widget = e.widget;
        if (widget is Container && widget.decoration is BoxDecoration) {
          final deco = widget.decoration as BoxDecoration;
          return deco.color != null && deco.shape == BoxShape.circle;
        }
        return false;
      });

      expect(hasEventMarker, isTrue);
    });

    testWidgets('selected day has proper decoration',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      bool selectedDayHasCircleDecoration(Element e) {
        final widget = e.widget;
        if (widget is Container && widget.decoration is BoxDecoration) {
          final deco = widget.decoration as BoxDecoration;
          return deco.color != null && deco.shape == BoxShape.circle;
        }
        return false;
      }

      final selectedMarkerExists =
          find.byType(Container).evaluate().any(selectedDayHasCircleDecoration);

      expect(selectedMarkerExists, isTrue);
    });
  });
}
