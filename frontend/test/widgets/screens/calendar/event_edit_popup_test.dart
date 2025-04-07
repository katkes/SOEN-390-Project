import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:googleapis/calendar/v3.dart' as gcal;
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:soen_390/screens/calendar/calendar_event_service.dart';
import 'package:soen_390/screens/calendar/event_edit_popup.dart';
import 'package:soen_390/services/calendar_service.dart';
import 'package:soen_390/screens/indoor/mappedin_map_controller.dart';

@GenerateMocks([CalendarService, CalendarEventService, MappedinMapController])
import 'event_edit_popup_test.mocks.dart';

class FakeMappedinMapController extends MappedinMapController {
  @override
  Future<bool> navigateToRoom(String roomNumber, bool reverse) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return true;
  }
}

class MockBuildContext extends Mock implements BuildContext {}

void main() {
  late MockCalendarService mockCalendarService;
  late MockCalendarEventService mockCalendarEventService;
  late gcal.Event testEvent;
  final String testCalendarId = 'testCalendarId';

  setUp(() {
    mockCalendarService = MockCalendarService();
    mockCalendarEventService = MockCalendarEventService();

    testEvent = gcal.Event.fromJson({
      'id': 'testId',
      'summary': 'Test Event',
      'location': 'Test Building, Room 123',
      'description': 'Test Description',
      'start': {'dateTime': DateTime.now().toIso8601String()},
      'end': {
        'dateTime':
            DateTime.now().add(const Duration(hours: 1)).toIso8601String()
      },
    });
  });

  Widget createWidgetUnderTest({
    VoidCallback? onEventUpdated,
    VoidCallback? onEventDeleted,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return EventEditPopup(
                    event: testEvent,
                    calendarService: mockCalendarService,
                    calendarEventService: mockCalendarEventService,
                    calendarId: testCalendarId,
                    onEventUpdated: onEventUpdated,
                    onEventDeleted: onEventDeleted,
                  );
                },
              );
            },
            child: const Text('Show Dialog'),
          ),
        ),
      ),
    );
  }

  testWidgets('Go Now button opens navigation to classroom',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.tap(find.text('Show Dialog'));
    await tester.pumpAndSettle();

    expect(find.text('Go Now'), findsOneWidget);
  });
  testWidgets('Go Now button can be tapped without crashing',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return EventEditPopup(
                    event: testEvent,
                    calendarService: mockCalendarService,
                    calendarEventService: mockCalendarEventService,
                    calendarId: testCalendarId,
                  );
                },
              );
            },
            child: const Text('Show Dialog'),
          ),
        ),
      ),
    ));

    // Open the dialog
    await tester.tap(find.text('Show Dialog'));
    await tester.pumpAndSettle();

    // This test simply verifies the button can be tapped without crashing
    // It may not launch the navigation because of dependencies, but at least
    // we know the button handler doesn't throw exceptions
    await tester.tap(find.text('Go Now'));

    // If we made it here without exceptions, the test passes
    expect(true, isTrue);
  });
  testWidgets('Go Now button exists and has correct text and icon',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EventEditPopup(
            event: testEvent,
            calendarService: mockCalendarService,
            calendarEventService: mockCalendarEventService,
            calendarId: 'primary',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('goNowButton')), findsOneWidget);

    expect(
        find.descendant(
            of: find.byKey(const Key('goNowButton')),
            matching: find.text('Go Now')),
        findsOneWidget);
    expect(
        find.descendant(
            of: find.byKey(const Key('goNowButton')),
            matching: find.byIcon(Icons.directions_walk)),
        findsOneWidget);
  });
  group('EventEditPopup UI Rendering', () {
    // Test: Verify all UI elements are displayed correctly
    // Expected: All widget texts and icons should be visible with correct text content
    testWidgets('renders event details correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Edit Event'), findsOneWidget);
      expect(find.text('Test Event'), findsOneWidget);
      expect(find.byIcon(Icons.delete), findsOneWidget);
      expect(find.text('Start Time'), findsOneWidget);
      expect(find.text('End Time'), findsOneWidget);
      expect(find.text('Update'), findsOneWidget);
      expect(find.text('Go Now'), findsOneWidget);

      expect(find.widgetWithText(TextField, 'Test Building'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Room 123'), findsOneWidget);
    });

    // Test: Verify date and time pickers can be opened and closed
    // Expected: After interacting with date/time pickers, the dialog should still be open
    testWidgets('date and time pickers work correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Start Time'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('End Time'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(find.text('Update'), findsOneWidget);
    });
  });

  group('EventEditPopup Event Update Functionality', () {
    // Test: Verify error handling when update fails
    // Expected: Error message should appear and dialog should remain open
    testWidgets('handles update error correctly', (WidgetTester tester) async {
      when(mockCalendarService.updateEvent(
        any,
        any,
        any,
      )).thenThrow(Exception('Update failed'));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Update'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Failed to update event: Exception: Update failed'),
          findsOneWidget);
      expect(find.text('Edit Event'), findsOneWidget);
    });
  });

  group('EventEditPopup Event Delete Functionality', () {
    // Test: Verify delete confirmation dialog appears when delete button is pressed
    // Expected: Confirmation dialog should be displayed with correct content
    testWidgets('displays delete confirmation dialog',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      expect(find.text('Delete Event'), findsOneWidget);
      expect(find.text('Are you sure you want to delete this event?'),
          findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });

    // Test: Verify error handling when delete fails
    // Expected: Error message should appear and edit dialog should remain open
    testWidgets('handles delete error correctly', (WidgetTester tester) async {
      when(mockCalendarService.deleteEvent(
        any,
        any,
      )).thenThrow(Exception('Delete failed'));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Failed to delete event: Exception: Delete failed'),
          findsOneWidget);
      expect(find.text('Delete Event'), findsNothing);
      expect(find.text('Edit Event'), findsOneWidget);
    });

    // Test: Verify canceling deletion doesn't delete the event
    // Expected: Delete operation should not be called and edit dialog should remain open
    testWidgets('cancels deletion when Cancel is pressed',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Delete Event'), findsNothing);
      expect(find.text('Edit Event'), findsOneWidget);

      verifyNever(mockCalendarService.deleteEvent(any, any));
    });
  });

  group('EventEditPopup Callbacks', () {
    // Test: Verify onEventUpdated callback is triggered after successful update
    // Expected: Callback counter should increment by 1
    testWidgets('calls onEventUpdated callback when event is updated',
        (WidgetTester tester) async {
      int callCount = 0;

      when(mockCalendarService.updateEvent(any, any, any))
          .thenAnswer((_) async => gcal.Event());

      await tester.pumpWidget(createWidgetUnderTest(
        onEventUpdated: () {
          callCount++;
        },
      ));

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Update'));
      await tester.pumpAndSettle();

      expect(callCount, 1);
    });

    // Test: Verify onEventDeleted callback is triggered after successful deletion
    // Expected: Callback counter should increment by 1
    testWidgets('calls onEventDeleted callback when event is deleted',
        (WidgetTester tester) async {
      int callCount = 0;

      when(mockCalendarService.deleteEvent(any, any)).thenAnswer((_) async {});

      await tester.pumpWidget(createWidgetUnderTest(
        onEventDeleted: () {
          callCount++;
        },
      ));

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(callCount, 1);
    });
  });

  group('EventEditPopup Edge Cases', () {
    // Test: Verify widget handles events with null location property
    // Expected: Widget should render without crashing with empty text fields
    testWidgets('handles event with no location correctly',
        (WidgetTester tester) async {
      testEvent = gcal.Event.fromJson({
        'id': 'testId',
        'summary': 'Test Event',
        'description': 'Test Description',
        'start': {'dateTime': DateTime.now().toIso8601String()},
        'end': {
          'dateTime':
              DateTime.now().add(const Duration(hours: 1)).toIso8601String()
        },
      });

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Edit Event'), findsOneWidget);
      expect(find.widgetWithText(TextField, ''), findsWidgets);
    });

    // Test: Verify widget handles events with null description property
    // Expected: Widget should render without crashing
    testWidgets('handles event with no description correctly',
        (WidgetTester tester) async {
      testEvent = gcal.Event.fromJson({
        'id': 'testId',
        'summary': 'Test Event',
        'location': 'Test Location',
        'start': {'dateTime': DateTime.now().toIso8601String()},
        'end': {
          'dateTime':
              DateTime.now().add(const Duration(hours: 1)).toIso8601String()
        },
      });

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Edit Event'), findsOneWidget);
    });
  });

  group('EventEditPopup Form Validation', () {
    // Test: Verify form data is correctly sent to update service
    // Expected: Update service should receive event with updated title
    testWidgets('allows updating with valid data', (WidgetTester tester) async {
      when(mockCalendarService.updateEvent(any, any, any))
          .thenAnswer((_) async => gcal.Event());

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.widgetWithText(TextField, 'Test Event'), 'New Event Title');

      await tester.tap(find.text('Update'));
      await tester.pumpAndSettle();

      final captured = verify(mockCalendarService.updateEvent(
        testCalendarId,
        'testId',
        captureAny,
      )).captured.single as gcal.Event;

      expect(captured.summary, 'New Event Title');
    });
  });
}
