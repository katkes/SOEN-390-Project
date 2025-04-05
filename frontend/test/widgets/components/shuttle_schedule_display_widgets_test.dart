import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soen_390/services/shuttle_service.dart';
import 'package:soen_390/widgets/shuttle_schedule_display_widgets.dart';

void main() {
  group('ScheduleList', () {
    testWidgets('ScheduleList renders correctly', (WidgetTester tester) async {
      const title = 'Test Schedule';
      final times = ['9:00', '10:00', '11:00'];
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScheduleList(
              title: title,
              times: times,
            ),
          ),
        ),
      );
      
      // Verify title is displayed
      expect(find.text(title), findsOneWidget);

      // Verify all times are displayed as Chips
      for (final time in times) {
        expect(find.text(time), findsOneWidget);
      }
      
      // Verify correct number of Chips
      expect(find.byType(Chip), findsNWidgets(times.length));
    });
    
    testWidgets('ScheduleList handles empty list', (WidgetTester tester) async {
      const title = 'Empty Schedule';
      final times = <String>[];
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScheduleList(
              title: title,
              times: times,
            ),
          ),
        ),
      );
      
      // Verify title is still displayed
      expect(find.text(title), findsOneWidget);
      
      // Verify no Chips are displayed
      expect(find.byType(Chip), findsNothing);
    });
  });
  
  group('StopLocations', () {
    testWidgets('StopLocations renders correctly', (WidgetTester tester) async {
      final schedule = ShuttleSchedule(
        loyDepartures: ['9:15'],
        sgwDepartures: ['9:45'],
        lastBus: {'LOY': '18:15', 'SGW': '18:15'},
        stops: {
          'LOY': ShuttleStopLocation(name: 'LOY', coordinates: '45°27\'28.2"N 73°38\'20.3"W'),
          'SGW': ShuttleStopLocation(name: 'SGW', coordinates: '45°29\'49.6"N 73°34\'42.5"W')
        },
      );
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StopLocations(schedule: schedule),
          ),
        ),
      );
      
      // Verify header is displayed
      expect(find.text('Stop Locations'), findsOneWidget);
      
      // Verify stop information is displayed
      expect(find.text("LOY: 45°27\'28.2\"N 73°38\'20.3\"W"), findsOneWidget);
      expect(find.text("SGW: 45°29\'49.6\"N 73°34\'42.5\"W"), findsOneWidget);
      
      // Verify location icons are present
      expect(find.byIcon(Icons.location_on), findsNWidgets(2));
    });
    
    testWidgets('StopLocations handles empty stops', (WidgetTester tester) async {
      final schedule = ShuttleSchedule(
        loyDepartures: ['9:15'],
        sgwDepartures: ['9:45'],
        lastBus: {'LOY': '18:15', 'SGW': '18:15'},
        stops: {},
      );
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StopLocations(schedule: schedule),
          ),
        ),
      );
      
      // Verify nothing is displayed
      expect(find.text('Stop Locations'), findsNothing);
      expect(find.byIcon(Icons.location_on), findsNothing);
    });
  });
}
