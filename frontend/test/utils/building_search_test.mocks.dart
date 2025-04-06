// Mocks generated by Mockito 5.4.5 from annotations
// in soen_390/test/utils/building_search_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i4;

import 'package:flutter_map/flutter_map.dart' as _i5;
import 'package:latlong2/latlong.dart' as _i3;
import 'package:mockito/mockito.dart' as _i1;
import 'package:soen_390/services/map_service.dart' as _i2;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: must_be_immutable
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

/// A class which mocks [MapService].
///
/// See the documentation for Mockito's code generation for more information.
class MockMapService extends _i1.Mock implements _i2.MapService {
  @override
  set onMarkerCleared(Function? _onMarkerCleared) => super.noSuchMethod(
        Invocation.setter(#onMarkerCleared, _onMarkerCleared),
        returnValueForMissingStub: null,
      );

  @override
  void selectPolygon(_i3.LatLng? location) => super.noSuchMethod(
        Invocation.method(#selectMarker, [location]),
        returnValueForMissingStub: null,
      );

  @override
  void startClearTimer() => super.noSuchMethod(
        Invocation.method(#startClearTimer, []),
        returnValueForMissingStub: null,
      );

  @override
  _i4.Future<List<_i5.Marker>> loadBuildingMarkers(Function? onMarkerTapped) =>
      (super.noSuchMethod(
        Invocation.method(#loadBuildingMarkers, [onMarkerTapped]),
        returnValue: _i4.Future<List<_i5.Marker>>.value(<_i5.Marker>[]),
        returnValueForMissingStub: _i4.Future<List<_i5.Marker>>.value(
          <_i5.Marker>[],
        ),
      ) as _i4.Future<List<_i5.Marker>>);

  @override
  _i4.Future<List<_i5.Polygon<Object>>> loadBuildingPolygons() =>
      (super.noSuchMethod(
        Invocation.method(#loadBuildingPolygons, []),
        returnValue: _i4.Future<List<_i5.Polygon<Object>>>.value(
          <_i5.Polygon<Object>>[],
        ),
        returnValueForMissingStub: _i4.Future<List<_i5.Polygon<Object>>>.value(
          <_i5.Polygon<Object>>[],
        ),
      ) as _i4.Future<List<_i5.Polygon<Object>>>);

  @override
  _i4.Future<List<String>> getBuildingSuggestions(String? query) =>
      (super.noSuchMethod(
        Invocation.method(#getBuildingSuggestions, [query]),
        returnValue: _i4.Future<List<String>>.value(<String>[]),
        returnValueForMissingStub: _i4.Future<List<String>>.value(
          <String>[],
        ),
      ) as _i4.Future<List<String>>);

  @override
  _i4.Future<Map<String, dynamic>?> searchBuildingWithDetails(
    String? buildingName,
  ) =>
      (super.noSuchMethod(
        Invocation.method(#searchBuildingWithDetails, [buildingName]),
        returnValue: _i4.Future<Map<String, dynamic>?>.value(),
        returnValueForMissingStub: _i4.Future<Map<String, dynamic>?>.value(),
      ) as _i4.Future<Map<String, dynamic>?>);

  @override
  _i4.Future<String?> findCampusForBuilding(String? buildingName) =>
      (super.noSuchMethod(
        Invocation.method(#findCampusForBuilding, [buildingName]),
        returnValue: _i4.Future<String?>.value(),
        returnValueForMissingStub: _i4.Future<String?>.value(),
      ) as _i4.Future<String?>);
}
