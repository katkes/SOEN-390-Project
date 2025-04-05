import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_places_autocomplete_text_field/google_places_autocomplete_text_field.dart';
import 'package:integration_test/integration_test.dart';
import 'package:soen_390/main.dart' as app;
import 'package:soen_390/services/map_service.dart';
import 'package:soen_390/widgets/building_information_popup.dart';
import 'package:soen_390/widgets/outdoor_map.dart';
import 'package:soen_390/widgets/poi_list_view.dart';
import 'package:soen_390/widgets/poi_search_bar.dart';
import 'package:soen_390/widgets/route_card.dart';
import 'dart:math';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// The purpose of this test is to automate user interactions with the app's map and navigation features, ensuring they function correctly in a real or emulated environment.
// It simulates user behaviors to verify that the app behaves as expected in different scenarios.
void main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final int elapsedTime = 3;
  await dotenv.load(fileName: ".env");
  final String hallBuildingAddress = "Hall Building Auditorium, Boulevard De Maisonneuve Ouest, Montreal, QC, Canada";

  // Function to find the map icon in navbar and tapping on it to switch to map section
  Future<void> navigatingToOutdoorMap(WidgetTester tester) async {
    final mapIconFinder = find.byIcon(Icons.map_outlined);
    await tester.tap(mapIconFinder);
    await tester.pumpAndSettle();
    await Future.delayed(Duration(seconds: elapsedTime));
  }

  // Function to navigate to profile section
  Future<void> navigatingToProfileSection(WidgetTester tester) async {
    final profileIconFinder = find.byIcon(Icons.person_outline);
    await tester.tap(profileIconFinder);
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
  Future<void> selectLocation(WidgetTester tester, String option,
      String location) async {
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

  // Function to navigate to route planning screen from outdoor map screen
  Future<void> navigatingToRoutePlanningScreen(WidgetTester tester) async {
    final findMyWayButton = find.text('Find My Way');
    await tester.tap(findMyWayButton);
    await tester.pumpAndSettle();
    await Future.delayed(Duration(seconds: elapsedTime));
    expect(find.text('Your Location'), findsOneWidget);
  }

  // Function to navigate to point of interests screen
  Future<void> navigatingToPointOfInterestsScreen(WidgetTester tester) async {
    await loadingApp(tester);
    await navigatingToOutdoorMap(tester);
    await navigatingToRoutePlanningScreen(tester);
    final String pointOfInterestsButtonLabel = "What's Nearby?";
    final nearbyButton = find.text(pointOfInterestsButtonLabel);
    await tester.tap(nearbyButton);
    await tester.pumpAndSettle();
    await Future.delayed(Duration(seconds: elapsedTime));
  }

  Future<void> choosePOI(WidgetTester tester, String chosenCategory) async {
    // Choosing a category
    final String categoryLabel = "Show Place Categories";
    final String category = chosenCategory;
    final categoryButton = find.text(categoryLabel);
    await tester.tap(categoryButton);
    await tester.pumpAndSettle();
    await Future.delayed(Duration(seconds: elapsedTime));
    final categoryFinder = find.text(category);
    await tester.tap(categoryFinder);
    await tester.pumpAndSettle();
    await Future.delayed(Duration(seconds: elapsedTime));
    expect(find.byType(Card), findsWidgets);

    // Clicking on a card
    final cardFinder = find.byType(Card).first;
    await tester.tap(cardFinder);
    await tester.pumpAndSettle();
    await Future.delayed(Duration(seconds: elapsedTime));

    // Getting directions to point of interest
    final String getDirectionsButtonLabel = "Set Destination";
    final getDirectionsButton = find.text(getDirectionsButtonLabel);
    await tester.tap(getDirectionsButton);
    await tester.pumpAndSettle();
    await Future.delayed(Duration(seconds: elapsedTime));
    expect(find.text('Your Location'), findsOneWidget);
  }

  // Function to automate route planning flow depending on different transportation options
  // bool isUsingLiveLocation: whether or not the user is using is default live location for route planning
  Future<void> routePlanning(WidgetTester tester, IconData icon,
      {required bool isUsingLiveLocation}) async {
    await loadingApp(tester);
    await navigatingToOutdoorMap(tester);
    expect(find.byType(MapWidget), findsOneWidget);

    // Navigating to route planning screen
    navigatingToRoutePlanningScreen(tester);

    // Selecting start location
    if (!isUsingLiveLocation) {
      String startLocation = hallBuildingAddress;
      await selectLocation(tester, "Your Location", startLocation);
    }

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
    if (isUsingLiveLocation) {
      await tester.tap(confirmRouteButton);
    }
    await tester.pumpAndSettle();
    // since live location of emulator is in california, route generation takes more time
    await Future.delayed(Duration(seconds: elapsedTime));

    // Checks for displaying of route
    expect(find.byType(RouteCard), findsWidgets);
    final routeCardFinder = find
        .byType(RouteCard)
        .first;
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
        'Testing ability to switch campuses, screens, and building pop-ups',
            (tester) async {
          await loadingApp(tester);
          await navigatingToOutdoorMap(tester);

          // Finding the campuses toggle buttons
          final sgwToggleButton =
              find
                  .text('SGW')
                  .first; // Retrieves first element it sees
          final loyolaToggleButton =
              find
                  .text('Loyola')
                  .first; // Retrieves first element it sees

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
          await navigatingToProfileSection(tester);

          // Tapping on a random building marker and waiting for information to be retrieved
          final buildingMarkerFinder = find.byIcon(Icons.location_pin);
          final markerElements = buildingMarkerFinder.evaluate().toList();
          final markersLength = markerElements.length;
          final randomIndex = Random().nextInt(markersLength);
          final markerPreciseLocation = tester.getCenter(
              buildingMarkerFinder.at(
                  randomIndex)); // Adding this line to get precise location of marker and ensuring pop-up is triggered
          await tester.tapAt(markerPreciseLocation);
          await tester.pumpAndSettle();
          await Future.delayed(Duration(seconds: elapsedTime));
        });

    // Target user stories: 3.1, 3.3, 3.4, 3.5
    testWidgets('Test route planning - car option', (tester) async {
      await routePlanning(
          tester, Icons.directions_car, isUsingLiveLocation: false);
    });

    // Target user stories: 3.1, 3.3, 3.4, 3.5
    testWidgets('Test route planning - bike option', (tester) async {
      await routePlanning(
          tester, Icons.directions_bike, isUsingLiveLocation: false);
    });

    // Target user stories: 3.1, 3.3, 3.4, 3.5
    testWidgets('Test route planning - public transport option',
            (tester) async {
          await routePlanning(tester, Icons.train, isUsingLiveLocation: false);
        });

    // Target user stories: 3.1, 3.3, 3.4, 3.5
    testWidgets('Test route planning - walk option', (tester) async {
      await routePlanning(
          tester, Icons.directions_walk, isUsingLiveLocation: false);
    });

    // User stories targeted: 2.4
    testWidgets('Test tracking user live location feature', (tester) async {
      await routePlanning(
          tester, Icons.directions_car, isUsingLiveLocation: true);
    });

    // Target user stories: none (additional feature)
    testWidgets('Test search bar functionality', (tester) async {
      await loadingApp(tester);
      await navigatingToOutdoorMap(tester);
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
      await Future.delayed(const Duration(
          seconds: 2)); // Hardcoded value because selected marker disappears after a few seconds

    });

    // Target user stories: 4.1
    testWidgets('Testing connection to google calendar', (WidgetTester tester) async {
      // Loading app and navigating to profile section
      await loadingApp(tester);
      await navigatingToProfileSection(tester);

      // Clicking on "Sign in with Google" button
      final String googleSignInButtonLabel = "Sign in with Google";
      final signInButton = find.text(googleSignInButtonLabel);
      await tester.tap(signInButton);
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 10)); // Takes more time to load google sign in page
    });

    testWidgets('Testing outdoor points of interests - search bar functionality', (WidgetTester tester) async {
      // Loading app and navigating to points of interests screen
      await navigatingToPointOfInterestsScreen(tester);

      // Performing a search using the search bar
      final searchBarFinder = find.byType(POISearchBar);
      await tester.tap(searchBarFinder);
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: elapsedTime));
      await tester.enterText(searchBarFinder, hallBuildingAddress);
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: elapsedTime));

      // Looking for POI, and getting directions
      await choosePOI(tester, "RESTAURANT");
    });

    testWidgets('Testing outdoor points of interests with current location - place categories', (WidgetTester tester) async {
      // Loading app and navigating to points of interests screen
      await navigatingToPointOfInterestsScreen(tester);

      // Clicking on current location button
      final currentLocationButton = find.byIcon(Icons.my_location);
      await tester.tap(currentLocationButton);
      await Future.delayed(Duration(seconds: elapsedTime));

      // Looking for POI, and getting directions
      await choosePOI(tester, "STORE");
    });

  });
}


