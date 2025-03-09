// Mocks generated by Mockito 5.4.5 from annotations
// in soen_390/test/widgets/screens/waypoint_selection_screens_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i8;

import 'package:geolocator/geolocator.dart' as _i4;
import 'package:latlong2/latlong.dart' as _i5;
import 'package:mockito/mockito.dart' as _i1;
import 'package:mockito/src/dummies.dart' as _i7;
import 'package:soen_390/services/building_to_coordinates.dart' as _i10;
import 'package:soen_390/services/google_route_service.dart' as _i6;
import 'package:soen_390/services/http_service.dart' as _i3;
import 'package:soen_390/services/interfaces/route_service_interface.dart'
    as _i9;
import 'package:soen_390/utils/location_service.dart' as _i2;

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

class _FakeLocationService_0 extends _i1.SmartFake
    implements _i2.LocationService {
  _FakeLocationService_0(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

class _FakeHttpService_1 extends _i1.SmartFake implements _i3.HttpService {
  _FakeHttpService_1(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

class _FakeGeolocatorPlatform_2 extends _i1.SmartFake
    implements _i4.GeolocatorPlatform {
  _FakeGeolocatorPlatform_2(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

class _FakePosition_3 extends _i1.SmartFake implements _i4.Position {
  _FakePosition_3(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

class _FakeLocationSettings_4 extends _i1.SmartFake
    implements _i4.LocationSettings {
  _FakeLocationSettings_4(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

class _FakeLatLng_5 extends _i1.SmartFake implements _i5.LatLng {
  _FakeLatLng_5(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

/// A class which mocks [GoogleRouteService].
///
/// See the documentation for Mockito's code generation for more information.
class MockGoogleRouteService extends _i1.Mock
    implements _i6.GoogleRouteService {
  @override
  String get apiKey => (super.noSuchMethod(
        Invocation.getter(#apiKey),
        returnValue: _i7.dummyValue<String>(
          this,
          Invocation.getter(#apiKey),
        ),
        returnValueForMissingStub: _i7.dummyValue<String>(
          this,
          Invocation.getter(#apiKey),
        ),
      ) as String);

  @override
  _i2.LocationService get locationService => (super.noSuchMethod(
        Invocation.getter(#locationService),
        returnValue: _FakeLocationService_0(
          this,
          Invocation.getter(#locationService),
        ),
        returnValueForMissingStub: _FakeLocationService_0(
          this,
          Invocation.getter(#locationService),
        ),
      ) as _i2.LocationService);

  @override
  _i3.HttpService get httpService => (super.noSuchMethod(
        Invocation.getter(#httpService),
        returnValue: _FakeHttpService_1(
          this,
          Invocation.getter(#httpService),
        ),
        returnValueForMissingStub: _FakeHttpService_1(
          this,
          Invocation.getter(#httpService),
        ),
      ) as _i3.HttpService);

  @override
  _i8.Future<_i9.RouteResult?> getRoute({
    required _i5.LatLng? from,
    required _i5.LatLng? to,
  }) =>
      (super.noSuchMethod(
        Invocation.method(#getRoute, [], {#from: from, #to: to}),
        returnValue: _i8.Future<_i9.RouteResult?>.value(),
        returnValueForMissingStub: _i8.Future<_i9.RouteResult?>.value(),
      ) as _i8.Future<_i9.RouteResult?>);

  @override
  _i8.Future<Map<String, List<_i9.RouteResult>>> getRoutes({
    required _i5.LatLng? from,
    required _i5.LatLng? to,
    DateTime? departureTime,
    DateTime? arrivalTime,
  }) =>
      (super.noSuchMethod(
        Invocation.method(#getRoutes, [], {
          #from: from,
          #to: to,
          #departureTime: departureTime,
          #arrivalTime: arrivalTime,
        }),
        returnValue: _i8.Future<Map<String, List<_i9.RouteResult>>>.value(
          <String, List<_i9.RouteResult>>{},
        ),
        returnValueForMissingStub:
            _i8.Future<Map<String, List<_i9.RouteResult>>>.value(
          <String, List<_i9.RouteResult>>{},
        ),
      ) as _i8.Future<Map<String, List<_i9.RouteResult>>>);

  @override
  _i9.RouteResult? selectRoute(List<_i9.RouteResult>? routes, int? index) =>
      (super.noSuchMethod(
        Invocation.method(#selectRoute, [routes, index]),
        returnValueForMissingStub: null,
      ) as _i9.RouteResult?);

  @override
  _i8.Future<void> startLiveNavigation({
    required _i5.LatLng? to,
    required String? mode,
    required dynamic Function(_i9.RouteResult)? onUpdate,
  }) =>
      (super.noSuchMethod(
        Invocation.method(#startLiveNavigation, [], {
          #to: to,
          #mode: mode,
          #onUpdate: onUpdate,
        }),
        returnValue: _i8.Future<void>.value(),
        returnValueForMissingStub: _i8.Future<void>.value(),
      ) as _i8.Future<void>);
}

/// A class which mocks [GeocodingService].
///
/// See the documentation for Mockito's code generation for more information.
class MockGeocodingService extends _i1.Mock implements _i10.GeocodingService {
  @override
  String get apiKey => (super.noSuchMethod(
        Invocation.getter(#apiKey),
        returnValue: _i7.dummyValue<String>(
          this,
          Invocation.getter(#apiKey),
        ),
        returnValueForMissingStub: _i7.dummyValue<String>(
          this,
          Invocation.getter(#apiKey),
        ),
      ) as String);

  @override
  _i3.HttpService get httpService => (super.noSuchMethod(
        Invocation.getter(#httpService),
        returnValue: _FakeHttpService_1(
          this,
          Invocation.getter(#httpService),
        ),
        returnValueForMissingStub: _FakeHttpService_1(
          this,
          Invocation.getter(#httpService),
        ),
      ) as _i3.HttpService);

  @override
  _i8.Future<_i5.LatLng?> getCoordinates(String? address) =>
      (super.noSuchMethod(
        Invocation.method(#getCoordinates, [address]),
        returnValue: _i8.Future<_i5.LatLng?>.value(),
        returnValueForMissingStub: _i8.Future<_i5.LatLng?>.value(),
      ) as _i8.Future<_i5.LatLng?>);
}

/// A class which mocks [LocationService].
///
/// See the documentation for Mockito's code generation for more information.
class MockLocationService extends _i1.Mock implements _i2.LocationService {
  @override
  _i4.GeolocatorPlatform get geolocator => (super.noSuchMethod(
        Invocation.getter(#geolocator),
        returnValue: _FakeGeolocatorPlatform_2(
          this,
          Invocation.getter(#geolocator),
        ),
        returnValueForMissingStub: _FakeGeolocatorPlatform_2(
          this,
          Invocation.getter(#geolocator),
        ),
      ) as _i4.GeolocatorPlatform);

  @override
  _i4.Position get currentPosition => (super.noSuchMethod(
        Invocation.getter(#currentPosition),
        returnValue: _FakePosition_3(
          this,
          Invocation.getter(#currentPosition),
        ),
        returnValueForMissingStub: _FakePosition_3(
          this,
          Invocation.getter(#currentPosition),
        ),
      ) as _i4.Position);

  @override
  set currentPosition(_i4.Position? _currentPosition) => super.noSuchMethod(
        Invocation.setter(#currentPosition, _currentPosition),
        returnValueForMissingStub: null,
      );

  @override
  _i4.LocationSettings get locSetting => (super.noSuchMethod(
        Invocation.getter(#locSetting),
        returnValue: _FakeLocationSettings_4(
          this,
          Invocation.getter(#locSetting),
        ),
        returnValueForMissingStub: _FakeLocationSettings_4(
          this,
          Invocation.getter(#locSetting),
        ),
      ) as _i4.LocationSettings);

  @override
  set locSetting(_i4.LocationSettings? _locSetting) => super.noSuchMethod(
        Invocation.setter(#locSetting, _locSetting),
        returnValueForMissingStub: null,
      );

  @override
  bool get serviceEnabled => (super.noSuchMethod(
        Invocation.getter(#serviceEnabled),
        returnValue: false,
        returnValueForMissingStub: false,
      ) as bool);

  @override
  set serviceEnabled(bool? _serviceEnabled) => super.noSuchMethod(
        Invocation.setter(#serviceEnabled, _serviceEnabled),
        returnValueForMissingStub: null,
      );

  @override
  _i4.LocationPermission get permission => (super.noSuchMethod(
        Invocation.getter(#permission),
        returnValue: _i4.LocationPermission.denied,
        returnValueForMissingStub: _i4.LocationPermission.denied,
      ) as _i4.LocationPermission);

  @override
  set permission(_i4.LocationPermission? _permission) => super.noSuchMethod(
        Invocation.setter(#permission, _permission),
        returnValueForMissingStub: null,
      );

  @override
  _i8.Future<bool> isLocationEnabled() => (super.noSuchMethod(
        Invocation.method(#isLocationEnabled, []),
        returnValue: _i8.Future<bool>.value(false),
        returnValueForMissingStub: _i8.Future<bool>.value(false),
      ) as _i8.Future<bool>);

  @override
  _i8.Future<bool> determinePermissions() => (super.noSuchMethod(
        Invocation.method(#determinePermissions, []),
        returnValue: _i8.Future<bool>.value(false),
        returnValueForMissingStub: _i8.Future<bool>.value(false),
      ) as _i8.Future<bool>);

  @override
  _i8.Future<_i4.Position> getCurrentLocation() => (super.noSuchMethod(
        Invocation.method(#getCurrentLocation, []),
        returnValue: _i8.Future<_i4.Position>.value(
          _FakePosition_3(this, Invocation.method(#getCurrentLocation, [])),
        ),
        returnValueForMissingStub: _i8.Future<_i4.Position>.value(
          _FakePosition_3(this, Invocation.method(#getCurrentLocation, [])),
        ),
      ) as _i8.Future<_i4.Position>);

  @override
  _i8.Future<void> updateCurrentLocation() => (super.noSuchMethod(
        Invocation.method(#updateCurrentLocation, []),
        returnValue: _i8.Future<void>.value(),
        returnValueForMissingStub: _i8.Future<void>.value(),
      ) as _i8.Future<void>);

  @override
  _i8.Future<_i4.Position> getCurrentLocationAccurately() =>
      (super.noSuchMethod(
        Invocation.method(#getCurrentLocationAccurately, []),
        returnValue: _i8.Future<_i4.Position>.value(
          _FakePosition_3(
            this,
            Invocation.method(#getCurrentLocationAccurately, []),
          ),
        ),
        returnValueForMissingStub: _i8.Future<_i4.Position>.value(
          _FakePosition_3(
            this,
            Invocation.method(#getCurrentLocationAccurately, []),
          ),
        ),
      ) as _i8.Future<_i4.Position>);

  @override
  _i8.Future<void> updateCurrentLocationAccurately() => (super.noSuchMethod(
        Invocation.method(#updateCurrentLocationAccurately, []),
        returnValue: _i8.Future<void>.value(),
        returnValueForMissingStub: _i8.Future<void>.value(),
      ) as _i8.Future<void>);

  @override
  void takePosition(_i4.Position? p) => super.noSuchMethod(
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
  _i8.Future<void> startUp() => (super.noSuchMethod(
        Invocation.method(#startUp, []),
        returnValue: _i8.Future<void>.value(),
        returnValueForMissingStub: _i8.Future<void>.value(),
      ) as _i8.Future<void>);

  @override
  void stopListening() => super.noSuchMethod(
        Invocation.method(#stopListening, []),
        returnValueForMissingStub: null,
      );

  @override
  _i8.Stream<_i4.Position> getPositionStream() => (super.noSuchMethod(
        Invocation.method(#getPositionStream, []),
        returnValue: _i8.Stream<_i4.Position>.empty(),
        returnValueForMissingStub: _i8.Stream<_i4.Position>.empty(),
      ) as _i8.Stream<_i4.Position>);

  @override
  _i5.LatLng convertPositionToLatLng(_i4.Position? p) => (super.noSuchMethod(
        Invocation.method(#convertPositionToLatLng, [p]),
        returnValue: _FakeLatLng_5(
          this,
          Invocation.method(#convertPositionToLatLng, [p]),
        ),
        returnValueForMissingStub: _FakeLatLng_5(
          this,
          Invocation.method(#convertPositionToLatLng, [p]),
        ),
      ) as _i5.LatLng);

  @override
  _i8.Stream<_i5.LatLng> getLatLngStream() => (super.noSuchMethod(
        Invocation.method(#getLatLngStream, []),
        returnValue: _i8.Stream<_i5.LatLng>.empty(),
        returnValueForMissingStub: _i8.Stream<_i5.LatLng>.empty(),
      ) as _i8.Stream<_i5.LatLng>);
}
