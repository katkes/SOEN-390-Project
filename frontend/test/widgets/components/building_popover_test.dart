//This test test the functionality of the building_information_popup.dart file
//It tests upon clicking the marker, the building information is displayed

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soen_390/widgets/building_information_popup.dart';

void main() {
  group('BuildingInformationPopup Tests', () {
    ///Test to verify that the BuildingInformationPopup widget renders the correct
    /// building name, address, and essential UI elements like the ElevatedButton and arrow icon.
    testWidgets('renders building information popup correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: BuildingInformationPopup(
            buildingName: 'EV Building',
            buildingAddress: '1515 St. Catherine St. W',
          ),
        ),
      );

      expect(find.text('EV Building'), findsOneWidget);
      expect(find.text('1515 St. Catherine St. W'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
    });

    /// Test to verify that if a photo URL is provided, the image is displayed correctly.
    testWidgets('displays photo if URL is provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: BuildingInformationPopup(
            buildingName: 'EV Building',
            buildingAddress: '1515 St. Catherine St. W',
            photoUrl: 'https://www.gettyimages.ca/photos/normal-picture',
          ),
        ),
      );

      expect(find.byType(Image), findsOneWidget);
      expect(find.byType(Image).evaluate().single.widget is Image, true);
    });

    /// Test to ensure that the building name and address are displayed correctly.
    testWidgets('displays building name and address correctly',
        (WidgetTester tester) async {
      const buildingName = 'EV Building';
      const buildingAddress = '1515 St. Catherine St. W';

      await tester.pumpWidget(
        const MaterialApp(
          home: BuildingInformationPopup(
            buildingName: buildingName,
            buildingAddress: buildingAddress,
          ),
        ),
      );

      expect(find.text('EV Building'), findsOneWidget);

      expect(find.text(buildingAddress), findsOneWidget);
    });

    // Test to verify that when no photo URL is provided, a default image is displayed.
    testWidgets('displays default image when no photo URL is provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: BuildingInformationPopup(
            buildingName: 'EV Building',
            buildingAddress: '1515 St. Catherine St. W',
            photoUrl: null, // No photo URL provided
          ),
        ),
      );
      final image = find.byType(Image).evaluate().single.widget as Image;
      expect((image.image as AssetImage).assetName,
          'assets/images/buildings/hall.png');
    });

    /// Test to check if long building names are abbreviated correctly for better UI display.
    testWidgets('abbreviates long building names correctly',
        (WidgetTester tester) async {
      // Arrange
      const longBuildingName =
          'Very Long Building Name That Should Be Abbreviated';
      const buildingAddress = '1515 St. Catherine St. W';
      final expectedAbbreviation = '${longBuildingName.split(" ")[0]} Bldg';

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: BuildingInformationPopup(
            buildingName: longBuildingName,
            buildingAddress: buildingAddress,
          ),
        ),
      );

      // Assert
      expect(find.text(expectedAbbreviation), findsOneWidget);
      expect(find.text(longBuildingName), findsNothing);
    });
  });
}
