import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:soen_390/utils/building_search.dart';
import 'package:soen_390/screens/calendar/event_creation_widget.dart';

void main() {
  // Test to verify that all UI elements are correctly displayed in the EventCreationPopup
  testWidgets('EventCreationPopup UI elements are present',
      (WidgetTester tester) async {
    // Set up a test environment with the EventCreationPopup widget
    await tester.pumpWidget(
      MaterialApp(
        home: EventCreationPopup(
          onSave: (name, building, classroom, time, day, recurrence) {},
        ),
      ),
    );

    // Verify all expected UI elements are present
    expect(find.text('Create New Event'), findsOneWidget);
    expect(find.text('Event Name'), findsOneWidget);
    expect(find.text('Building'), findsOneWidget);
    expect(find.text('Classroom'), findsOneWidget);
    expect(find.text('Pick a date'), findsOneWidget);
    expect(find.text('Pick a time'), findsOneWidget);
    expect(find.text('Recurrence'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
    expect(find.byType(BuildingSearchField), findsOneWidget);
    expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
  });

  // Test to verify that text input fields accept and display entered text
  testWidgets('EventCreationPopup input fields accept text',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: EventCreationPopup(
          onSave: (name, building, classroom, time, day, recurrence) {},
        ),
      ),
    );

    // Enter text in the first two TextFormField widgets
    await tester.enterText(find.byType(TextFormField).at(0), 'Test Event Name');
    await tester.enterText(find.byType(TextFormField).at(1), 'Test Classroom');

    // Verify the entered text is visible
    expect(find.text('Test Event Name'), findsOneWidget);
    expect(find.text('Test Classroom'), findsOneWidget);
  });

  // Test to verify that the date picker widget works correctly
  testWidgets('EventCreationPopup date picker works',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: EventCreationPopup(
          onSave: (name, building, classroom, time, day, recurrence) {},
        ),
      ),
    );

    // Tap the calendar icon to open the date picker
    await tester.tap(find.byIcon(Icons.calendar_today));
    await tester.pumpAndSettle(); // Wait for animations to complete

    // Tap the OK button to confirm date selection
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    // Verify the date appears in the expected format (today's date)
    expect(find.text(DateFormat('yyyy-MM-dd').format(DateTime.now())),
        findsOneWidget);
  });

  // This test is a duplicate of the first test and should be removed or modified
  testWidgets('EventCreationPopup UI elements are present',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: EventCreationPopup(
          onSave: (name, building, classroom, time, day, recurrence) {},
        ),
      ),
    );
    expect(find.text('Create New Event'), findsOneWidget);
    expect(find.text('Event Name'), findsOneWidget);
    expect(find.text('Classroom'), findsOneWidget);
    expect(find.text('Pick a date'), findsOneWidget);
    expect(find.text('Pick a time'), findsOneWidget);
    expect(find.text('Recurrence'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
    expect(find.byType(BuildingSearchField), findsOneWidget);
    expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
  });

  // This test is a duplicate of the second test and should be removed or modified
  testWidgets('EventCreationPopup input fields accept text',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: EventCreationPopup(
          onSave: (name, building, classroom, time, day, recurrence) {},
        ),
      ),
    );
    await tester.enterText(find.byType(TextFormField).at(0), 'Test Event Name');
    await tester.enterText(find.byType(TextFormField).at(1), 'Test Classroom');
    expect(find.text('Test Event Name'), findsOneWidget);
    expect(find.text('Test Classroom'), findsOneWidget);
  });

  // This test is a duplicate of the third test and should be removed or modified
  testWidgets('EventCreationPopup date picker works',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: EventCreationPopup(
          onSave: (name, building, classroom, time, day, recurrence) {},
        ),
      ),
    );
    await tester.tap(find.byIcon(Icons.calendar_today));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.text(DateFormat('yyyy-MM-dd').format(DateTime.now())),
        findsOneWidget);
  });

  // Test to verify that the time picker widget works correctly
  testWidgets('EventCreationPopup time picker works',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: EventCreationPopup(
          onSave: (name, building, classroom, time, day, recurrence) {},
        ),
      ),
    );
    // Tap the time icon to open the time picker
    await tester.tap(find.byIcon(Icons.access_time));
    await tester.pumpAndSettle();
    // Tap OK to confirm time selection
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    // The time picker should update the button text, so it shouldn't say "Pick a time" anymore
    expect(find.text('Pick a time'), findsNothing);
  });

  // Test to verify that the cancel button closes the dialog
  testWidgets('EventCreationPopup cancel button works',
      (WidgetTester tester) async {
    bool dialogClosed = false;

    // Set up a test environment with a button that opens the dialog
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => EventCreationPopup(
                  onSave: (name, building, classroom, time, day, recurrence) {},
                ),
              ).then(
                  (_) => dialogClosed = true); // Set flag when dialog is closed
            },
            child: const Text('Show Dialog'),
          ),
        ),
      ),
    );

    // Open the dialog
    await tester.tap(find.text('Show Dialog'));
    await tester.pumpAndSettle();

    // Tap the cancel button
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    // Verify the dialog was closed
    expect(dialogClosed, true);
  });

  // Test to verify that form validation prevents submission when required fields are missing
  testWidgets(
      'EventCreationPopup validation prevents submission with missing fields',
      (WidgetTester tester) async {
    bool onSaveCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: EventCreationPopup(
          onSave: (name, building, classroom, time, day, recurrence) {
            onSaveCalled = true;
          },
        ),
      ),
    );

    // Try to submit without filling required fields
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // onSave should not be called due to validation
    expect(onSaveCalled, false);

    // Form should still be visible (dialog not closed)
    expect(find.text('Create New Event'), findsOneWidget);
  });

  // Test to verify that the onSave callback is called with the correct data when form is valid
  testWidgets('EventCreationPopup onSave callback is called with correct data',
      (WidgetTester tester) async {
    // Variables to capture the values passed to onSave
    String? savedName;
    String? savedBuilding;
    String? savedClassroom;
    TimeOfDay? savedTime;
    DateTime? savedDay;
    String? savedRecurrence;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          // Add Scaffold for proper context
          body: EventCreationPopup(
            onSave: (name, building, classroom, time, day, recurrence) {
              // Capture all values passed to onSave
              savedName = name;
              savedBuilding = building;
              savedClassroom = classroom;
              savedTime = time;
              savedDay = day;
              savedRecurrence = recurrence;
            },
          ),
        ),
      ),
    );

    // Fill all required fields
    await tester.enterText(find.byType(TextFormField).at(0), 'Test Event');
    await tester.enterText(find.byType(TextFormField).at(1), 'Room 301');

    // Select building using the custom BuildingSearchField
    final buildingSearchField =
        tester.widget<BuildingSearchField>(find.byType(BuildingSearchField));
    buildingSearchField.onSelected?.call('Test Building');

    // Select date
    await tester.tap(find.byIcon(Icons.calendar_today));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    // Select time
    await tester.tap(find.byIcon(Icons.access_time));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    // Select recurrence from dropdown
    // Find the dropdown button and tap it
    final dropdownFinder = find.byType(DropdownButtonFormField<String>);
    await tester.ensureVisible(dropdownFinder); // Ensure it's visible
    await tester.tap(dropdownFinder);
    await tester.pumpAndSettle();

    // Select the 'Weekly' option from the dropdown menu
    // Using .last because there might be multiple "Weekly" elements in the widget tree
    await tester.tap(find.text('Weekly').last, warnIfMissed: false);
    await tester.pumpAndSettle();

    // Submit form
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // Verify callback was called with correct data
    expect(savedName, 'Test Event');
    expect(savedBuilding, 'Test Building');
    expect(savedClassroom, 'Room 301');
    expect(savedTime, isNotNull);
    expect(savedDay, isNotNull);
    expect(savedRecurrence, 'Weekly');
  });

  // Test to verify that widget state is properly reset when dialog is reopened
  testWidgets('EventCreationPopup handles widget state disposal properly',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => EventCreationPopup(
                  onSave: (name, building, classroom, time, day, recurrence) {},
                ),
              );
            },
            child: const Text('Show Dialog'),
          ),
        ),
      ),
    );

    // Open dialog
    await tester.tap(find.text('Show Dialog'));
    await tester.pumpAndSettle();

    // Enter text in fields
    await tester.enterText(find.byType(TextFormField).at(0), 'Test Event');

    // Close dialog
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    // Reopen dialog and check if state is reset
    await tester.tap(find.text('Show Dialog'));
    await tester.pumpAndSettle();

    // Verify field is empty (state should be reset)
    expect(find.text('Test Event'), findsNothing);
  });

  // Test to verify that form maintains state during scrolling
  testWidgets('EventCreationPopup form maintains state during scrolling',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: EventCreationPopup(
          onSave: (name, building, classroom, time, day, recurrence) {},
        ),
      ),
    );

    // Enter text in the first field
    await tester.enterText(find.byType(TextFormField).at(0), 'Test Event Name');

    // Scroll down to see the rest of the form
    await tester.drag(
        find.byType(SingleChildScrollView), const Offset(0, -300));
    await tester.pumpAndSettle();

    // Scroll back up
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, 300));
    await tester.pumpAndSettle();

    // Verify the text is still there (state maintained during scrolling)
    expect(find.text('Test Event Name'), findsOneWidget);
  });

  // Test to verify form validation for null values
  testWidgets('EventCreationPopup validation handles null values properly',
      (WidgetTester tester) async {
    bool onSaveCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: EventCreationPopup(
          onSave: (name, building, classroom, time, day, recurrence) {
            onSaveCalled = true;
          },
        ),
      ),
    );

    // Enter text only in the required text fields
    await tester.enterText(find.byType(TextFormField).at(0), 'Test Event');
    await tester.enterText(find.byType(TextFormField).at(1), 'Room 301');

    // Don't select building, time, or date (leaving them null)

    // Try to submit
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // Verify onSave was not called (validation should prevent submission)
    expect(onSaveCalled, false);
  });
}
