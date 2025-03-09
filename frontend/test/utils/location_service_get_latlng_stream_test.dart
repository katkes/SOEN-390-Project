/// This test suite is designed to verify the behavior of the `LocationService`
/// class, specifically the `getLatLngStream` method. The primary goal is to
/// ensure that the `LocationService` correctly converts `geo.Position`
/// objects (from the `geolocator` package) into `LatLng` objects (from the
/// `latlong2` package).

library;

import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:mockito/mockito.dart';
import 'package:soen_390/utils/location_service.dart';

class MockGeolocator extends Mock implements geo.GeolocatorPlatform {
  @override
  Stream<geo.Position> getPositionStream(
      {geo.LocationSettings? locationSettings}) {
    return super.noSuchMethod(
      Invocation.method(
          #getPositionStream, [], {#locationSettings: locationSettings}),
      returnValue: const Stream<geo.Position>.empty(),
    );
  }
}

void main() {
  group('LocationService', () {
    late MockGeolocator mockGeolocator;
    late LocationService locationService;

    setUp(() {
      mockGeolocator = MockGeolocator();
      locationService = LocationService(geolocator: mockGeolocator);

      // Initialize location settings
      locationService.setPlatformSpecificLocationSettings();
    });

    test('getLatLngStream should convert geo.Position to LatLng', () async {
      final controller = StreamController<geo.Position>();

      // Set up the mock to return our controlled stream
      when(mockGeolocator.getPositionStream(
        locationSettings: anyNamed('locationSettings'),
      )).thenAnswer((_) => controller.stream);

      // Start listening to the LatLng stream
      final latLngStreamFuture = locationService.getLatLngStream().toList();

      final position1 = MockPosition(12.3456, 65.4321);
      final position2 = MockPosition(23.4567, 76.5432);

      controller.add(position1);
      controller.add(position2);

      // Close the controller to complete the stream
      await controller.close();

      final result = await latLngStreamFuture;

      expect(result.length, 2);
      expect(result[0].latitude, 12.3456);
      expect(result[0].longitude, 65.4321);
      expect(result[1].latitude, 23.4567);
      expect(result[1].longitude, 76.5432);
    });

    test('getLatLngStream should handle an empty position stream gracefully',
        () async {
      // Mock an empty position stream
      when(mockGeolocator.getPositionStream(
        locationSettings: anyNamed('locationSettings'),
      )).thenAnswer((_) => const Stream<geo.Position>.empty());

      // Get the LatLng stream from LocationService
      final result = await locationService.getLatLngStream().toList();

      expect(result, isEmpty);
    });

    tearDown(() {
      LocationService.resetInstance();
    });
  });
}

// ignore_for_file: must_be_immutable // Suppress the immutability warning
class MockPosition extends Mock implements geo.Position {
  @override
  final double latitude;

  @override
  final double longitude;

  MockPosition(this.latitude, this.longitude);
}
