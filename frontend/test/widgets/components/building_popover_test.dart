//This test test the functionality of the building_information_popup.dart file
//It tests upon clicking the marker, the building information is displayed

import 'package:latlong2/latlong.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soen_390/services/interfaces/route_service_interface.dart';
import 'package:soen_390/widgets/building_information_popup.dart';
import 'package:soen_390/utils/location_service.dart';
import 'package:soen_390/services/google_route_service.dart';
import 'package:soen_390/services/building_to_coordinates.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soen_390/providers/service_providers.dart';

@GenerateMocks([GoogleRouteService, LocationService, GeocodingService])
import 'building_popover_test.mocks.dart';

void main() {
  group('BuildingInformationPopup Tests', () {
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
    });

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

      expect(find.text(buildingName), findsOneWidget);
      expect(find.text(buildingAddress), findsOneWidget);
    });

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

    testWidgets('abbreviates long building names correctly',
        (WidgetTester tester) async {
      const longBuildingName =
          'Very Long Building Name That Should Be Abbreviated';
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
    testWidgets('abbreviates building name when short',
        (WidgetTester tester) async {
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
    testWidgets('handles long building name abbreviation correctly',
        (WidgetTester tester) async {
      const buildingName =
          'Very Very Long Building Name That Should Be Abbreviated';
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
  group('BuildingInformationPopup Tests', () {
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

    testWidgets('opens waypoint selection on button press',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            routeServiceProvider.overrideWithValue(MockGoogleRouteService()),
            locationServiceProvider.overrideWithValue(MockLocationService()),
            buildingToCoordinatesProvider
                .overrideWithValue(MockGeocodingService()),
          ],
          child: const MaterialApp(
            home: BuildingInformationPopup(
              buildingName: 'EV Building',
              buildingAddress: '1515 St. Catherine St. W',
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.arrow_forward));
      await tester.pumpAndSettle();
    });
  });

  testWidgets(
      'calls onRouteSelected and pops when a non-null RouteResult is returned',
      (WidgetTester tester) async {
    bool onRouteSelectedCalled = false;
    RouteResult? receivedResult;

    // Create a mock RouteResult
    final mockResult = RouteResult(
      distance: 1000,
      duration: 600,
      routePoints: [const LatLng(45.5017, -73.5673)],
      steps: [],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          routeServiceProvider.overrideWithValue(MockGoogleRouteService()),
          locationServiceProvider.overrideWithValue(MockLocationService()),
          buildingToCoordinatesProvider
              .overrideWithValue(MockGeocodingService()),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Builder(builder: (context) {
              return BuildingInformationPopup(
                buildingName: 'EV Building',
                buildingAddress: '1515 St. Catherine St. W',
                onRouteSelected: (result) {
                  onRouteSelectedCalled = true;
                  receivedResult = result;
                },
              );
            }),
          ),
        ),
      ),
    );

    // Tap the arrow_forward button to start navigation
    await tester.tap(find.byIcon(Icons.arrow_forward));
    await tester.pump(); // Let the navigation begin

    // Simulate the new screen returning a non-null RouteResult
    Navigator.of(tester.element(find.byType(BuildingInformationPopup)))
        .pop(mockResult);

    // Complete all pending animations/futures
    await tester.pumpAndSettle();

    // Verify that onRouteSelected was called and received the mockResult
    expect(onRouteSelectedCalled, isTrue);
    expect(receivedResult, equals(mockResult));
  });
}
