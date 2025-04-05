import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soen_390/widgets/shuttle_schedule_dispaly.dart';
import 'package:soen_390/styles/theme.dart';
import 'package:soen_390/screens/shuttle_bus/shuttle_schedule_screen.dart';

void main() {
  testWidgets('ShuttleScheduleScreen renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: appTheme,
        home: const ShuttleScheduleScreen(),
      ),
    );
    
    // Verify AppBar
    expect(find.text('Shuttle Schedule'), findsOneWidget);
    
    // Verify ShuttleScheduleDisplay is present
    expect(find.byType(ShuttleScheduleDisplay), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    //expect(find.byType(SafeArea), findsOneWidget);
    
    // Verify Friday schedule is initially displayed
    expect(find.text('Shuttle Bus Schedule (Friday)'), findsOneWidget);
    expect(find.text('Show Mon-Thurs Schedule'), findsOneWidget);
    
    // Verify some of the departure times are visible
    // (Since we're using the real service, we know what times to expect)
    expect(find.text('9:15'), findsAtLeastNWidgets(1));
    expect(find.text('9:45'), findsAtLeastNWidgets(1));
    
    // Test toggle button works
    await tester.tap(find.text('Show Mon-Thurs Schedule'));
    await tester.pump();
    
    // Verify Monday-Thursday schedule is now displayed
    expect(find.text('Shuttle Bus Schedule (Mon-Thurs)'), findsOneWidget);
    expect(find.text('Show Friday Schedule'), findsOneWidget);
  });
}
