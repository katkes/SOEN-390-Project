// This file contains widget tests for the WaypointSelectionScreen widget.
// The tests verify that the WaypointSelectionScreen widget correctly displays the RouteCard widgets
// and interacts with the NavBar.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soen_390/services/google_route_service.dart';
import 'package:soen_390/services/building_to_coordinates.dart';
import 'package:soen_390/utils/location_service.dart';
import 'package:mockito/annotations.dart';
import 'waypoint_selection_screens_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<GoogleRouteService>(),
  MockSpec<GeocodingService>(),
  MockSpec<LocationService>(),


])
void main() {
  // Test to verify that RouteCards are displayed after adding a route
  late MockGoogleRouteService mockGoogleRouteService;
  late MockGeocodingService mockGeocodingService;
  late MockLocationService mockLocationService;


  setUp(() {
    // Initialize mocks before each test
    mockGoogleRouteService = MockGoogleRouteService();
    mockGeocodingService = MockGeocodingService();
    mockLocationService = MockLocationService();

  });
  group('WaypointSelectionScreen Tests', () {
    
  });
  

}
