// Mocks generated by Mockito 5.4.5 from annotations
// in soen_390/test/services/google_route_service_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i6;

import 'package:geolocator/geolocator.dart' as _i3;
import 'package:http/http.dart' as _i2;
import 'package:latlong2/latlong.dart' as _i4;
import 'package:mockito/mockito.dart' as _i1;
import 'package:soen_390/services/interfaces/http_client_interface.dart' as _i5;
import 'package:soen_390/utils/location_service.dart' as _i7;

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

class _FakeResponse_0 extends _i1.SmartFake implements _i2.Response {
  _FakeResponse_0(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

class _FakeGeolocatorPlatform_1 extends _i1.SmartFake
    implements _i3.GeolocatorPlatform {
  _FakeGeolocatorPlatform_1(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

class _FakePosition_2 extends _i1.SmartFake implements _i3.Position {
  _FakePosition_2(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

class _FakeLocationSettings_3 extends _i1.SmartFake
    implements _i3.LocationSettings {
  _FakeLocationSettings_3(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

class _FakeLatLng_4 extends _i1.SmartFake implements _i4.LatLng {
  _FakeLatLng_4(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

/// A class which mocks [IHttpClient].
///
/// See the documentation for Mockito's code generation for more information.
class MockIHttpClient extends _i1.Mock implements _i5.IHttpClient {
  MockIHttpClient() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i6.Future<_i2.Response> get(Uri? url) => (super.noSuchMethod(
        Invocation.method(#get, [url]),
        returnValue: _i6.Future<_i2.Response>.value(
          _FakeResponse_0(this, Invocation.method(#get, [url])),
        ),
      ) as _i6.Future<_i2.Response>);
}

/// A class which mocks [LocationService].
///
/// See the documentation for Mockito's code generation for more information.
class MockLocationService extends _i1.Mock implements _i7.LocationService {
  MockLocationService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.GeolocatorPlatform get geolocator => (super.noSuchMethod(
        Invocation.getter(#geolocator),
        returnValue: _FakeGeolocatorPlatform_1(
          this,
          Invocation.getter(#geolocator),
        ),
      ) as _i3.GeolocatorPlatform);

  @override
  _i3.Position get currentPosition => (super.noSuchMethod(
        Invocation.getter(#currentPosition),
        returnValue: _FakePosition_2(
          this,
          Invocation.getter(#currentPosition),
        ),
      ) as _i3.Position);

  @override
  set currentPosition(_i3.Position? _currentPosition) => super.noSuchMethod(
        Invocation.setter(#currentPosition, _currentPosition),
        returnValueForMissingStub: null,
      );

  @override
  _i3.LocationSettings get locSetting => (super.noSuchMethod(
        Invocation.getter(#locSetting),
        returnValue: _FakeLocationSettings_3(
          this,
          Invocation.getter(#locSetting),
        ),
      ) as _i3.LocationSettings);

  @override
  set locSetting(_i3.LocationSettings? _locSetting) => super.noSuchMethod(
        Invocation.setter(#locSetting, _locSetting),
        returnValueForMissingStub: null,
      );

  @override
  bool get serviceEnabled => (super.noSuchMethod(
        Invocation.getter(#serviceEnabled),
        returnValue: false,
      ) as bool);

  @override
  set serviceEnabled(bool? _serviceEnabled) => super.noSuchMethod(
        Invocation.setter(#serviceEnabled, _serviceEnabled),
        returnValueForMissingStub: null,
      );

  @override
  _i3.LocationPermission get permission => (super.noSuchMethod(
        Invocation.getter(#permission),
        returnValue: _i3.LocationPermission.denied,
      ) as _i3.LocationPermission);

  @override
  set permission(_i3.LocationPermission? _permission) => super.noSuchMethod(
        Invocation.setter(#permission, _permission),
        returnValueForMissingStub: null,
      );

  @override
  _i6.Future<bool> isLocationEnabled() => (super.noSuchMethod(
        Invocation.method(#isLocationEnabled, []),
        returnValue: _i6.Future<bool>.value(false),
      ) as _i6.Future<bool>);

  @override
  _i6.Future<bool> determinePermissions() => (super.noSuchMethod(
        Invocation.method(#determinePermissions, []),
        returnValue: _i6.Future<bool>.value(false),
      ) as _i6.Future<bool>);

  @override
  _i6.Future<_i3.Position> getCurrentLocation() => (super.noSuchMethod(
        Invocation.method(#getCurrentLocation, []),
        returnValue: _i6.Future<_i3.Position>.value(
          _FakePosition_2(this, Invocation.method(#getCurrentLocation, [])),
        ),
      ) as _i6.Future<_i3.Position>);

  @override
  _i6.Future<void> updateCurrentLocation() => (super.noSuchMethod(
        Invocation.method(#updateCurrentLocation, []),
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);

  @override
  _i6.Future<_i3.Position> getCurrentLocationAccurately() =>
      (super.noSuchMethod(
        Invocation.method(#getCurrentLocationAccurately, []),
        returnValue: _i6.Future<_i3.Position>.value(
          _FakePosition_2(
            this,
            Invocation.method(#getCurrentLocationAccurately, []),
          ),
        ),
      ) as _i6.Future<_i3.Position>);

  @override
  _i6.Future<void> updateCurrentLocationAccurately() => (super.noSuchMethod(
        Invocation.method(#updateCurrentLocationAccurately, []),
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);

  @override
  void takePosition(_i3.Position? p) => super.noSuchMethod(
        Invocation.method(#takePosition, [p]),
        returnValueForMissingStub: null,
      );

  @override
  void setPlatformSpecificLocationSettings() => super.noSuchMethod(
        Invocation.method(#setPlatformSpecificLocationSettings, []),
        returnValueForMissingStub: null,
      );

  @override
  void createLocationStream() => super.noSuchMethod(
        Invocation.method(#createLocationStream, []),
        returnValueForMissingStub: null,
      );

  @override
  _i6.Future<void> startUp() => (super.noSuchMethod(
        Invocation.method(#startUp, []),
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);

  @override
  void stopListening() => super.noSuchMethod(
        Invocation.method(#stopListening, []),
        returnValueForMissingStub: null,
      );

  @override
  bool checkIfPositionIsAtSGW(_i4.LatLng? coordinates) => (super.noSuchMethod(
        Invocation.method(#checkIfPositionIsAtSGW, [coordinates]),
        returnValue: false,
      ) as bool);

  @override
  bool checkIfPositionIsAtLOY(_i4.LatLng? coordinates) => (super.noSuchMethod(
        Invocation.method(#checkIfPositionIsAtLOY, [coordinates]),
        returnValue: false,
      ) as bool);

  @override
  _i6.Stream<_i3.Position> getPositionStream() => (super.noSuchMethod(
        Invocation.method(#getPositionStream, []),
        returnValue: _i6.Stream<_i3.Position>.empty(),
      ) as _i6.Stream<_i3.Position>);

  @override
  _i4.LatLng convertPositionToLatLng(_i3.Position? p) => (super.noSuchMethod(
        Invocation.method(#convertPositionToLatLng, [p]),
        returnValue: _FakeLatLng_4(
          this,
          Invocation.method(#convertPositionToLatLng, [p]),
        ),
      ) as _i4.LatLng);

  @override
  _i6.Stream<_i4.LatLng> getLatLngStream() => (super.noSuchMethod(
        Invocation.method(#getLatLngStream, []),
        returnValue: _i6.Stream<_i4.LatLng>.empty(),
      ) as _i6.Stream<_i4.LatLng>);
}
