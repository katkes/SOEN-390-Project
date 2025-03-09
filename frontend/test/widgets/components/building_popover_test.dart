//This test test the functionality of the building_information_popup.dart file
//It tests upon clicking the marker, the building information is displayed

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soen_390/widgets/building_information_popup.dart';

void main() {
  group('BuildingInformationPopup Tests', () {
    testWidgets('renders building information popup correctly', (WidgetTester tester) async {
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

    testWidgets('displays photo if URL is provided', (WidgetTester tester) async {
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
    });

    testWidgets('displays building name and address correctly', (WidgetTester tester) async {
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

      expect(find.text(buildingName), findsOneWidget);
      expect(find.text(buildingAddress), findsOneWidget);
    });

    testWidgets('displays default image when no photo URL is provided', (WidgetTester tester) async {
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
      expect((image.image as AssetImage).assetName, 'assets/images/buildings/hall.png');
    });

    testWidgets('abbreviates long building names correctly', (WidgetTester tester) async {
      const longBuildingName = 'Very Long Building Name That Should Be Abbreviated';
      const buildingAddress = '1515 St. Catherine St. W';
      final expectedAbbreviation = '${longBuildingName.split(" ")[0]} Bldg';

      await tester.pumpWidget(
        const MaterialApp(
          home: BuildingInformationPopup(
            buildingName: longBuildingName,
            buildingAddress: buildingAddress,
          ),
        ),
      );

      expect(find.text(expectedAbbreviation), findsOneWidget);
      expect(find.text(longBuildingName), findsNothing);
    });

    testWidgets('clicking marker shows the popup', (WidgetTester tester) async {
      final GlobalKey key = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GestureDetector(
              key: key,
              onTap: () {
                showDialog(
                  context: key.currentContext!,
                  builder: (context) => const BuildingInformationPopup(
                    buildingName: 'EV Building',
                    buildingAddress: '1515 St. Catherine St. W',
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(key));
      await tester.pumpAndSettle();

      expect(find.byType(BuildingInformationPopup), findsOneWidget);
    });

    // New test: checks abbreviated building name with name length under threshold
    testWidgets('abbreviates building name when short', (WidgetTester tester) async {
      const shortBuildingName = 'EV Building';
      const buildingAddress = '1515 St. Catherine St. W';

      await tester.pumpWidget(
        const MaterialApp(
          home: BuildingInformationPopup(
            buildingName: shortBuildingName,
            buildingAddress: buildingAddress,
          ),
        ),
      );

      expect(find.text(shortBuildingName), findsOneWidget);
    });

    // New test: ensures abbreviated building name handles more complex name (test lines 38 and 39)
    testWidgets('handles long building name abbreviation correctly', (WidgetTester tester) async {
      const buildingName = 'Very Very Long Building Name That Should Be Abbreviated';
      const buildingAddress = '1515 St. Catherine St. W';
      final abbreviatedName = '${buildingName.split(" ")[0]} Bldg';

      await tester.pumpWidget(
        const MaterialApp(
          home: BuildingInformationPopup(
            buildingName: buildingName,
            buildingAddress: buildingAddress,
          ),
        ),
      );

      expect(find.text(abbreviatedName), findsOneWidget);
      expect(find.text(buildingName), findsNothing);
    });
  });
}
