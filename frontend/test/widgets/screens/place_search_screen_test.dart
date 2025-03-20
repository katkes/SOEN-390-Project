import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:soen_390/models/outdoor_poi.dart';
import 'package:soen_390/models/places.dart';
import 'package:soen_390/screens/outdoor_poi/outdoor_poi_detail_screen.dart';
import 'package:soen_390/screens/outdoor_poi/place_search_screen.dart';
import 'package:soen_390/services/google_poi_service.dart';
import 'package:soen_390/services/poi_factory.dart';
import 'package:soen_390/utils/location_service.dart';
import 'package:soen_390/widgets/poi_search_bar.dart';
import 'package:soen_390/widgets/poi_type_selector.dart';
import 'package:soen_390/widgets/poi_list_view.dart';
import 'package:latlong2/latlong.dart';

import 'place_search_screen_test.mocks.dart';

@GenerateMocks([GooglePOIService, LocationService, PointOfInterestFactory])
void main() {
  dotenv.testLoad(fileInput: '''
GOOGLE_PLACES_API_KEY=TEST_API_KEY
''');
  late MockLocationService mockLocationService;
  late MockGooglePOIService mockPoiService;
  late MockPointOfInterestFactory mockPoiFactory;

  setUp(() {
    mockLocationService = MockLocationService();
    mockPoiService = MockGooglePOIService();
    mockPoiFactory = MockPointOfInterestFactory();
  });

  Widget createTestWidget() {
    return MaterialApp(
      home: PlaceSearchScreen(
        locationService: mockLocationService,
        poiService: mockPoiService,
        poiFactory: mockPoiFactory,
      ),
    );
  }

  testWidgets('renders core widgets', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());
    expect(find.byType(POISearchBar), findsOneWidget);
    expect(find.byType(POITypeSelector), findsOneWidget);
    expect(find.byType(POIListView), findsOneWidget);
  });

  testWidgets('uses current location on button tap',
      (WidgetTester tester) async {
    when(mockLocationService.startUp()).thenAnswer((_) async {});
    when(mockLocationService.getCurrentLocationAccurately()).thenAnswer(
        (_) async => Position(
            latitude: 45.0,
            longitude: -73.0,
            timestamp: DateTime.now(),
            accuracy: 1,
            altitude: 1,
            heading: 1,
            speed: 1,
            speedAccuracy: 1,
            altitudeAccuracy: 1,
            headingAccuracy: 1,
            isMocked: false));
    when(mockLocationService.convertPositionToLatLng(any))
        .thenReturn(const LatLng(45.0, -73.0));

    await tester.pumpWidget(createTestWidget());

    // Tap the location button inside POISearchBar
    await tester.tap(find.byIcon(Icons.my_location));
    await tester.pump();

    verify(mockLocationService.startUp()).called(1);
    verify(mockLocationService.getCurrentLocationAccurately()).called(1);
  });

  testWidgets('uses current location and loads POIs into UI',
      (WidgetTester tester) async {
    // Mock LocationService behavior
    when(mockLocationService.startUp()).thenAnswer((_) async {});
    when(mockLocationService.getCurrentLocationAccurately()).thenAnswer(
      (_) async => Position(
        latitude: 45.0,
        longitude: -73.0,
        timestamp: DateTime.now(),
        accuracy: 1,
        altitude: 1,
        heading: 1,
        speed: 1,
        speedAccuracy: 1,
        altitudeAccuracy: 1,
        headingAccuracy: 1,
        isMocked: false,
      ),
    );
    when(mockLocationService.convertPositionToLatLng(any))
        .thenReturn(const LatLng(45.0, -73.0));

    // Mock POI fetching based on location + type
    final testPlace = Place(
      name: 'Location Place',
      placeId: 'loc_place_1',
      businessStatus: 'OPERATIONAL',
      latitude: 45.0,
      longitude: -73.0,
      address: '456 St',
      types: ['restaurant'],
      rating: 4.3,
      userRatingsTotal: 80,
      priceLevel: 1,
      openNow: true,
      photoReference: null,
      iconUrl: '',
      plusCode: null,
    );

    when(mockPoiService.getNearbyPlaces(
      latitude: 45.0,
      longitude: -73.0,
      type: 'restaurant',
      radius: 1500,
    )).thenAnswer((_) async => [testPlace]);

    await tester.pumpWidget(createTestWidget());

    // Tap location icon
    await tester.tap(find.byIcon(Icons.my_location));
    await tester.pumpAndSettle(); // Wait for location fetch

    // Tap POI type "RESTAURANT"
    await tester.tap(find.text('RESTAURANT'));
    await tester.pumpAndSettle(); // Wait for POI fetch

    // Verify services were called
    verify(mockLocationService.startUp()).called(1);
    verify(mockLocationService.getCurrentLocationAccurately()).called(1);
    verify(mockPoiService.getNearbyPlaces(
      latitude: 45.0,
      longitude: -73.0,
      type: 'restaurant',
      radius: 1500,
    )).called(1);

    // Verify the fetched place appears in the UI
    expect(find.text('Location Place'), findsOneWidget);
  });

  testWidgets('tapping a place creates POI and navigates',
      (WidgetTester tester) async {
    final testPlace = Place(
      name: 'Tap Place',
      placeId: 'place_123',
      businessStatus: 'OPERATIONAL',
      latitude: 45.0,
      longitude: -73.0,
      address: '123 St',
      types: ['park'],
      rating: 4.0,
      userRatingsTotal: 50,
      priceLevel: 1,
      openNow: true,
      photoReference: null,
      iconUrl: '',
      plusCode: null,
    );

    final testPOI = const PointOfInterest(
      id: 'place_123',
      name: 'Tap Place',
      description: 'A nice place',
      imageUrl: '',
      latitude: 0.0,
      longitude: 0.0,
    );

    when(mockPoiFactory.createPointOfInterest(
            placeId: anyNamed('placeId'), imageUrl: anyNamed('imageUrl')))
        .thenAnswer((_) async => testPOI);

    await tester.pumpWidget(createTestWidget());

    final dynamic state = tester.state(find.byType(PlaceSearchScreen));
    state.testSetPlaces([testPlace]);

    await tester.pump();

    await tester.tap(find.text('Tap Place'));
    await tester.pumpAndSettle();

    verify(mockPoiFactory.createPointOfInterest(
      placeId: 'place_123',
      imageUrl: '',
    )).called(1);

    // Verify navigation happened (new screen exists)
    expect(find.byType(PoiDetailScreen), findsOneWidget);
  });

testWidgets('shows SnackBar on POI fetch error', (WidgetTester tester) async {
    // Mock failure from POI service
    when(mockPoiService.getNearbyPlaces(
      latitude: 45.0,
      longitude: -73.0,
      type: 'restaurant',
      radius: 1500,
    )).thenThrow(Exception('Failed to fetch POIs'));

    when(mockLocationService.startUp()).thenAnswer((_) async {});
    when(mockLocationService.getCurrentLocationAccurately()).thenAnswer(
      (_) async => Position(
        latitude: 45.0,
        longitude: -73.0,
        timestamp: DateTime.now(),
        accuracy: 1,
        altitude: 1,
        heading: 1,
        speed: 1,
        speedAccuracy: 1,
        altitudeAccuracy: 1,
        headingAccuracy: 1,
        isMocked: false,
      ),
    );
    when(mockLocationService.convertPositionToLatLng(any))
        .thenReturn(const LatLng(45.0, -73.0));

    await tester.pumpWidget(MaterialApp(
        home: PlaceSearchScreen(
      locationService: mockLocationService,
      poiService: mockPoiService,
      poiFactory: mockPoiFactory,
    )));

    // Simulate user pressing the location button to set location
    await tester.tap(find.byIcon(Icons.my_location));
    await tester.pumpAndSettle();

    // Simulate user selecting POI type to trigger _onTypeSelected
    await tester.tap(find.text('RESTAURANT'));
    await tester.pumpAndSettle();

    // Expect error message in SnackBar
    expect(find.text('Failed to fetch places'), findsOneWidget);
  });

  testWidgets('shows SnackBar on location fetch error',
      (WidgetTester tester) async {
    when(mockLocationService.startUp()).thenAnswer((_) async {});
    when(mockLocationService.getCurrentLocationAccurately())
        .thenThrow(Exception('Location error'));

    await tester.pumpWidget(createTestWidget());

    await tester.tap(find.byIcon(Icons.my_location));
    await tester.pumpAndSettle();

    expect(find.text('Unable to fetch current location'), findsOneWidget);
  });

  testWidgets('shows loading indicator while fetching POIs',
      (WidgetTester tester) async {
    when(mockLocationService.startUp()).thenAnswer((_) async {});
    when(mockLocationService.getCurrentLocationAccurately()).thenAnswer(
      (_) async => Position(
        latitude: 45.0,
        longitude: -73.0,
        timestamp: DateTime.now(),
        accuracy: 1,
        altitude: 1,
        heading: 1,
        speed: 1,
        speedAccuracy: 1,
        altitudeAccuracy: 1,
        headingAccuracy: 1,
        isMocked: false,
      ),
    );
    when(mockLocationService.convertPositionToLatLng(any))
        .thenReturn(const LatLng(45.0, -73.0));

    final completer = Completer<List<Place>>();
    when(mockPoiService.getNearbyPlaces(
      latitude: 45.0,
      longitude: -73.0,
      type: 'park',
      radius: 1500,
    )).thenAnswer((_) => completer.future);

    await tester.pumpWidget(MaterialApp(
        home: PlaceSearchScreen(
      locationService: mockLocationService,
      poiService: mockPoiService,
      poiFactory: mockPoiFactory,
    )));

    await tester.tap(find.byIcon(Icons.my_location));
    await tester.pumpAndSettle();

    await tester.tap(find.text('PARK'));
    await tester.pump();

    // Loading indicator should be shown while POI fetch is pending
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Complete the future to stop loading
    completer.complete([]);
    await tester.pumpAndSettle();

    // Loading indicator gone
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('_updateLocation triggers POI fetch if type is set',
      (WidgetTester tester) async {
    // Arrange: Mock POI service
    when(mockPoiService.getNearbyPlaces(
      latitude: 45.0,
      longitude: -73.0,
      type: 'park',
      radius: 1500,
    )).thenAnswer((_) async => []);

    await tester.pumpWidget(MaterialApp(
      home: PlaceSearchScreen(
        locationService: mockLocationService,
        poiService: mockPoiService,
        poiFactory: mockPoiFactory,
      ),
    ));

    // Step 1: Simulate location update first
    final searchBarFinder = find.byType(POISearchBar);
    final searchBarWidget = tester.widget<POISearchBar>(searchBarFinder);
    searchBarWidget.onSearch('Test Address', 45.0, -73.0);
    await tester.pump(); // allow location state update

    // Step 2: Now select the POI type ("PARK")
    await tester.tap(find.text('PARK'));
    await tester.pumpAndSettle(); // triggers POI fetch

    // Assert: Verify POI service was called with correct location and type
    verify(mockPoiService.getNearbyPlaces(
      latitude: 45.0,
      longitude: -73.0,
      type: 'park',
      radius: 1500,
    )).called(1);
  });

  testWidgets('does not fetch POIs if location is null',
      (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());

    await tester.tap(find.text('RESTAURANT'));
    await tester.pumpAndSettle();

    verifyNever(mockPoiService.getNearbyPlaces(
      latitude: anyNamed('latitude'),
      longitude: anyNamed('longitude'),
      type: anyNamed('type'),
      radius: anyNamed('radius'),
    ));
  });

}
