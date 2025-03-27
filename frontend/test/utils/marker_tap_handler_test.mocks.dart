// Mocks generated by Mockito 5.4.5 from annotations
// in soen_390/test/utils/marker_tap_handler_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i4;
import 'dart:ui' as _i6;

import 'package:flutter_map/flutter_map.dart' as _i2;
import 'package:latlong2/latlong.dart' as _i5;
import 'package:mockito/mockito.dart' as _i1;
import 'package:soen_390/services/interfaces/maps_api_client.dart' as _i3;
import 'package:soen_390/widgets/building_popup.dart' as _i7;

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

class _FakeMapCamera_0 extends _i1.SmartFake implements _i2.MapCamera {
  _FakeMapCamera_0(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class _FakeMapsApiClient_1 extends _i1.SmartFake implements _i3.MapsApiClient {
  _FakeMapsApiClient_1(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

/// A class which mocks [MapController].
///
/// See the documentation for Mockito's code generation for more information.
class MockMapController extends _i1.Mock implements _i2.MapController {
  @override
  _i4.Stream<_i2.MapEvent> get mapEventStream =>
      (super.noSuchMethod(
            Invocation.getter(#mapEventStream),
            returnValue: _i4.Stream<_i2.MapEvent>.empty(),
            returnValueForMissingStub: _i4.Stream<_i2.MapEvent>.empty(),
          )
          as _i4.Stream<_i2.MapEvent>);

  @override
  _i2.MapCamera get camera =>
      (super.noSuchMethod(
            Invocation.getter(#camera),
            returnValue: _FakeMapCamera_0(this, Invocation.getter(#camera)),
            returnValueForMissingStub: _FakeMapCamera_0(
              this,
              Invocation.getter(#camera),
            ),
          )
          as _i2.MapCamera);

  @override
  bool move(
    _i5.LatLng? center,
    double? zoom, {
    _i6.Offset? offset = _i6.Offset.zero,
    String? id,
  }) =>
      (super.noSuchMethod(
            Invocation.method(
              #move,
              [center, zoom],
              {#offset: offset, #id: id},
            ),
            returnValue: false,
            returnValueForMissingStub: false,
          )
          as bool);

  @override
  bool rotate(double? degree, {String? id}) =>
      (super.noSuchMethod(
            Invocation.method(#rotate, [degree], {#id: id}),
            returnValue: false,
            returnValueForMissingStub: false,
          )
          as bool);

  @override
  ({bool moveSuccess, bool rotateSuccess}) rotateAroundPoint(
    double? degree, {
    _i6.Offset? offset,
    String? id,
  }) =>
      (super.noSuchMethod(
            Invocation.method(
              #rotateAroundPoint,
              [degree],
              {#offset: offset, #id: id},
            ),
            returnValue: (moveSuccess: false, rotateSuccess: false),
            returnValueForMissingStub: (
              moveSuccess: false,
              rotateSuccess: false,
            ),
          )
          as ({bool moveSuccess, bool rotateSuccess}));

  @override
  ({bool moveSuccess, bool rotateSuccess}) moveAndRotate(
    _i5.LatLng? center,
    double? zoom,
    double? degree, {
    String? id,
  }) =>
      (super.noSuchMethod(
            Invocation.method(
              #moveAndRotate,
              [center, zoom, degree],
              {#id: id},
            ),
            returnValue: (moveSuccess: false, rotateSuccess: false),
            returnValueForMissingStub: (
              moveSuccess: false,
              rotateSuccess: false,
            ),
          )
          as ({bool moveSuccess, bool rotateSuccess}));

  @override
  bool fitCamera(_i2.CameraFit? cameraFit) =>
      (super.noSuchMethod(
            Invocation.method(#fitCamera, [cameraFit]),
            returnValue: false,
            returnValueForMissingStub: false,
          )
          as bool);

  @override
  void dispose() => super.noSuchMethod(
    Invocation.method(#dispose, []),
    returnValueForMissingStub: null,
  );
}

/// A class which mocks [BuildingPopUps].
///
/// See the documentation for Mockito's code generation for more information.
class MockBuildingPopUps extends _i1.Mock implements _i7.BuildingPopUps {
  @override
  _i3.MapsApiClient get mapsApiClient =>
      (super.noSuchMethod(
            Invocation.getter(#mapsApiClient),
            returnValue: _FakeMapsApiClient_1(
              this,
              Invocation.getter(#mapsApiClient),
            ),
            returnValueForMissingStub: _FakeMapsApiClient_1(
              this,
              Invocation.getter(#mapsApiClient),
            ),
          )
          as _i3.MapsApiClient);

  @override
  _i4.Future<Map<String, dynamic>> fetchBuildingInformation(
    double? latitude,
    double? longitude,
    String? locationName,
  ) =>
      (super.noSuchMethod(
            Invocation.method(#fetchBuildingInformation, [
              latitude,
              longitude,
              locationName,
            ]),
            returnValue: _i4.Future<Map<String, dynamic>>.value(
              <String, dynamic>{},
            ),
            returnValueForMissingStub: _i4.Future<Map<String, dynamic>>.value(
              <String, dynamic>{},
            ),
          )
          as _i4.Future<Map<String, dynamic>>);
}
