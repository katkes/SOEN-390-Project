// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:soen_390/providers/navigation_provider.dart';
import 'package:soen_390/services/geocoding_service.dart';
import 'package:soen_390/utils/navigation_utils.dart';
import 'package:soen_390/screens/indoor/mappedin_map_controller.dart';
import 'navigation_utils_test.mocks.dart';
import 'package:soen_390/utils/location_service.dart';
import 'package:soen_390/utils/route_cache_manager.dart';
import 'package:soen_390/utils/waypoint_validator.dart';
import 'package:soen_390/utils/campus_route_checker.dart';
import 'package:soen_390/services/google_route_service.dart';

// Generate mocks
@GenerateMocks([
  MappedinMapController,
  WidgetRef,
  NavigationNotifier,
  GeocodingService,
  LocationService,
  GoogleRouteService,
  CampusRouteChecker,
  WaypointValidator,
  RouteCacheManager
])
void main() {
  late MockMappedinMapController mockMapController;
  late MockWidgetRef mockWidgetRef;

  late MockNavigationNotifier mockNavigationNotifier;
  late MockGeocodingService mockBuildingToCoordinatesService;
  late MockLocationService mockLocationService;
  late MockGoogleRouteService mockRouteService;
  late MockCampusRouteChecker mockCampusRouteChecker;
  late MockWaypointValidator mockWaypointValidator;
  late MockRouteCacheManager mockRouteCacheManager;

  setUp(() {
    mockMapController = MockMappedinMapController();
    mockWidgetRef = MockWidgetRef();

    mockMapController = MockMappedinMapController();
    mockWidgetRef = MockWidgetRef();
    mockNavigationNotifier = MockNavigationNotifier();
    mockBuildingToCoordinatesService = MockGeocodingService();
    mockLocationService = MockLocationService();
    mockRouteService = MockGoogleRouteService();
    mockCampusRouteChecker = MockCampusRouteChecker();
    mockWaypointValidator = MockWaypointValidator();
    mockRouteCacheManager = MockRouteCacheManager();
  });

  testWidgets('shows SnackBar on room navigation failure',
      (WidgetTester tester) async {
    when(mockMapController.navigateToRoom('H860'))
        .thenAnswer((_) async => false);
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                Future.microtask(() {
                  NavigationUtils.openMappedinMap(
                    context: context,
                    mappedinController: mockMapController,
                    roomName: 'H860',
                  );
                });
                return Container();
              },
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Failed to navigate to H860'), findsOneWidget);
  });

  testWidgets('shows SnackBar on building selection failure',
      (WidgetTester tester) async {
    when(mockMapController.selectBuildingByName('H'))
        .thenAnswer((_) async => false);
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                Future.microtask(() {
                  NavigationUtils.openMappedinMap(
                    context: context,
                    mappedinController: mockMapController,
                    buildingName: 'H',
                  );
                });
                return Container();
              },
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Failed to switch to H Building'), findsOneWidget);
  });

  testWidgets('shows SnackBar on room navigation failure in openMappedinMap',
      (WidgetTester tester) async {
    // Arrange: Create a mock failure for room navigation
    when(mockMapController.navigateToRoom('H860'))
        .thenAnswer((_) async => false);

    // Act: Trigger the function to open the map
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                Future.microtask(() {
                  NavigationUtils.openMappedinMap(
                    context: context,
                    mappedinController: mockMapController,
                    roomName: 'H860',
                  );
                });
                return Container();
              },
            ),
          ),
        ),
      ),
    );

    // Wait for SnackBar to show
    await tester.pumpAndSettle();

    // Assert: SnackBar shows the failure message
    expect(find.text('Failed to navigate to H860'), findsOneWidget);
  });
  testWidgets('shows SnackBar on building selection failure',
      (WidgetTester tester) async {
    when(mockMapController.selectBuildingByName('H'))
        .thenAnswer((_) async => false);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                Future.microtask(() {
                  NavigationUtils.openMappedinMap(
                    context: context,
                    mappedinController: mockMapController,
                    buildingName: 'H',
                  );
                });
                return Container();
              },
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Failed to switch to H Building'), findsOneWidget);
  });
}
