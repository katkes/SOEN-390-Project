import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soen_390/services/shuttle_service.dart';
import 'package:soen_390/widgets/shuttle_schedule_display.dart';

void main() {
  late ShuttleSchedule testFridaySchedule;
  late ShuttleSchedule testMondayThursdaySchedule;
  
  setUp(() {
    // Create test schedules without using ShuttleService directly
    testFridaySchedule = ShuttleSchedule(
      loyDepartures: ['9:15', '10:15'],
      sgwDepartures: ['9:45', '10:45'],
      lastBus: {'LOY': '18:15', 'SGW': '18:15'},
      stops: {
        'LOY': ShuttleStopLocation(name: 'LOY', coordinates: '45°27\'28.2"N 73°38\'20.3"W'),
        'SGW': ShuttleStopLocation(name: 'SGW', coordinates: '45°29\'49.6"N 73°34\'42.5"W')
      },
    );
    
    testMondayThursdaySchedule = ShuttleSchedule(
      loyDepartures: ['9:00', '10:00'],
      sgwDepartures: ['9:30', '10:30'],
      lastBus: {'LOY': '18:30', 'SGW': '18:30'},
      stops: {
        'LOY': ShuttleStopLocation(name: 'LOY', coordinates: '45°27\'28.2"N 73°38\'20.3"W'),
        'SGW': ShuttleStopLocation(name: 'SGW', coordinates: '45°29\'49.6"N 73°34\'42.5"W')
      },
    );
  });
  
  testWidgets('ShuttleScheduleDisplay shows Friday schedule by default', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ShuttleScheduleDisplay(
            fridaySchedule: testFridaySchedule,
            mondayThursdaySchedule: testMondayThursdaySchedule,
          ),
        ),
      ),
    );
    
    // Verify it shows Friday schedule initially
    expect(find.text('Shuttle Bus Schedule (Friday)'), findsOneWidget);
    expect(find.text('Show Mon-Thurs Schedule'), findsOneWidget);
    expect(find.text('LOY Departures'), findsOneWidget);
    expect(find.text('SGW Departures'), findsOneWidget);
    
    // Verify Friday departure times are displayed
    expect(find.text('9:15'), findsOneWidget);
    expect(find.text('10:15'), findsOneWidget);
    expect(find.text('9:45'), findsOneWidget);
    expect(find.text('10:45'), findsOneWidget);
    
    // Verify stop locations are displayed
    expect(find.text('Stop Locations'), findsOneWidget);
    expect(find.text("LOY: 45°27\'28.2\"N 73°38\'20.3\"W"), findsOneWidget);
    expect(find.text("SGW: 45°29\'49.6\"N 73°34\'42.5\"W"), findsOneWidget);
  });
  
  testWidgets('ShuttleScheduleDisplay toggles between schedules', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ShuttleScheduleDisplay(
            fridaySchedule: testFridaySchedule,
            mondayThursdaySchedule: testMondayThursdaySchedule,
          ),
        ),
      ),
    );
    
    // Verify it shows Friday schedule initially
    expect(find.text('Shuttle Bus Schedule (Friday)'), findsOneWidget);
    
    // Toggle to Monday-Thursday schedule
    await tester.tap(find.text('Show Mon-Thurs Schedule'));
    await tester.pump();
    
    // Verify it shows Monday-Thursday schedule
    expect(find.text('Shuttle Bus Schedule (Mon-Thurs)'), findsOneWidget);
    expect(find.text('Show Friday Schedule'), findsOneWidget);
    
    // Verify Monday-Thursday departure times are displayed
    expect(find.text('9:00'), findsOneWidget);
    expect(find.text('10:00'), findsOneWidget);
    expect(find.text('9:30'), findsOneWidget);
    expect(find.text('10:30'), findsOneWidget);
    
    // Toggle back to Friday schedule
    await tester.tap(find.text('Show Friday Schedule'));
    await tester.pump();
    
    // Verify it shows Friday schedule again
    expect(find.text('Shuttle Bus Schedule (Friday)'), findsOneWidget);
    expect(find.text('Show Mon-Thurs Schedule'), findsOneWidget);
  });
}
