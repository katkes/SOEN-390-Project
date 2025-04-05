import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soen_390/services/shuttle_service.dart';
import 'package:soen_390/styles/theme.dart';
import 'package:soen_390/widgets/shuttle_schedule_dispaly.dart';

void main() {
  final mockSchedule = ShuttleSchedule(
    loyDepartures: ['9:15', '10:15', '11:15'],
    sgwDepartures: ['9:45', '10:45', '11:45'],
    lastBus: {'LOY': '18:15', 'SGW': '18:15'},
    stops: {
      'LOY': ShuttleStopLocation(name: 'LOY', coordinates: '45°27\'28.2"N 73°38\'20.3"W'),
      'SGW': ShuttleStopLocation(name: 'SGW', coordinates: '45°29\'49.6"N 73°34\'42.5"W'),
    },
  );

  testWidgets('ShuttleScheduleDisplay shows correct title', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: appTheme,
        home: Scaffold(
          body: ShuttleScheduleDisplay(fridaySchedule: mockSchedule),
        ),
      ),
    );

    expect(find.text('Shuttle Bus Schedule (Friday)'), findsOneWidget);
  });

  testWidgets('ShuttleScheduleDisplay shows LOY departures section', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: appTheme,
        home: Scaffold(
          body: ShuttleScheduleDisplay(fridaySchedule: mockSchedule),
        ),
      ),
    );

    expect(find.text('LOY Departures'), findsOneWidget);
    for (var time in mockSchedule.loyDepartures) {
      expect(find.text(time), findsOneWidget);
    }
  });

  testWidgets('ShuttleScheduleDisplay shows SGW departures section', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: appTheme,
        home: Scaffold(
          body: ShuttleScheduleDisplay(fridaySchedule: mockSchedule),
        ),
      ),
    );

    expect(find.text('SGW Departures'), findsOneWidget);
    for (var time in mockSchedule.sgwDepartures) {
      expect(find.text(time), findsOneWidget);
    }
  });

  testWidgets('ShuttleScheduleDisplay shows stop locations', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: appTheme,
        home: Scaffold(
          body: ShuttleScheduleDisplay(fridaySchedule: mockSchedule),
        ),
      ),
    );

    expect(find.text('Stop Locations'), findsOneWidget);
    expect(find.text('LOY: 45°27\'28.2"N 73°38\'20.3"W'), findsOneWidget);
    expect(find.text('SGW: 45°29\'49.6"N 73°34\'42.5"W'), findsOneWidget);
  });

  testWidgets('ShuttleScheduleDisplay includes location icons', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: appTheme,
        home: Scaffold(
          body: ShuttleScheduleDisplay(fridaySchedule: mockSchedule),
        ),
      ),
    );

    expect(find.byIcon(Icons.location_on), findsNWidgets(2)); // One for each stop
  });

  testWidgets('ShuttleScheduleDisplay renders chips correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: appTheme,
        home: Scaffold(
          body: ShuttleScheduleDisplay(fridaySchedule: mockSchedule),
        ),
      ),
    );

    // Total number of chips should equal the total number of departure times
    final totalTimes = mockSchedule.loyDepartures.length + mockSchedule.sgwDepartures.length;
    expect(find.byType(Chip), findsNWidgets(totalTimes));
  });

  testWidgets('ShuttleScheduleDisplay has correct styling', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: appTheme,
        home: Scaffold(
          body: ShuttleScheduleDisplay(fridaySchedule: mockSchedule),
        ),
      ),
    );

    // Verify container exists with decoration
    final containerFinder = find.byType(Container).first;
    final Container container = tester.widget(containerFinder);
    expect(container.margin, const EdgeInsets.all(16));
    expect(container.padding, const EdgeInsets.all(16));
    
    final BoxDecoration decoration = container.decoration as BoxDecoration;
    expect(decoration.borderRadius, BorderRadius.circular(20));
    expect(decoration.boxShadow?.length, 1);
  });

  testWidgets('ShuttleScheduleDisplay _buildScheduleList creates correct widgets', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: appTheme,
        home: Scaffold(
          body: ShuttleScheduleDisplay(fridaySchedule: mockSchedule),
        ),
      ),
    );

    // Verify column structure for each schedule list
    expect(find.byType(Column), findsAtLeast(3)); // At least 3 columns (main + 2 for schedule lists)
    expect(find.byType(Wrap), findsAtLeast(2)); // At least 2 wraps (one for each departure list)
  });

}
