import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:soen_390/utils/google_directions_url_builder.dart';

void main() {
  final apiKey = 'test_api_key';
  late GoogleDirectionsUrlBuilder builder;

  setUp(() {
    builder = GoogleDirectionsUrlBuilder(apiKey: apiKey);
  });

  test('builds basic URL with required parameters', () {
    final url = builder.buildRequestUrl(
        from: const LatLng(45.5017, -73.5673),
        to: const LatLng(45.4972, -73.5789),
        mode: 'driving');

    expect(url, contains('origin=45.5017,-73.5673'));
    expect(url, contains('destination=45.4972,-73.5789'));
    expect(url, contains('mode=driving'));
    expect(url, contains('key=test_api_key'));
  });

  test('includes alternatives parameter when set to true', () {
    final url = builder.buildRequestUrl(
        from: const LatLng(45.5017, -73.5673),
        to: const LatLng(45.4972, -73.5789),
        mode: 'driving',
        alternatives: true);

    expect(url, contains('alternatives=true'));
  });

  test('includes departure time for non-walking modes', () {
    final departureTime = DateTime(2024, 1, 1, 12, 0);
    final url = builder.buildRequestUrl(
        from: const LatLng(45.5017, -73.5673),
        to: const LatLng(45.4972, -73.5789),
        mode: 'driving',
        departureTime: departureTime);

    expect(
        url,
        contains(
            'departure_time=${departureTime.millisecondsSinceEpoch ~/ 1000}'));
  });

  test('excludes departure time for walking mode', () {
    final departureTime = DateTime(2024, 1, 1, 12, 0);
    final url = builder.buildRequestUrl(
        from: const LatLng(45.5017, -73.5673),
        to: const LatLng(45.4972, -73.5789),
        mode: 'walking',
        departureTime: departureTime);

    expect(url, isNot(contains('departure_time')));
  });

  test('includes arrival time for transit mode', () {
    final arrivalTime = DateTime(2024, 1, 1, 12, 0);
    final url = builder.buildRequestUrl(
        from: const LatLng(45.5017, -73.5673),
        to: const LatLng(45.4972, -73.5789),
        mode: 'transit',
        arrivalTime: arrivalTime);

    expect(url,
        contains('arrival_time=${arrivalTime.millisecondsSinceEpoch ~/ 1000}'));
  });
}
