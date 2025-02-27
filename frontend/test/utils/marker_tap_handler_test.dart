import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_map/flutter_map.dart';

import 'package:soen_390/utils/marker_tap_handler.dart';
import 'package:soen_390/services/building_info_api.dart';
import 'marker_tap_handler_test.mocks.dart';

@GenerateNiceMocks([MockSpec<MapController>(), MockSpec<BuildingPopUps>()])
void main() {
  late MockMapController mockMapController;
  late MockBuildingPopUps mockBuildingPopUps;
  late MarkerTapHandler markerTapHandler;
  late Function(String?, String?) onBuildingInfoUpdated;

  setUp(() {
    mockMapController = MockMapController();
    mockBuildingPopUps = MockBuildingPopUps();
    onBuildingInfoUpdated = (name, address) {};

    markerTapHandler = MarkerTapHandler(
      mapController: mockMapController,
      buildingPopUps: mockBuildingPopUps,
      onBuildingInfoUpdated: onBuildingInfoUpdated,
    );

    when(mockBuildingPopUps.fetchBuildingInformation(any, any, any))
        .thenAnswer((_) async => {'photo': 'test_photo.jpg'});
  });

  testWidgets('popover is shown after marker tap', (WidgetTester tester) async {
    const double lat = 45.4973;
    const double lon = -73.5793;
    const String name = 'Test Building';
    const String address = 'Test Address';
    final Offset tapPosition = Offset(100, 100);

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: Container()),
    ));

    markerTapHandler.onMarkerTapped(lat, lon, name, address, tapPosition,
        tester.element(find.byType(Container)));

    await tester.pumpAndSettle(); // Ensure all animations and timers finish

    // Add an explicit pump to simulate time passage if needed
    await tester.pump(Duration(milliseconds: 400));

    expect(find.byType(Container),
        findsOneWidget); // Adjust based on expected behavior
  });
  testWidgets('getLocationInfo is called with correct parameters',
      (WidgetTester tester) async {
    const double lat = 45.4973;
    const double lon = -73.5793;
    const String name = 'Test Building';
    const String address = 'Test Address';
    final Offset tapPosition = Offset(100, 100);

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: Container()),
    ));

    markerTapHandler.onMarkerTapped(lat, lon, name, address, tapPosition,
        tester.element(find.byType(Container)));

    // Use FakeAsync to control async operations and timers
    await tester.pumpAndSettle(); // Ensure async tasks settle

    // Use FakeAsync to simulate the passage of time if necessary
    await tester
        .pump(Duration(milliseconds: 500)); // Adjust duration to the timeout

    verify(mockBuildingPopUps.fetchBuildingInformation(lat, lon, name))
        .called(1);
  });
}
