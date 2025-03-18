import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soen_390/providers/service_providers.dart';
import 'package:soen_390/utils/location_service.dart';
import 'package:soen_390/services/http_service.dart';

void main() {
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

  test('httpServiceProvider returns an HttpService instance', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final httpService = container.read(httpServiceProvider);
    expect(httpService, isA<HttpService>());
  });
}
