import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soen_390/screens/shuttle_bus/shuttle_schedule_screen.dart';
import 'package:soen_390/services/shuttle_service.dart';
import 'package:soen_390/styles/theme.dart';

class MockShuttleService extends ShuttleService {
  @override
  ShuttleSchedule getFridaySchedule() {
    return ShuttleSchedule(
      loyDepartures: ['9:15', '10:15', '11:15'],
      sgwDepartures: ['9:45', '10:45', '11:45'],
      lastBus: {'LOY': '18:15', 'SGW': '18:15'},
      stops: {
        'LOY': ShuttleStopLocation(name: 'LOY', coordinates: '45°27\'28.2"N 73°38\'20.3"W'),
        'SGW': ShuttleStopLocation(name: 'SGW', coordinates: '45°29\'49.6"N 73°34\'42.5"W'),
      },
    );
  }
}

void main() {

  testWidgets('ShuttleScheduleScreen displays AppBar with correct title', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: appTheme,
        home: const ShuttleScheduleScreen(),
      ),
    );

    expect(find.byType(AppBar), findsOneWidget);
    expect(find.text('Shuttle Schedule'), findsOneWidget);
  });

  testWidgets('ShuttleScheduleScreen applies correct padding and styling', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: appTheme,
        home: const ShuttleScheduleScreen(),
      ),
    );

    final singleChildScrollViewFinder = find.byType(SingleChildScrollView);
    expect(singleChildScrollViewFinder, findsOneWidget);

    final SingleChildScrollView scrollView = tester.widget(singleChildScrollViewFinder);
    expect(scrollView.padding, const EdgeInsets.all(16.0));
  });
}

