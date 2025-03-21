import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import "package:soen_390/screens/indoor_accessibility/indoor_accessibility_preference.dart";
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group("Testing indoor accessibility checkbox functionality/UI", () {
    testWidgets("checkbox should start with unchecked",
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: IndoorAccessibilityPage(), //creates the widget for testing
      ));

      //check the default string
      expect(
          find.text('Requires mobility considerations: false'), findsOneWidget);
      final checkbox = find.byType(Checkbox);
      expect(checkbox, findsOneWidget);
      expect(tester.widget<Checkbox>(checkbox).value,
          false); //checks that the checkbox is not selected when the widget is initialized.

      final state = tester.state<IndoorAccessibilityState>(
          find.byType(IndoorAccessibilityPage));
      expect(state.getMobilityStatus(), false);
    }); //end of test

    testWidgets("checkbox turned to true functionality",
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: IndoorAccessibilityPage(), //creates the widget for testing
      ));
      final checkbox = find.byType(Checkbox);
      await tester.tap(checkbox); //simulates checking the checkbox I think?
      await tester.pump(); //rebuilds the widget to encompesate the check

      expect(
          find.text("Requires mobility considerations: true"), findsOneWidget);
      expect(tester.widget<Checkbox>(checkbox).value, true);

      final state = tester.state<IndoorAccessibilityState>(
          find.byType(IndoorAccessibilityPage));
      expect(state.getMobilityStatus(), true);
    }); // end of test

    testWidgets(
        "Checkbox can be toggled back to false after it got checked to true",
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: IndoorAccessibilityPage(), //creates the widget for testing
      ));

      final checkbox = find.byType(Checkbox);

      await tester.tap(checkbox);
      await tester
          .pump(); //update the changed checkbox along with the state change.

      // run it back to turn it back off
      await tester.tap(checkbox);
      await tester.pump();

      expect(
          find.text('Requires mobility considerations: false'), findsOneWidget);
      expect(tester.widget<Checkbox>(checkbox).value, false);

      final state = tester.state<IndoorAccessibilityState>(
          find.byType(IndoorAccessibilityPage));
      expect(state.getMobilityStatus(), false);
    }); //end of test
  });//end of group

  group("Testing data persistence from the shared preferences package implementation", (){
    setUp(() async {
      //mock shared preferences
      SharedPreferences.setMockInitialValues({});
    });

    test('Initial value should be false', () async {
      bool result = await IndoorAccessibilityState.getMobilityStatusPreference();
      expect(result, false);
    });

    test('Saved preference should be retrievable', () async {
      // Mock saving a value
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('mobility_impaired', true);

      bool result = await IndoorAccessibilityState.getMobilityStatusPreference();
      expect(result, true);
    });
  });
} //end of main function
