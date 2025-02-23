import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:osrm/osrm.dart';
import 'package:soen_390/services/route_service.dart';

void main() {
  group('Test route interactions', () {
    test('Test route service', () async {
      final from = LatLng(45.497288, -73.578843);
      final to = LatLng(45.495150, -73.577253);

      final result = await getRouteFromCoordinates(from: from, to: to);

      if (result != null) {
        final dist = result.distance;
        print('Distance: $dist');
        expect(dist, allOf(greaterThan(600), lessThan(700)));
      }
    });
    test('Bad coordinates', () async {
      final from = LatLng(1145.497288, -11173.578843);
      final to = LatLng(5645.495150, -56473.577253);

      expect(
        () async => await getRouteFromCoordinates(from: from, to: to),
        throwsA(isA<OsrmResponseException>()
            .having(
              (e) => e.code,
              'code',
              OsrmResponseCode.invalidQuery,
            )
            .having(
              (e) => e.message,
              'message',
              contains("Query string malformed close to position"),
            )),
      );
    });
    test('Test same coordinates', () async {
      final from = LatLng(45.497288, -73.578843);
      final to = LatLng(45.497288, -73.578843);

      final result = await getRouteFromCoordinates(from: from, to: to);

      if (result != null) {
        final dist = result.distance;
        print('Distance: $dist');
        expect(dist, equals(0));
      }
    });
  });
}
