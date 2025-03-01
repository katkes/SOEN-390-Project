import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test_helper/integration_test_helper.dart';
import 'package:soen_390/main.dart' as app;

void main() {
  group('App Test', () {
    IntegrationTestHelperBinding.ensureInitialized();
    testWidgets('Switching between campuses and viewing building info when clicking on a building', (tester) async{
      app.main();
      await tester.pumpAndSettle(); // waiting for the app to settle

      // TODO: Create finders for toggle button, navigation bar, and buildings
      final sgwToggleButton = find.text('SGW').first; // Retrieves first element it sees
      final loyolaToggleButton = find.text('Loyola').first; // Retrieves first element it sees

      // TODO: Tap on the toggle button and wait till it settled
      await tester.tap(sgwToggleButton);
      await tester.pumpAndSettle();
      // TODO: Check that the appropriate map is being rendered depending on the campus
      // TODO: Tap on a building and wait till it settled
      // TODO: Check that the appropriate building info is being rendered
      // TODO: Check that the navigation bar is being rendered
      // TODO: Change section using the navigation bar
      // TODO: Go back to the map section and verify that the last campus the user checked is being rendered
    });
  });
}