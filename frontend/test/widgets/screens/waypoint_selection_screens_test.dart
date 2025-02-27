import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soen_390/screens/waypoint/waypoint_selection_screens.dart';
import 'package:soen_390/widgets/nav_bar.dart';
import 'package:soen_390/widgets/route_card.dart';

void main() {
  testWidgets('Displays RouteCards after adding a route',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: WaypointSelectionScreen(),
      ),
    );

    await tester.pumpAndSettle();

    final state = tester.state<WaypointSelectionScreenState>(
        find.byType(WaypointSelectionScreen));

    // ignore: invalid_use_of_protected_member
    state.setState(() {
      state.confirmedRoutes.add({
        "title": "Test Route",
        "timeRange": "10:00 - 10:30",
        "duration": "30 min",
        "description": "Start → Destination",
        "icons": [Icons.train],
      });
    });

    await tester.pumpAndSettle();

    expect(find.byType(RouteCard), findsOneWidget);
    expect(find.text("Test Route"), findsOneWidget);
  });

  testWidgets('WaypointSelectionScreen interacts with NavBar',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: WaypointSelectionScreen(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(NavBar), findsOneWidget);

    final walkIcon = find.byIcon(Icons.directions_walk);
    expect(walkIcon, findsOneWidget);
    await tester.tap(walkIcon);
    await tester.pumpAndSettle();

    expect(find.byType(WaypointSelectionScreen), findsOneWidget);
  });
}
