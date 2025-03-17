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
  final int elapsedTime = 3;

  // Function to find the map icon in navbar and tapping on it to switch to map section
  Future<void> navigatingToMapSection(WidgetTester tester) async {
    final mapIconFinder = find.byIcon(Icons.map_outlined);
    await tester.tap(mapIconFinder);
    await tester.pumpAndSettle();
    await Future.delayed(Duration(seconds: elapsedTime));
  }

  // Function to load the app for testing
  Future<void> loadingApp(WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();
    await Future.delayed(Duration(seconds: elapsedTime));
  }

  // Function to enter start address and destination address
  Future<void> selectLocation(
      WidgetTester tester, String option, String location) async {
    final startLocationFinder = find.text(option);
    await tester.tap(startLocationFinder);
    await tester.pumpAndSettle();
    await Future.delayed(Duration(seconds: elapsedTime));
    final searchBarFinder = find.text("Type address...");
    await tester.tap(searchBarFinder, warnIfMissed: false);
    await tester.pumpAndSettle();
    final typeAddressFinder = find.byType(TextField);
    await tester.enterText(typeAddressFinder, location);
    await tester.pumpAndSettle();
    await Future.delayed(Duration(seconds: elapsedTime));
    final confirmAddressFinder = find.text("Use this Address");
    await tester.tap(confirmAddressFinder);
    await tester.pumpAndSettle();
    await Future.delayed(Duration(seconds: elapsedTime));
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
    await Future.delayed(Duration(seconds: elapsedTime));
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
    await Future.delayed(Duration(seconds: elapsedTime));

    // Confirming route
    final confirmRouteButton = find.text('Confirm Route');
    await tester.tap(confirmRouteButton);
    await tester.pumpAndSettle();
    await Future.delayed(Duration(seconds: elapsedTime));

    // Checks for displaying of route
    expect(find.byType(RouteCard), findsWidgets);
    final routeCardFinder = find.byType(RouteCard).first;
    await tester.tap(routeCardFinder);
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(
        seconds:
            8)); // Reason why the elapsed time is longer is because the route is being rendered

    expect(find.byType(PolylineLayer), findsOneWidget);
  }

  // Group containing all the test flows of the app
  group('App Test', () {
    // Target user stories: 2.1, 2.2, 2.3
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
      await Future.delayed(Duration(seconds: elapsedTime));

      // Verifying that the loyola campus is being rendered
      expect(find.byType(MapWidget), findsOneWidget);

      // Tapping on sgw and waiting till it settled
      await tester.tap(sgwToggleButton);
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: elapsedTime));

      // Verifying that the sgw campus is being rendered
      expect(find.byType(MapWidget), findsOneWidget);

      // Verifying that if you click on another section, the last campus rendered stays the same
      final profileIconFinder = find.byIcon(Icons.person_outline);
      await tester.tap(profileIconFinder);
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: elapsedTime));
      await navigatingToMapSection(tester);
      expect(find.byType(MapWidget), findsOneWidget);
      await Future.delayed(Duration(seconds: elapsedTime));

      // Tapping on a random building marker and waiting for information to be retrieved
      final buildingMarkerFinder = find.byIcon(Icons.location_pin);
      final markerElements = buildingMarkerFinder.evaluate().toList();
      final markersLength = markerElements.length;
      final randomIndex = Random().nextInt(markersLength);
      await tester.tap(buildingMarkerFinder.at(randomIndex));
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: elapsedTime));
    });

    // Testing route planning with car transportation option
    // Target user stories: 3.1, 3.3, 3.4, 3.5
    testWidgets('Test route planning - car option', (tester) async {
      await routePlanning(tester, Icons.directions_car);
    });

    // Testing route planning with bike transportation option
    // Target user stories: 3.1, 3.3, 3.4, 3.5
    testWidgets('Test route planning - bike option', (tester) async {
      await routePlanning(tester, Icons.directions_bike);
    });

    // Testing route planning with public transportation option
    // Target user stories: 3.1, 3.3, 3.4, 3.5
    testWidgets('Test route planning - public transport option',
        (tester) async {
      await routePlanning(tester, Icons.train);
    });

    // Testing route planning with walk transportation option
    // Target user stories: 3.1, 3.3, 3.4, 3.5
    testWidgets('Test route planning - walk option', (tester) async {
      await routePlanning(tester, Icons.directions_walk);
    });

    // Testing the search bar functionality when searching for building through the map
    // Target user stories: none (additional feature)
    testWidgets('Test search bar functionality', (tester) async {
      await loadingApp(tester);
      await navigatingToMapSection(tester);
      expect(find.byType(MapWidget), findsOneWidget);
      await Future.delayed(Duration(seconds: elapsedTime));

      // Finding search bar and tapping on it
      final searchBarFinder = find.byIcon(Icons.search);
      await tester.tap(searchBarFinder);
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: elapsedTime));

      // Entering text into search bar
      final textFieldFinder = find.byKey(const Key("searchBarTextField"));
      await tester.enterText(textFieldFinder, "Hall Building");
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: elapsedTime));

      // Clicking on suggestion
      final buildingSuggestion = find.byKey(const Key("123"));
      await tester.tap(buildingSuggestion);
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: elapsedTime));
    });
  });
}
