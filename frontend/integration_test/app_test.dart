import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:soen_390/main.dart' as app;
import 'package:soen_390/widgets/outdoor_map.dart';
import 'package:soen_390/widgets/route_card.dart';
import 'dart:math';

// The purpose of this test is to automate user interactions with the app's map and navigation features, ensuring they function correctly in a real or emulated environment.
// It simulates user behaviors to verify that the app behaves as expected in different scenarios.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Function to find the map icon in navbar and tapping on it to switch to map section
  Future<void> navigatingToMapSection(WidgetTester tester) async {
    final mapIconFinder = find.byIcon(Icons.map_outlined);
    await tester.tap(mapIconFinder);
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 3));
  }

  // Function to load the app for testing
  Future<void> loadingApp(WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 3));
  }

  // Function to enter start address and destination address
  Future<void> selectLocation(
      WidgetTester tester, String option, String location) async {
    final startLocationFinder = find.text(option);
    await tester.tap(startLocationFinder);
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 3));
    final searchBarFinder = find.text("Type address...");
    await tester.tap(searchBarFinder, warnIfMissed: false);
    await tester.pumpAndSettle();
    final typeAddressFinder = find.byType(TextField);
    await tester.enterText(typeAddressFinder, location);
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 5));
    final confirmAddressFinder = find.text("Use this Address");
    await tester.tap(confirmAddressFinder);
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 3));
  }

  // Function to automate route planning flow depending on different transportation options
  Future<void> routePlanning(WidgetTester tester, IconData icon) async {
    await loadingApp(tester);
    await navigatingToMapSection(tester);
    expect(find.byType(MapWidget), findsOneWidget);

    // Navigating to transportation screen
    final findMyWayButton = find.text('Find My Way');
    await tester.tap(findMyWayButton);
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 3));
    expect(find.text('Start Location'), findsOneWidget);

    // Selecting start location
    String startLocation =
        "Hall Building Auditorium, Boulevard De Maisonneuve Ouest, Montreal, QC, Canada";
    await selectLocation(tester, "Start Location", startLocation);

    // Selecting destination
    String destinationLocation =
        "Stinger Dome, Sherbrooke Street West, Montreal, QC, Canada";
    await selectLocation(tester, "Destination", destinationLocation);

    // Selecting car transportation option
    final carButton = find.byIcon(icon);
    await tester.tap(carButton);
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 3));

    // Confirming route
    final confirmRouteButton = find.text('Confirm Route');
    await tester.tap(confirmRouteButton);
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 3));

    // Checks for displaying of route
    expect(find.byType(RouteCard), findsWidgets);
    final routeCardFinder = find.byType(RouteCard).first;
    await tester.tap(routeCardFinder);
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 5));

    expect(find.byType(PolylineLayer), findsOneWidget);
  }

  // Group containing all the test flows of the app
  group('App Test', () {
    testWidgets(
        'Testing ability to switch campuses, sections, and building pop-ups',
        (tester) async {
      await loadingApp(tester);
      await navigatingToMapSection(tester);

      // Finding the campuses toggle buttons
      final sgwToggleButton =
          find.text('SGW').first; // Retrieves first element it sees
      final loyolaToggleButton =
          find.text('Loyola').first; // Retrieves first element it sees

      // Tapping on loyola and waiting till it settled
      await tester.tap(loyolaToggleButton);
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 3));

      // Verifying that the loyola campus is being rendered
      expect(find.byType(MapWidget), findsOneWidget);

      // Tapping on sgw and waiting till it settled
      await tester.tap(sgwToggleButton);
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 3));

      // Verifying that the sgw campus is being rendered
      expect(find.byType(MapWidget), findsOneWidget);

      // Verifying that if you click on another section, the last campus rendered stays the same
      final profileIconFinder = find.byIcon(Icons.person_outline);
      await tester.tap(profileIconFinder);
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 3));
      await navigatingToMapSection(tester);
      expect(find.byType(MapWidget), findsOneWidget);
      await Future.delayed(const Duration(seconds: 5));

      // Tapping on a random building marker and waiting for information to be retrieved
      final buildingMarkerFinder = find.byIcon(Icons.location_pin);
      final markerElements = buildingMarkerFinder.evaluate().toList();
      final markersLength = markerElements.length;
      final randomIndex = Random().nextInt(markersLength);
      await tester.tap(buildingMarkerFinder.at(randomIndex));
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 5));
    });

    testWidgets('Route planning - car option', (tester) async {
      await routePlanning(tester, Icons.directions_car);
    });

    testWidgets('Route planning - bike option', (tester) async {
      await routePlanning(tester, Icons.directions_bike);
    });

    testWidgets('Route planning - public transport option', (tester) async {
      await routePlanning(tester, Icons.train);
    });

    testWidgets('Route planning - walk option', (tester) async {
      await routePlanning(tester, Icons.directions_walk);
    });
  });
}
