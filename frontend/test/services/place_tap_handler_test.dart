import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:soen_390/models/places.dart';
import 'package:soen_390/models/outdoor_poi.dart';
import 'package:soen_390/services/place_tap_handler.dart';
import 'package:soen_390/services/poi_factory.dart';

import 'place_tap_handler_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<PointOfInterestFactory>(),
  MockSpec<NavigatorObserver>(),
])
void main() {
  late MockPointOfInterestFactory mockPoiFactory;
  late MockNavigatorObserver mockNavigatorObserver;
  late bool callbackInvoked;
  late String destinationName;
  late double destinationLat, destinationLng;

  setUp(() {
    mockPoiFactory = MockPointOfInterestFactory();
    mockNavigatorObserver = MockNavigatorObserver();
    callbackInvoked = false;
  });

  Widget createTestWidget({required Widget child}) {
    return MaterialApp(
      home: Scaffold(body: child),
      navigatorObservers: [mockNavigatorObserver],
    );
  }

  group('PlaceTapHandler tests', () {
    testWidgets('successful navigation and callback invocation',
        (tester) async {
      final testPlace = Place(
        placeId: 'test_id',
        name: 'Test Place',
        businessStatus: 'OPERATIONAL',
        latitude: 45.0,
        longitude: -73.0,
        address: '123 Test St',
        types: ['restaurant'],
        rating: 4.5,
        userRatingsTotal: 100,
        iconUrl: 'http://example.com/icon.png',
      );

      final testPoi = const PointOfInterest(
        id: 'test_poi_id',
        name: 'Test POI',
        description: 'A test point of interest',
        latitude: 12.34,
        longitude: 56.78,
      );

      when(mockPoiFactory.createPointOfInterest(
        placeId: anyNamed('placeId'),
        imageUrl: anyNamed('imageUrl'),
      )).thenAnswer((_) async => testPoi);

      // Declare a stable BuildContext to use after navigation
      late BuildContext stableContext;

      await tester.pumpWidget(createTestWidget(
        child: Builder(builder: (context) {
          stableContext = context; // Assign stable context here
          return ElevatedButton(
            onPressed: () {
              PlaceTapHandler(
                context: context,
                apiKey: 'dummyKey',
                poiFactory: mockPoiFactory,
                onSetDestination: (name, lat, lng) {
                  callbackInvoked = true;
                  destinationName = name;
                  destinationLat = lat;
                  destinationLng = lng;
                },
              ).handle(testPlace);
            },
            child: const Text('Tap Me'),
          );
        }),
      ));

      await tester.tap(find.text('Tap Me'));
      await tester.pumpAndSettle();

      verify(mockNavigatorObserver.didPush(any, any))
          .called(greaterThanOrEqualTo(1));

      // Now use the stableContext to pop the route
      Navigator.of(stableContext).pop({
        'name': testPoi.name,
        'lat': testPoi.latitude,
        'lng': testPoi.longitude,
      });

      await tester.pumpAndSettle();

      expect(callbackInvoked, isTrue);
      expect(destinationName, equals(testPoi.name));
      expect(destinationLat, equals(testPoi.latitude));
      expect(destinationLng, equals(testPoi.longitude));
    });

    testWidgets('handles exception gracefully with SnackBar', (tester) async {
      final testPlace = Place(
        placeId: 'error_id',
        name: 'Error Place',
        businessStatus: 'CLOSED',
        latitude: 40.0,
        longitude: -70.0,
        address: '404 Error St',
        types: ['error_place'],
        rating: 0.0,
        userRatingsTotal: 0,
        iconUrl: 'http://example.com/error_icon.png',
      );

      when(mockPoiFactory.createPointOfInterest(
        placeId: anyNamed('placeId'),
        imageUrl: anyNamed('imageUrl'),
      )).thenThrow(Exception('API Error'));

      await tester.pumpWidget(createTestWidget(
        child: Builder(builder: (context) {
          return ElevatedButton(
            onPressed: () {
              PlaceTapHandler(
                context: context,
                apiKey: 'dummyKey',
                poiFactory: mockPoiFactory,
              ).handle(testPlace);
            },
            child: const Text('Trigger Error'),
          );
        }),
      ));

      await tester.tap(find.text('Trigger Error'));
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Failed to load place details.'), findsOneWidget);
    });
  });
}
