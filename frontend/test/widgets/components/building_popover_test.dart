//This test test the functionality of the building_information_popup.dart file
//It tests upon clicking the marker, the building information is displayed

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soen_390/widgets/building_information_popup.dart';

void main() {
  group('BuildingInformationPopup Tests', () {
    testWidgets('renders building information popup correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BuildingInformationPopup(
            buildingName: 'EV Building',
            buildingAddress: '1515 St. Catherine St. W',
          ),
        ),
      );

      expect(find.text('EV Building'), findsOneWidget);
      expect(find.text('1515 St. Catherine St. W'), findsOneWidget);
    });
  });
}


