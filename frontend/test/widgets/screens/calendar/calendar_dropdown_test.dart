import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:googleapis/calendar/v3.dart' as gcal;
import 'package:soen_390/screens/calendar/calendar_dropdown.dart';

/// Test the CalendarDropdown widget
/// The CalendarDropdown is a custom dropdown widget that displays a list of calendars
/// The CalendarDropdown is used in the CalendarScreen to display a dropdown menu of calendars
/// The tests in this file test the CalendarDropdown by checking that the dropdown displays the correct calendars,
/// triggers the onCalendarSelected callback when a calendar is selected, and handles the case when the selectedCalendarId is null
void main() {
  late List<gcal.CalendarListEntry> mockCalendars;

  setUp(() {
    // Setup mock calendars for testing
    mockCalendars = [
      gcal.CalendarListEntry()
        ..id = 'calendar1'
        ..summary = 'Test Calendar 1',
      gcal.CalendarListEntry()
        ..id = 'calendar2'
        ..summary = 'Test Calendar 2',
      gcal.CalendarListEntry()
        ..id = 'calendar3'
        ..summary = null, // Testing null summary case
    ];
  });
  testWidgets('CalendarDropdown handles null selectedCalendarId',
      (WidgetTester tester) async {
    String? selectedId;
    void mockCallback(String? calendarId) {
      selectedId = calendarId;
    }

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CalendarDropdown(
            calendars: mockCalendars,
            selectedCalendarId: null,
            onCalendarSelected: mockCallback,
          ),
        ),
      ),
    );

    expect(find.byType(DropdownButton<String>), findsOneWidget);

    // Open dropdown
    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();

    // Select a calendar
    await tester.tap(find.text('Test Calendar 1').last);
    await tester.pumpAndSettle();

    // Verify callback
    expect(selectedId, 'calendar1');
  });

  testWidgets('CalendarDropdown handles empty calendar list',
      (WidgetTester tester) async {
    // Setup
    void mockCallback(String? calendarId) {}

    // Build widget with empty calendar list
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CalendarDropdown(
            calendars: [],
            selectedCalendarId: null,
            onCalendarSelected: mockCallback,
          ),
        ),
      ),
    );

    // Verify dropdown exists but has no items
    expect(find.byType(DropdownButton<String>), findsOneWidget);

    // Verify no dropdown items
    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
    expect(find.byType(DropdownMenuItem<String>), findsNothing);
  });
}
