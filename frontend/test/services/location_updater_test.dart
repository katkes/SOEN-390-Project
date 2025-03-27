import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:soen_390/utils/location_service.dart';
import 'package:soen_390/services/location_updater.dart';
import 'package:geolocator/geolocator.dart' as geo;

@GenerateMocks([LocationService])
import 'location_updater_test.mocks.dart';

void main() {
  group('LocationUpdater', () {
    late MockLocationService mockService;
    late LocationUpdater locationUpdater;

    setUp(() {
      mockService = MockLocationService();
      locationUpdater = LocationUpdater(mockService);
    });

    test(
        'getCurrentLatLng calls startUp, getCurrentLocationAccurately, and convertPositionToLatLng',
        () async {
      // Correctly create a mock geo.Position object
      final mockPosition = geo.Position(
        latitude: 45.5017,
        longitude: -73.5673,
        timestamp: DateTime.now(),
        accuracy: 1,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      );

      final expectedLatLng = LatLng(45.5017, -73.5673);

      when(mockService.startUp()).thenAnswer((_) async {});
      when(mockService.getCurrentLocationAccurately())
          .thenAnswer((_) async => mockPosition);
      when(mockService.convertPositionToLatLng(mockPosition))
          .thenReturn(expectedLatLng);

      final result = await locationUpdater.getCurrentLatLng();

      verify(mockService.startUp()).called(1);
      verify(mockService.getCurrentLocationAccurately()).called(1);
      verify(mockService.convertPositionToLatLng(mockPosition)).called(1);
      expect(result, expectedLatLng);
    });

    test('getCurrentLatLng throws exception if startUp fails', () async {
      when(mockService.startUp())
          .thenThrow(Exception('Failed to initialize location service'));

      expect(() async => await locationUpdater.getCurrentLatLng(),
          throwsException);
      verify(mockService.startUp()).called(1);
      verifyNever(mockService.getCurrentLocationAccurately());
      verifyNever(mockService.convertPositionToLatLng(any));
    });

    test(
        'getCurrentLatLng throws exception if getCurrentLocationAccurately fails',
        () async {
      // Correctly stub startUp() to complete successfully
      when(mockService.startUp()).thenAnswer((_) async {});

      // Explicitly make getCurrentLocationAccurately throw
      when(mockService.getCurrentLocationAccurately())
          .thenThrow(Exception('Failed to get location'));

      // Invoke the method and expect it to throw
      expect(() => locationUpdater.getCurrentLatLng(), throwsException);

      // Wait explicitly to ensure async behavior completes before verification
      await untilCalled(mockService.getCurrentLocationAccurately());

      verify(mockService.startUp()).called(1);
      verify(mockService.getCurrentLocationAccurately()).called(1);
      verifyNever(mockService.convertPositionToLatLng(any));
    });
  });
}
