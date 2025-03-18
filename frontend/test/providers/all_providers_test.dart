import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:soen_390/providers/service_providers.dart';
import 'package:soen_390/utils/location_service.dart';
import 'package:soen_390/services/http_service.dart';

void main() {
  test('geolocatorProvider returns a GeolocatorPlatform instance', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final geolocator = container.read(geolocatorProvider);
    expect(geolocator, isA<GeolocatorPlatform>());
  });
  test('locationServiceProvider provides a LocationService instance', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final locationService = container.read(locationServiceProvider);
    expect(locationService, isA<LocationService>());
  });

  test('locationServiceProvider returns the singleton instance', () {
    final container = ProviderContainer();

    final instance1 = container.read(locationServiceProvider);
    final instance2 = container.read(locationServiceProvider);

    expect(instance1, same(instance2)); // Both should be the same instance
  });

  test('geolocatorProvider returns the same GeolocatorPlatform instance', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final geolocator1 = container.read(geolocatorProvider);
    final geolocator2 = container.read(geolocatorProvider);

    expect(geolocator1, same(geolocator2));
  });

  test('httpServiceProvider returns an HttpService instance', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final httpService = container.read(httpServiceProvider);
    expect(httpService, isA<HttpService>());
  });
}
