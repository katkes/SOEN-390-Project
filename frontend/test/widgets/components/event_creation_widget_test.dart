import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:soen_390/utils/building_search.dart';
import 'package:soen_390/screens/calendar/event_creation_widget.dart';

void main() {
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
}
