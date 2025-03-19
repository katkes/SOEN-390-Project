// Mocks generated by Mockito 5.4.5 from annotations
// in soen_390/test/widgets/screens/place_search_screen_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i7;

import 'package:geolocator/geolocator.dart' as _i2;
import 'package:latlong2/latlong.dart' as _i3;
import 'package:mockito/mockito.dart' as _i1;
import 'package:soen_390/models/outdoor_poi.dart' as _i5;
import 'package:soen_390/models/places.dart' as _i8;
import 'package:soen_390/services/building_info_api.dart' as _i4;
import 'package:soen_390/services/google_poi_service.dart' as _i6;
import 'package:soen_390/services/poi_factory.dart' as _i10;
import 'package:soen_390/utils/location_service.dart' as _i9;

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

class _FakeGeolocatorPlatform_0 extends _i1.SmartFake
    implements _i2.GeolocatorPlatform {
  _FakeGeolocatorPlatform_0(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class _FakePosition_1 extends _i1.SmartFake implements _i2.Position {
  _FakePosition_1(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class _FakeLocationSettings_2 extends _i1.SmartFake
    implements _i2.LocationSettings {
  _FakeLocationSettings_2(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class _FakeLatLng_3 extends _i1.SmartFake implements _i3.LatLng {
  _FakeLatLng_3(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class _FakeGoogleMapsApiClient_4 extends _i1.SmartFake
    implements _i4.GoogleMapsApiClient {
  _FakeGoogleMapsApiClient_4(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class _FakePointOfInterest_5 extends _i1.SmartFake
    implements _i5.PointOfInterest {
  _FakePointOfInterest_5(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

/// A class which mocks [GooglePOIService].
///
/// See the documentation for Mockito's code generation for more information.
class MockGooglePOIService extends _i1.Mock implements _i6.GooglePOIService {
  MockGooglePOIService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i7.Future<List<_i8.Place>> getNearbyPlaces({
    required double? latitude,
    required double? longitude,
    required String? type,
    required int? radius,
  }) =>
      (super.noSuchMethod(
            Invocation.method(#getNearbyPlaces, [], {
              #latitude: latitude,
              #longitude: longitude,
              #type: type,
              #radius: radius,
            }),
            returnValue: _i7.Future<List<_i8.Place>>.value(<_i8.Place>[]),
          )
          as _i7.Future<List<_i8.Place>>);

  @override
  void dispose() => super.noSuchMethod(
    Invocation.method(#dispose, []),
    returnValueForMissingStub: null,
  );
}

/// A class which mocks [LocationService].
///
/// See the documentation for Mockito's code generation for more information.
class MockLocationService extends _i1.Mock implements _i9.LocationService {
  MockLocationService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.GeolocatorPlatform get geolocator =>
      (super.noSuchMethod(
            Invocation.getter(#geolocator),
            returnValue: _FakeGeolocatorPlatform_0(
              this,
              Invocation.getter(#geolocator),
            ),
          )
          as _i2.GeolocatorPlatform);

  @override
  _i2.Position get currentPosition =>
      (super.noSuchMethod(
            Invocation.getter(#currentPosition),
            returnValue: _FakePosition_1(
              this,
              Invocation.getter(#currentPosition),
            ),
          )
          as _i2.Position);

  @override
  set currentPosition(_i2.Position? _currentPosition) => super.noSuchMethod(
    Invocation.setter(#currentPosition, _currentPosition),
    returnValueForMissingStub: null,
  );

  @override
  _i2.LocationSettings get locSetting =>
      (super.noSuchMethod(
            Invocation.getter(#locSetting),
            returnValue: _FakeLocationSettings_2(
              this,
              Invocation.getter(#locSetting),
            ),
          )
          as _i2.LocationSettings);

  @override
  set locSetting(_i2.LocationSettings? _locSetting) => super.noSuchMethod(
    Invocation.setter(#locSetting, _locSetting),
    returnValueForMissingStub: null,
  );

  @override
  bool get serviceEnabled =>
      (super.noSuchMethod(
            Invocation.getter(#serviceEnabled),
            returnValue: false,
          )
          as bool);

  @override
  set serviceEnabled(bool? _serviceEnabled) => super.noSuchMethod(
    Invocation.setter(#serviceEnabled, _serviceEnabled),
    returnValueForMissingStub: null,
  );

  @override
  _i2.LocationPermission get permission =>
      (super.noSuchMethod(
            Invocation.getter(#permission),
            returnValue: _i2.LocationPermission.denied,
          )
          as _i2.LocationPermission);

  @override
  set permission(_i2.LocationPermission? _permission) => super.noSuchMethod(
    Invocation.setter(#permission, _permission),
    returnValueForMissingStub: null,
  );

  @override
  _i7.Future<bool> isLocationEnabled() =>
      (super.noSuchMethod(
            Invocation.method(#isLocationEnabled, []),
            returnValue: _i7.Future<bool>.value(false),
          )
          as _i7.Future<bool>);

  @override
  _i7.Future<bool> determinePermissions() =>
      (super.noSuchMethod(
            Invocation.method(#determinePermissions, []),
            returnValue: _i7.Future<bool>.value(false),
          )
          as _i7.Future<bool>);

  @override
  _i7.Future<_i2.Position> getCurrentLocation() =>
      (super.noSuchMethod(
            Invocation.method(#getCurrentLocation, []),
            returnValue: _i7.Future<_i2.Position>.value(
              _FakePosition_1(this, Invocation.method(#getCurrentLocation, [])),
            ),
          )
          as _i7.Future<_i2.Position>);

  @override
  _i7.Future<void> updateCurrentLocation() =>
      (super.noSuchMethod(
            Invocation.method(#updateCurrentLocation, []),
            returnValue: _i7.Future<void>.value(),
            returnValueForMissingStub: _i7.Future<void>.value(),
          )
          as _i7.Future<void>);

  @override
  _i7.Future<_i2.Position> getCurrentLocationAccurately() =>
      (super.noSuchMethod(
            Invocation.method(#getCurrentLocationAccurately, []),
            returnValue: _i7.Future<_i2.Position>.value(
              _FakePosition_1(
                this,
                Invocation.method(#getCurrentLocationAccurately, []),
              ),
            ),
          )
          as _i7.Future<_i2.Position>);

  @override
  _i7.Future<void> updateCurrentLocationAccurately() =>
      (super.noSuchMethod(
            Invocation.method(#updateCurrentLocationAccurately, []),
            returnValue: _i7.Future<void>.value(),
            returnValueForMissingStub: _i7.Future<void>.value(),
          )
          as _i7.Future<void>);

  @override
  void takePosition(_i2.Position? p) => super.noSuchMethod(
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
  _i7.Future<void> startUp() =>
      (super.noSuchMethod(
            Invocation.method(#startUp, []),
            returnValue: _i7.Future<void>.value(),
            returnValueForMissingStub: _i7.Future<void>.value(),
          )
          as _i7.Future<void>);

  @override
  void stopListening() => super.noSuchMethod(
    Invocation.method(#stopListening, []),
    returnValueForMissingStub: null,
  );

  @override
  _i7.Stream<_i2.Position> getPositionStream() =>
      (super.noSuchMethod(
            Invocation.method(#getPositionStream, []),
            returnValue: _i7.Stream<_i2.Position>.empty(),
          )
          as _i7.Stream<_i2.Position>);

  @override
  _i3.LatLng convertPositionToLatLng(_i2.Position? p) =>
      (super.noSuchMethod(
            Invocation.method(#convertPositionToLatLng, [p]),
            returnValue: _FakeLatLng_3(
              this,
              Invocation.method(#convertPositionToLatLng, [p]),
            ),
          )
          as _i3.LatLng);

  @override
  _i7.Stream<_i3.LatLng> getLatLngStream() =>
      (super.noSuchMethod(
            Invocation.method(#getLatLngStream, []),
            returnValue: _i7.Stream<_i3.LatLng>.empty(),
          )
          as _i7.Stream<_i3.LatLng>);
}

/// A class which mocks [PointOfInterestFactory].
///
/// See the documentation for Mockito's code generation for more information.
class MockPointOfInterestFactory extends _i1.Mock
    implements _i10.PointOfInterestFactory {
  MockPointOfInterestFactory() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i4.GoogleMapsApiClient get apiClient =>
      (super.noSuchMethod(
            Invocation.getter(#apiClient),
            returnValue: _FakeGoogleMapsApiClient_4(
              this,
              Invocation.getter(#apiClient),
            ),
          )
          as _i4.GoogleMapsApiClient);

  @override
  _i7.Future<_i5.PointOfInterest> createPointOfInterest({
    required String? placeId,
    required String? imageUrl,
  }) =>
      (super.noSuchMethod(
            Invocation.method(#createPointOfInterest, [], {
              #placeId: placeId,
              #imageUrl: imageUrl,
            }),
            returnValue: _i7.Future<_i5.PointOfInterest>.value(
              _FakePointOfInterest_5(
                this,
                Invocation.method(#createPointOfInterest, [], {
                  #placeId: placeId,
                  #imageUrl: imageUrl,
                }),
              ),
            ),
          )
          as _i7.Future<_i5.PointOfInterest>);
}
