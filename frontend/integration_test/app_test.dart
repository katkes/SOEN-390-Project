import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:soen_390/main.dart' as app;
import 'package:soen_390/widgets/outdoor_map.dart';
import 'package:soen_390/services/map_service.dart';
import 'dart:math';


void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Test', () {
    testWidgets('Switching between campuses and viewing building info when clicking on a building', (tester) async{
      app.main();
      await tester.pumpAndSettle(); // waiting for the app to settle
      await Future.delayed(const Duration(seconds: 3));

      // Finding the map icon in navbar and tapping on it to switch to map section
      final mapIconFinder = find.byIcon(Icons.map_outlined);
      await tester.tap(mapIconFinder);
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 3));

      // Finding the campuses toggle buttons
      final sgwToggleButton = find.text('SGW').first; // Retrieves first element it sees
      final loyolaToggleButton = find.text('Loyola').first; // Retrieves first element it sees

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
      await tester.tap(mapIconFinder);
      await tester.pumpAndSettle();
      expect(find.byType(MapWidget), findsOneWidget);

      // Tapping on a building marker and waiting till it settled
      final buildingMarkerFinder = find.byType(Marker).first;
      await tester.tap(buildingMarkerFinder);
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 3));

      // TODO: Tap on a building and wait till it settled
      // TODO: Check that the appropriate building info is being rendered
    });
  });
}