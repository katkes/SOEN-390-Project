import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:soen_390/utils/campus_route_checker.dart';
import 'package:soen_390/utils/location_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'campus_route_checker_test.mocks.dart';

@GenerateMocks([LocationService])
void main() {
  late CampusRouteChecker campusRouteChecker;
  late MockLocationService mockLocationService;

  setUp(() {
    mockLocationService = MockLocationService();
    campusRouteChecker =
        CampusRouteChecker(locationService: mockLocationService);
  });

  group('CampusRouteChecker - isInterCampus', () {
    test('returns true when from LOY to SGW', () {
      final from = const LatLng(45.4586, -73.6401); // LOY
      final to = const LatLng(45.4973, -73.5784); // SGW

      when(mockLocationService.checkIfPositionIsAtLOY(from)).thenReturn(true);
      when(mockLocationService.checkIfPositionIsAtSGW(to)).thenReturn(true);
      when(mockLocationService.checkIfPositionIsAtSGW(from)).thenReturn(false);
      when(mockLocationService.checkIfPositionIsAtLOY(to)).thenReturn(false);

      final result = campusRouteChecker.isInterCampus(from: from, to: to);
      expect(result, isTrue);
    });

    test('returns true when from SGW to LOY', () {
      final from = const LatLng(45.4973, -73.5784); // SGW
      final to = const LatLng(45.4586, -73.6401); // LOY

      when(mockLocationService.checkIfPositionIsAtSGW(from)).thenReturn(true);
      when(mockLocationService.checkIfPositionIsAtLOY(to)).thenReturn(true);
      when(mockLocationService.checkIfPositionIsAtLOY(from)).thenReturn(false);
      when(mockLocationService.checkIfPositionIsAtSGW(to)).thenReturn(false);

      final result = campusRouteChecker.isInterCampus(from: from, to: to);
      expect(result, isTrue);
    });

    test('returns false when both at LOY', () {
      final from = const LatLng(45.4586, -73.6401);
      final to = const LatLng(45.4586, -73.6401);

      when(mockLocationService.checkIfPositionIsAtLOY(from)).thenReturn(true);
      when(mockLocationService.checkIfPositionIsAtLOY(to)).thenReturn(true);
      when(mockLocationService.checkIfPositionIsAtSGW(from)).thenReturn(false);
      when(mockLocationService.checkIfPositionIsAtSGW(to)).thenReturn(false);

      final result = campusRouteChecker.isInterCampus(from: from, to: to);
      expect(result, isFalse);
    });

    test('returns false when both at SGW', () {
      final from = const LatLng(45.4973, -73.5784);
      final to = const LatLng(45.4973, -73.5784);

      when(mockLocationService.checkIfPositionIsAtSGW(from)).thenReturn(true);
      when(mockLocationService.checkIfPositionIsAtSGW(to)).thenReturn(true);
      when(mockLocationService.checkIfPositionIsAtLOY(from)).thenReturn(false);
      when(mockLocationService.checkIfPositionIsAtLOY(to)).thenReturn(false);

      final result = campusRouteChecker.isInterCampus(from: from, to: to);
      expect(result, isFalse);
    });

    test('returns false when not inter-campus', () {
      final from = const LatLng(45.0, -73.0);
      final to = const LatLng(46.0, -74.0);

      when(mockLocationService.checkIfPositionIsAtSGW(from)).thenReturn(false);
      when(mockLocationService.checkIfPositionIsAtSGW(to)).thenReturn(false);
      when(mockLocationService.checkIfPositionIsAtLOY(from)).thenReturn(false);
      when(mockLocationService.checkIfPositionIsAtLOY(to)).thenReturn(false);

      final result = campusRouteChecker.isInterCampus(from: from, to: to);
      expect(result, isFalse);
    });
  });
}
