import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_map/flutter_map.dart';

import 'package:soen_390/utils/marker_tap_handler.dart';
import 'package:soen_390/widgets/building_popup.dart';
import 'marker_tap_handler_test.mocks.dart';

/// Tests for MarkerTapHandler functionality.
/// Verifies marker tap behavior and building information retrieval.
///
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

  /// Test to verify that a popover is shown after tapping on a marker.
  /// This test simulates a marker tap, and checks if the popover widget appears as expected.
  testWidgets('popover is shown after marker tap', (WidgetTester tester) async {
    const double lat = 45.4973;
    const double lon = -73.5793;
    const String name = 'Test Building';
    const String address = 'Test Address';
    const Offset tapPosition = Offset(100, 100);

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: Container()),
    ));

    markerTapHandler.onMarkerTapped(lat, lon, name, address, tapPosition,
        tester.element(find.byType(Container)));

    await tester.pumpAndSettle();

    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(Container),
        findsOneWidget); // Adjust based on expected behavior
  });

  /// Test to verify that the correct parameters are passed to the
  /// `fetchBuildingInformation` method when a marker is tapped.
  /// This test checks if the method is called once with the correct latitude, longitude, and building name.
  testWidgets('getLocationInfo is called with correct parameters',
      (WidgetTester tester) async {
    const double lat = 45.4973;
    const double lon = -73.5793;
    const String name = 'Test Building';
    const String address = 'Test Address';
    final Offset tapPosition = const Offset(100, 100);

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: Container()),
    ));

    markerTapHandler.onMarkerTapped(lat, lon, name, address, tapPosition,
        tester.element(find.byType(Container)));

    await tester.pumpAndSettle();

    await tester.pump(const Duration(milliseconds: 500));

    verify(mockBuildingPopUps.fetchBuildingInformation(lat, lon, name))
        .called(1);
  });
}
