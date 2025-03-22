// Mocks generated by Mockito 5.4.5 from annotations
// in soen_390/test/main_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i11;
import 'dart:convert' as _i12;
import 'dart:typed_data' as _i14;

import 'package:geolocator/geolocator.dart' as _i5;
import 'package:google_sign_in/google_sign_in.dart' as _i8;
import 'package:googleapis_auth/googleapis_auth.dart' as _i9;
import 'package:http/http.dart' as _i2;
import 'package:latlong2/latlong.dart' as _i6;
import 'package:mockito/mockito.dart' as _i1;
import 'package:mockito/src/dummies.dart' as _i13;
import 'package:soen_390/core/secure_storage.dart' as _i7;
import 'package:soen_390/services/auth_service.dart' as _i17;
import 'package:soen_390/services/building_info_api.dart' as _i3;
import 'package:soen_390/services/building_to_coordinates.dart' as _i15;
import 'package:soen_390/services/http_service.dart' as _i4;
import 'package:soen_390/services/interfaces/route_service_interface.dart'
    as _i10;
import 'package:soen_390/utils/location_service.dart' as _i16;

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

class _FakeClient_0 extends _i1.SmartFake implements _i2.Client {
  _FakeClient_0(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

class _FakeResponse_1 extends _i1.SmartFake implements _i2.Response {
  _FakeResponse_1(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

class _FakeStreamedResponse_2 extends _i1.SmartFake
    implements _i2.StreamedResponse {
  _FakeStreamedResponse_2(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

class _FakeMapsApiClient_3 extends _i1.SmartFake implements _i3.MapsApiClient {
  _FakeMapsApiClient_3(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

class _FakeHttpService_4 extends _i1.SmartFake implements _i4.HttpService {
  _FakeHttpService_4(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

class _FakeGeolocatorPlatform_5 extends _i1.SmartFake
    implements _i5.GeolocatorPlatform {
  _FakeGeolocatorPlatform_5(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

class _FakePosition_6 extends _i1.SmartFake implements _i5.Position {
  _FakePosition_6(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

class _FakeLocationSettings_7 extends _i1.SmartFake
    implements _i5.LocationSettings {
  _FakeLocationSettings_7(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

class _FakeLatLng_8 extends _i1.SmartFake implements _i6.LatLng {
  _FakeLatLng_8(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

class _FakeSecureStorage_9 extends _i1.SmartFake implements _i7.SecureStorage {
  _FakeSecureStorage_9(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

class _FakeGoogleSignIn_10 extends _i1.SmartFake implements _i8.GoogleSignIn {
  _FakeGoogleSignIn_10(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

class _FakeAccessCredentials_11 extends _i1.SmartFake
    implements _i9.AccessCredentials {
  _FakeAccessCredentials_11(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

class _FakeGoogleSignInAuthentication_12 extends _i1.SmartFake
    implements _i8.GoogleSignInAuthentication {
  _FakeGoogleSignInAuthentication_12(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

/// A class which mocks [IRouteService].
///
/// See the documentation for Mockito's code generation for more information.
class MockIRouteService extends _i1.Mock implements _i10.IRouteService {
  @override
  _i11.Future<_i10.RouteResult?> getRoute({
    required _i6.LatLng? from,
    required _i6.LatLng? to,
  }) =>
      (super.noSuchMethod(
        Invocation.method(#getRoute, [], {#from: from, #to: to}),
        returnValue: _i11.Future<_i10.RouteResult?>.value(),
        returnValueForMissingStub: _i11.Future<_i10.RouteResult?>.value(),
      ) as _i11.Future<_i10.RouteResult?>);
}

/// A class which mocks [HttpService].
///
/// See the documentation for Mockito's code generation for more information.
class MockHttpService extends _i1.Mock implements _i4.HttpService {
  @override
  _i2.Client get client => (super.noSuchMethod(
        Invocation.getter(#client),
        returnValue: _FakeClient_0(this, Invocation.getter(#client)),
        returnValueForMissingStub: _FakeClient_0(
          this,
          Invocation.getter(#client),
        ),
      ) as _i2.Client);

  @override
  void dispose() => super.noSuchMethod(
        Invocation.method(#dispose, []),
        returnValueForMissingStub: null,
      );
}

/// A class which mocks [Client].
///
/// See the documentation for Mockito's code generation for more information.
class MockClient extends _i1.Mock implements _i2.Client {
  @override
  _i11.Future<_i2.Response> head(Uri? url, {Map<String, String>? headers}) =>
      (super.noSuchMethod(
        Invocation.method(#head, [url], {#headers: headers}),
        returnValue: _i11.Future<_i2.Response>.value(
          _FakeResponse_1(
            this,
            Invocation.method(#head, [url], {#headers: headers}),
          ),
        ),
        returnValueForMissingStub: _i11.Future<_i2.Response>.value(
          _FakeResponse_1(
            this,
            Invocation.method(#head, [url], {#headers: headers}),
          ),
        ),
      ) as _i11.Future<_i2.Response>);

  @override
  _i11.Future<_i2.Response> get(Uri? url, {Map<String, String>? headers}) =>
      (super.noSuchMethod(
        Invocation.method(#get, [url], {#headers: headers}),
        returnValue: _i11.Future<_i2.Response>.value(
          _FakeResponse_1(
            this,
            Invocation.method(#get, [url], {#headers: headers}),
          ),
        ),
        returnValueForMissingStub: _i11.Future<_i2.Response>.value(
          _FakeResponse_1(
            this,
            Invocation.method(#get, [url], {#headers: headers}),
          ),
        ),
      ) as _i11.Future<_i2.Response>);

  @override
  _i11.Future<_i2.Response> post(
    Uri? url, {
    Map<String, String>? headers,
    Object? body,
    _i12.Encoding? encoding,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #post,
          [url],
          {#headers: headers, #body: body, #encoding: encoding},
        ),
        returnValue: _i11.Future<_i2.Response>.value(
          _FakeResponse_1(
            this,
            Invocation.method(
              #post,
              [url],
              {#headers: headers, #body: body, #encoding: encoding},
            ),
          ),
        ),
        returnValueForMissingStub: _i11.Future<_i2.Response>.value(
          _FakeResponse_1(
            this,
            Invocation.method(
              #post,
              [url],
              {#headers: headers, #body: body, #encoding: encoding},
            ),
          ),
        ),
      ) as _i11.Future<_i2.Response>);

  @override
  _i11.Future<_i2.Response> put(
    Uri? url, {
    Map<String, String>? headers,
    Object? body,
    _i12.Encoding? encoding,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #put,
          [url],
          {#headers: headers, #body: body, #encoding: encoding},
        ),
        returnValue: _i11.Future<_i2.Response>.value(
          _FakeResponse_1(
            this,
            Invocation.method(
              #put,
              [url],
              {#headers: headers, #body: body, #encoding: encoding},
            ),
          ),
        ),
        returnValueForMissingStub: _i11.Future<_i2.Response>.value(
          _FakeResponse_1(
            this,
            Invocation.method(
              #put,
              [url],
              {#headers: headers, #body: body, #encoding: encoding},
            ),
          ),
        ),
      ) as _i11.Future<_i2.Response>);

  @override
  _i11.Future<_i2.Response> patch(
    Uri? url, {
    Map<String, String>? headers,
    Object? body,
    _i12.Encoding? encoding,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #patch,
          [url],
          {#headers: headers, #body: body, #encoding: encoding},
        ),
        returnValue: _i11.Future<_i2.Response>.value(
          _FakeResponse_1(
            this,
            Invocation.method(
              #patch,
              [url],
              {#headers: headers, #body: body, #encoding: encoding},
            ),
          ),
        ),
        returnValueForMissingStub: _i11.Future<_i2.Response>.value(
          _FakeResponse_1(
            this,
            Invocation.method(
              #patch,
              [url],
              {#headers: headers, #body: body, #encoding: encoding},
            ),
          ),
        ),
      ) as _i11.Future<_i2.Response>);

  @override
  _i11.Future<_i2.Response> delete(
    Uri? url, {
    Map<String, String>? headers,
    Object? body,
    _i12.Encoding? encoding,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #delete,
          [url],
          {#headers: headers, #body: body, #encoding: encoding},
        ),
        returnValue: _i11.Future<_i2.Response>.value(
          _FakeResponse_1(
            this,
            Invocation.method(
              #delete,
              [url],
              {#headers: headers, #body: body, #encoding: encoding},
            ),
          ),
        ),
        returnValueForMissingStub: _i11.Future<_i2.Response>.value(
          _FakeResponse_1(
            this,
            Invocation.method(
              #delete,
              [url],
              {#headers: headers, #body: body, #encoding: encoding},
            ),
          ),
        ),
      ) as _i11.Future<_i2.Response>);

  @override
  _i11.Future<String> read(Uri? url, {Map<String, String>? headers}) =>
      (super.noSuchMethod(
        Invocation.method(#read, [url], {#headers: headers}),
        returnValue: _i11.Future<String>.value(
          _i13.dummyValue<String>(
            this,
            Invocation.method(#read, [url], {#headers: headers}),
          ),
        ),
        returnValueForMissingStub: _i11.Future<String>.value(
          _i13.dummyValue<String>(
            this,
            Invocation.method(#read, [url], {#headers: headers}),
          ),
        ),
      ) as _i11.Future<String>);

  @override
  _i11.Future<_i14.Uint8List> readBytes(
    Uri? url, {
    Map<String, String>? headers,
  }) =>
      (super.noSuchMethod(
        Invocation.method(#readBytes, [url], {#headers: headers}),
        returnValue: _i11.Future<_i14.Uint8List>.value(_i14.Uint8List(0)),
        returnValueForMissingStub: _i11.Future<_i14.Uint8List>.value(
          _i14.Uint8List(0),
        ),
      ) as _i11.Future<_i14.Uint8List>);

  @override
  _i11.Future<_i2.StreamedResponse> send(_i2.BaseRequest? request) =>
      (super.noSuchMethod(
        Invocation.method(#send, [request]),
        returnValue: _i11.Future<_i2.StreamedResponse>.value(
          _FakeStreamedResponse_2(
            this,
            Invocation.method(#send, [request]),
          ),
        ),
        returnValueForMissingStub: _i11.Future<_i2.StreamedResponse>.value(
          _FakeStreamedResponse_2(
            this,
            Invocation.method(#send, [request]),
          ),
        ),
      ) as _i11.Future<_i2.StreamedResponse>);

  @override
  void close() => super.noSuchMethod(
        Invocation.method(#close, []),
        returnValueForMissingStub: null,
      );
}

/// A class which mocks [BuildingPopUps].
///
/// See the documentation for Mockito's code generation for more information.
class MockBuildingPopUps extends _i1.Mock implements _i3.BuildingPopUps {
  @override
  _i3.MapsApiClient get mapsApiClient => (super.noSuchMethod(
        Invocation.getter(#mapsApiClient),
        returnValue: _FakeMapsApiClient_3(
          this,
          Invocation.getter(#mapsApiClient),
        ),
        returnValueForMissingStub: _FakeMapsApiClient_3(
          this,
          Invocation.getter(#mapsApiClient),
        ),
      ) as _i3.MapsApiClient);

  @override
  _i11.Future<Map<String, dynamic>> fetchBuildingInformation(
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
        returnValue: _i11.Future<Map<String, dynamic>>.value(
          <String, dynamic>{},
        ),
        returnValueForMissingStub: _i11.Future<Map<String, dynamic>>.value(
          <String, dynamic>{},
        ),
      ) as _i11.Future<Map<String, dynamic>>);
}

/// A class which mocks [GoogleMapsApiClient].
///
/// See the documentation for Mockito's code generation for more information.
class MockGoogleMapsApiClient extends _i1.Mock
    implements _i3.GoogleMapsApiClient {
  @override
  String get apiKey => (super.noSuchMethod(
        Invocation.getter(#apiKey),
        returnValue: _i13.dummyValue<String>(
          this,
          Invocation.getter(#apiKey),
        ),
        returnValueForMissingStub: _i13.dummyValue<String>(
          this,
          Invocation.getter(#apiKey),
        ),
      ) as String);

  @override
  _i2.Client get client => (super.noSuchMethod(
        Invocation.getter(#client),
        returnValue: _FakeClient_0(this, Invocation.getter(#client)),
        returnValueForMissingStub: _FakeClient_0(
          this,
          Invocation.getter(#client),
        ),
      ) as _i2.Client);

  @override
  _i11.Future<Map<String, dynamic>> fetchBuildingInformation(
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
        returnValue: _i11.Future<Map<String, dynamic>>.value(
          <String, dynamic>{},
        ),
        returnValueForMissingStub: _i11.Future<Map<String, dynamic>>.value(
          <String, dynamic>{},
        ),
      ) as _i11.Future<Map<String, dynamic>>);
}

/// A class which mocks [GeocodingService].
///
/// See the documentation for Mockito's code generation for more information.
class MockGeocodingService extends _i1.Mock implements _i15.GeocodingService {
  @override
  String get apiKey => (super.noSuchMethod(
        Invocation.getter(#apiKey),
        returnValue: _i13.dummyValue<String>(
          this,
          Invocation.getter(#apiKey),
        ),
        returnValueForMissingStub: _i13.dummyValue<String>(
          this,
          Invocation.getter(#apiKey),
        ),
      ) as String);

  @override
  _i4.HttpService get httpService => (super.noSuchMethod(
        Invocation.getter(#httpService),
        returnValue: _FakeHttpService_4(
          this,
          Invocation.getter(#httpService),
        ),
        returnValueForMissingStub: _FakeHttpService_4(
          this,
          Invocation.getter(#httpService),
        ),
      ) as _i4.HttpService);

  @override
  _i11.Future<_i6.LatLng?> getCoordinates(String? address) =>
      (super.noSuchMethod(
        Invocation.method(#getCoordinates, [address]),
        returnValue: _i11.Future<_i6.LatLng?>.value(),
        returnValueForMissingStub: _i11.Future<_i6.LatLng?>.value(),
      ) as _i11.Future<_i6.LatLng?>);
}

/// A class which mocks [LocationService].
///
/// See the documentation for Mockito's code generation for more information.
class MockLocationService extends _i1.Mock implements _i16.LocationService {
  @override
  _i5.GeolocatorPlatform get geolocator => (super.noSuchMethod(
        Invocation.getter(#geolocator),
        returnValue: _FakeGeolocatorPlatform_5(
          this,
          Invocation.getter(#geolocator),
        ),
        returnValueForMissingStub: _FakeGeolocatorPlatform_5(
          this,
          Invocation.getter(#geolocator),
        ),
      ) as _i5.GeolocatorPlatform);

  @override
  _i5.Position get currentPosition => (super.noSuchMethod(
        Invocation.getter(#currentPosition),
        returnValue: _FakePosition_6(
          this,
          Invocation.getter(#currentPosition),
        ),
        returnValueForMissingStub: _FakePosition_6(
          this,
          Invocation.getter(#currentPosition),
        ),
      ) as _i5.Position);

  @override
  set currentPosition(_i5.Position? _currentPosition) => super.noSuchMethod(
        Invocation.setter(#currentPosition, _currentPosition),
        returnValueForMissingStub: null,
      );

  @override
  _i5.LocationSettings get locSetting => (super.noSuchMethod(
        Invocation.getter(#locSetting),
        returnValue: _FakeLocationSettings_7(
          this,
          Invocation.getter(#locSetting),
        ),
        returnValueForMissingStub: _FakeLocationSettings_7(
          this,
          Invocation.getter(#locSetting),
        ),
      ) as _i5.LocationSettings);

  @override
  set locSetting(_i5.LocationSettings? _locSetting) => super.noSuchMethod(
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
  _i5.LocationPermission get permission => (super.noSuchMethod(
        Invocation.getter(#permission),
        returnValue: _i5.LocationPermission.denied,
        returnValueForMissingStub: _i5.LocationPermission.denied,
      ) as _i5.LocationPermission);

  @override
  set permission(_i5.LocationPermission? _permission) => super.noSuchMethod(
        Invocation.setter(#permission, _permission),
        returnValueForMissingStub: null,
      );

  @override
  _i11.Future<bool> isLocationEnabled() => (super.noSuchMethod(
        Invocation.method(#isLocationEnabled, []),
        returnValue: _i11.Future<bool>.value(false),
        returnValueForMissingStub: _i11.Future<bool>.value(false),
      ) as _i11.Future<bool>);

  @override
  _i11.Future<bool> determinePermissions() => (super.noSuchMethod(
        Invocation.method(#determinePermissions, []),
        returnValue: _i11.Future<bool>.value(false),
        returnValueForMissingStub: _i11.Future<bool>.value(false),
      ) as _i11.Future<bool>);

  @override
  _i11.Future<_i5.Position> getCurrentLocation() => (super.noSuchMethod(
        Invocation.method(#getCurrentLocation, []),
        returnValue: _i11.Future<_i5.Position>.value(
          _FakePosition_6(this, Invocation.method(#getCurrentLocation, [])),
        ),
        returnValueForMissingStub: _i11.Future<_i5.Position>.value(
          _FakePosition_6(this, Invocation.method(#getCurrentLocation, [])),
        ),
      ) as _i11.Future<_i5.Position>);

  @override
  _i11.Future<void> updateCurrentLocation() => (super.noSuchMethod(
        Invocation.method(#updateCurrentLocation, []),
        returnValue: _i11.Future<void>.value(),
        returnValueForMissingStub: _i11.Future<void>.value(),
      ) as _i11.Future<void>);

  @override
  _i11.Future<_i5.Position> getCurrentLocationAccurately() =>
      (super.noSuchMethod(
        Invocation.method(#getCurrentLocationAccurately, []),
        returnValue: _i11.Future<_i5.Position>.value(
          _FakePosition_6(
            this,
            Invocation.method(#getCurrentLocationAccurately, []),
          ),
        ),
        returnValueForMissingStub: _i11.Future<_i5.Position>.value(
          _FakePosition_6(
            this,
            Invocation.method(#getCurrentLocationAccurately, []),
          ),
        ),
      ) as _i11.Future<_i5.Position>);

  @override
  _i11.Future<void> updateCurrentLocationAccurately() => (super.noSuchMethod(
        Invocation.method(#updateCurrentLocationAccurately, []),
        returnValue: _i11.Future<void>.value(),
        returnValueForMissingStub: _i11.Future<void>.value(),
      ) as _i11.Future<void>);

  @override
  void takePosition(_i5.Position? p) => super.noSuchMethod(
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
  _i11.Future<void> startUp() => (super.noSuchMethod(
        Invocation.method(#startUp, []),
        returnValue: _i11.Future<void>.value(),
        returnValueForMissingStub: _i11.Future<void>.value(),
      ) as _i11.Future<void>);

  @override
  void stopListening() => super.noSuchMethod(
        Invocation.method(#stopListening, []),
        returnValueForMissingStub: null,
      );

  @override
  _i11.Stream<_i5.Position> getPositionStream() => (super.noSuchMethod(
        Invocation.method(#getPositionStream, []),
        returnValue: _i11.Stream<_i5.Position>.empty(),
        returnValueForMissingStub: _i11.Stream<_i5.Position>.empty(),
      ) as _i11.Stream<_i5.Position>);

  @override
  _i6.LatLng convertPositionToLatLng(_i5.Position? p) => (super.noSuchMethod(
        Invocation.method(#convertPositionToLatLng, [p]),
        returnValue: _FakeLatLng_8(
          this,
          Invocation.method(#convertPositionToLatLng, [p]),
        ),
        returnValueForMissingStub: _FakeLatLng_8(
          this,
          Invocation.method(#convertPositionToLatLng, [p]),
        ),
      ) as _i6.LatLng);

  @override
  _i11.Stream<_i6.LatLng> getLatLngStream() => (super.noSuchMethod(
        Invocation.method(#getLatLngStream, []),
        returnValue: _i11.Stream<_i6.LatLng>.empty(),
        returnValueForMissingStub: _i11.Stream<_i6.LatLng>.empty(),
      ) as _i11.Stream<_i6.LatLng>);
}

/// A class which mocks [AuthService].
///
/// See the documentation for Mockito's code generation for more information.
class MockAuthService extends _i1.Mock implements _i17.AuthService {
  @override
  _i7.SecureStorage get secureStorage => (super.noSuchMethod(
        Invocation.getter(#secureStorage),
        returnValue: _FakeSecureStorage_9(
          this,
          Invocation.getter(#secureStorage),
        ),
        returnValueForMissingStub: _FakeSecureStorage_9(
          this,
          Invocation.getter(#secureStorage),
        ),
      ) as _i7.SecureStorage);

  @override
  _i4.HttpService get httpService => (super.noSuchMethod(
        Invocation.getter(#httpService),
        returnValue: _FakeHttpService_4(
          this,
          Invocation.getter(#httpService),
        ),
        returnValueForMissingStub: _FakeHttpService_4(
          this,
          Invocation.getter(#httpService),
        ),
      ) as _i4.HttpService);

  @override
  _i8.GoogleSignIn get googleSignIn => (super.noSuchMethod(
        Invocation.getter(#googleSignIn),
        returnValue: _FakeGoogleSignIn_10(
          this,
          Invocation.getter(#googleSignIn),
        ),
        returnValueForMissingStub: _FakeGoogleSignIn_10(
          this,
          Invocation.getter(#googleSignIn),
        ),
      ) as _i8.GoogleSignIn);

  @override
  _i11.Future<_i9.AuthClient?> signIn() => (super.noSuchMethod(
        Invocation.method(#signIn, []),
        returnValue: _i11.Future<_i9.AuthClient?>.value(),
        returnValueForMissingStub: _i11.Future<_i9.AuthClient?>.value(),
      ) as _i11.Future<_i9.AuthClient?>);

  @override
  _i11.Future<void> signOut() => (super.noSuchMethod(
        Invocation.method(#signOut, []),
        returnValue: _i11.Future<void>.value(),
        returnValueForMissingStub: _i11.Future<void>.value(),
      ) as _i11.Future<void>);

  @override
  void dispose() => super.noSuchMethod(
        Invocation.method(#dispose, []),
        returnValueForMissingStub: null,
      );
}

/// A class which mocks [SecureStorage].
///
/// See the documentation for Mockito's code generation for more information.
class MockSecureStorage extends _i1.Mock implements _i7.SecureStorage {
  @override
  _i11.Future<void> storeToken(String? key, String? value) =>
      (super.noSuchMethod(
        Invocation.method(#storeToken, [key, value]),
        returnValue: _i11.Future<void>.value(),
        returnValueForMissingStub: _i11.Future<void>.value(),
      ) as _i11.Future<void>);

  @override
  _i11.Future<String?> getToken(String? key) => (super.noSuchMethod(
        Invocation.method(#getToken, [key]),
        returnValue: _i11.Future<String?>.value(),
        returnValueForMissingStub: _i11.Future<String?>.value(),
      ) as _i11.Future<String?>);

  @override
  _i11.Future<void> deleteToken(String? key) => (super.noSuchMethod(
        Invocation.method(#deleteToken, [key]),
        returnValue: _i11.Future<void>.value(),
        returnValueForMissingStub: _i11.Future<void>.value(),
      ) as _i11.Future<void>);
}

/// A class which mocks [AuthClient].
///
/// See the documentation for Mockito's code generation for more information.
class MockAuthClient extends _i1.Mock implements _i9.AuthClient {
  @override
  _i9.AccessCredentials get credentials => (super.noSuchMethod(
        Invocation.getter(#credentials),
        returnValue: _FakeAccessCredentials_11(
          this,
          Invocation.getter(#credentials),
        ),
        returnValueForMissingStub: _FakeAccessCredentials_11(
          this,
          Invocation.getter(#credentials),
        ),
      ) as _i9.AccessCredentials);

  @override
  _i11.Future<_i2.Response> head(Uri? url, {Map<String, String>? headers}) =>
      (super.noSuchMethod(
        Invocation.method(#head, [url], {#headers: headers}),
        returnValue: _i11.Future<_i2.Response>.value(
          _FakeResponse_1(
            this,
            Invocation.method(#head, [url], {#headers: headers}),
          ),
        ),
        returnValueForMissingStub: _i11.Future<_i2.Response>.value(
          _FakeResponse_1(
            this,
            Invocation.method(#head, [url], {#headers: headers}),
          ),
        ),
      ) as _i11.Future<_i2.Response>);

  @override
  _i11.Future<_i2.Response> get(Uri? url, {Map<String, String>? headers}) =>
      (super.noSuchMethod(
        Invocation.method(#get, [url], {#headers: headers}),
        returnValue: _i11.Future<_i2.Response>.value(
          _FakeResponse_1(
            this,
            Invocation.method(#get, [url], {#headers: headers}),
          ),
        ),
        returnValueForMissingStub: _i11.Future<_i2.Response>.value(
          _FakeResponse_1(
            this,
            Invocation.method(#get, [url], {#headers: headers}),
          ),
        ),
      ) as _i11.Future<_i2.Response>);

  @override
  _i11.Future<_i2.Response> post(
    Uri? url, {
    Map<String, String>? headers,
    Object? body,
    _i12.Encoding? encoding,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #post,
          [url],
          {#headers: headers, #body: body, #encoding: encoding},
        ),
        returnValue: _i11.Future<_i2.Response>.value(
          _FakeResponse_1(
            this,
            Invocation.method(
              #post,
              [url],
              {#headers: headers, #body: body, #encoding: encoding},
            ),
          ),
        ),
        returnValueForMissingStub: _i11.Future<_i2.Response>.value(
          _FakeResponse_1(
            this,
            Invocation.method(
              #post,
              [url],
              {#headers: headers, #body: body, #encoding: encoding},
            ),
          ),
        ),
      ) as _i11.Future<_i2.Response>);

  @override
  _i11.Future<_i2.Response> put(
    Uri? url, {
    Map<String, String>? headers,
    Object? body,
    _i12.Encoding? encoding,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #put,
          [url],
          {#headers: headers, #body: body, #encoding: encoding},
        ),
        returnValue: _i11.Future<_i2.Response>.value(
          _FakeResponse_1(
            this,
            Invocation.method(
              #put,
              [url],
              {#headers: headers, #body: body, #encoding: encoding},
            ),
          ),
        ),
        returnValueForMissingStub: _i11.Future<_i2.Response>.value(
          _FakeResponse_1(
            this,
            Invocation.method(
              #put,
              [url],
              {#headers: headers, #body: body, #encoding: encoding},
            ),
          ),
        ),
      ) as _i11.Future<_i2.Response>);

  @override
  _i11.Future<_i2.Response> patch(
    Uri? url, {
    Map<String, String>? headers,
    Object? body,
    _i12.Encoding? encoding,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #patch,
          [url],
          {#headers: headers, #body: body, #encoding: encoding},
        ),
        returnValue: _i11.Future<_i2.Response>.value(
          _FakeResponse_1(
            this,
            Invocation.method(
              #patch,
              [url],
              {#headers: headers, #body: body, #encoding: encoding},
            ),
          ),
        ),
        returnValueForMissingStub: _i11.Future<_i2.Response>.value(
          _FakeResponse_1(
            this,
            Invocation.method(
              #patch,
              [url],
              {#headers: headers, #body: body, #encoding: encoding},
            ),
          ),
        ),
      ) as _i11.Future<_i2.Response>);

  @override
  _i11.Future<_i2.Response> delete(
    Uri? url, {
    Map<String, String>? headers,
    Object? body,
    _i12.Encoding? encoding,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #delete,
          [url],
          {#headers: headers, #body: body, #encoding: encoding},
        ),
        returnValue: _i11.Future<_i2.Response>.value(
          _FakeResponse_1(
            this,
            Invocation.method(
              #delete,
              [url],
              {#headers: headers, #body: body, #encoding: encoding},
            ),
          ),
        ),
        returnValueForMissingStub: _i11.Future<_i2.Response>.value(
          _FakeResponse_1(
            this,
            Invocation.method(
              #delete,
              [url],
              {#headers: headers, #body: body, #encoding: encoding},
            ),
          ),
        ),
      ) as _i11.Future<_i2.Response>);

  @override
  _i11.Future<String> read(Uri? url, {Map<String, String>? headers}) =>
      (super.noSuchMethod(
        Invocation.method(#read, [url], {#headers: headers}),
        returnValue: _i11.Future<String>.value(
          _i13.dummyValue<String>(
            this,
            Invocation.method(#read, [url], {#headers: headers}),
          ),
        ),
        returnValueForMissingStub: _i11.Future<String>.value(
          _i13.dummyValue<String>(
            this,
            Invocation.method(#read, [url], {#headers: headers}),
          ),
        ),
      ) as _i11.Future<String>);

  @override
  _i11.Future<_i14.Uint8List> readBytes(
    Uri? url, {
    Map<String, String>? headers,
  }) =>
      (super.noSuchMethod(
        Invocation.method(#readBytes, [url], {#headers: headers}),
        returnValue: _i11.Future<_i14.Uint8List>.value(_i14.Uint8List(0)),
        returnValueForMissingStub: _i11.Future<_i14.Uint8List>.value(
          _i14.Uint8List(0),
        ),
      ) as _i11.Future<_i14.Uint8List>);

  @override
  _i11.Future<_i2.StreamedResponse> send(_i2.BaseRequest? request) =>
      (super.noSuchMethod(
        Invocation.method(#send, [request]),
        returnValue: _i11.Future<_i2.StreamedResponse>.value(
          _FakeStreamedResponse_2(
            this,
            Invocation.method(#send, [request]),
          ),
        ),
        returnValueForMissingStub: _i11.Future<_i2.StreamedResponse>.value(
          _FakeStreamedResponse_2(
            this,
            Invocation.method(#send, [request]),
          ),
        ),
      ) as _i11.Future<_i2.StreamedResponse>);

  @override
  void close() => super.noSuchMethod(
        Invocation.method(#close, []),
        returnValueForMissingStub: null,
      );
}

/// A class which mocks [GoogleSignIn].
///
/// See the documentation for Mockito's code generation for more information.
class MockGoogleSignIn extends _i1.Mock implements _i8.GoogleSignIn {
  @override
  _i8.SignInOption get signInOption => (super.noSuchMethod(
        Invocation.getter(#signInOption),
        returnValue: _i8.SignInOption.standard,
        returnValueForMissingStub: _i8.SignInOption.standard,
      ) as _i8.SignInOption);

  @override
  List<String> get scopes => (super.noSuchMethod(
        Invocation.getter(#scopes),
        returnValue: <String>[],
        returnValueForMissingStub: <String>[],
      ) as List<String>);

  @override
  bool get forceCodeForRefreshToken => (super.noSuchMethod(
        Invocation.getter(#forceCodeForRefreshToken),
        returnValue: false,
        returnValueForMissingStub: false,
      ) as bool);

  @override
  _i11.Stream<_i8.GoogleSignInAccount?> get onCurrentUserChanged =>
      (super.noSuchMethod(
        Invocation.getter(#onCurrentUserChanged),
        returnValue: _i11.Stream<_i8.GoogleSignInAccount?>.empty(),
        returnValueForMissingStub:
            _i11.Stream<_i8.GoogleSignInAccount?>.empty(),
      ) as _i11.Stream<_i8.GoogleSignInAccount?>);

  @override
  _i11.Future<_i8.GoogleSignInAccount?> signInSilently({
    bool? suppressErrors = true,
    bool? reAuthenticate = false,
  }) =>
      (super.noSuchMethod(
        Invocation.method(#signInSilently, [], {
          #suppressErrors: suppressErrors,
          #reAuthenticate: reAuthenticate,
        }),
        returnValue: _i11.Future<_i8.GoogleSignInAccount?>.value(),
        returnValueForMissingStub:
            _i11.Future<_i8.GoogleSignInAccount?>.value(),
      ) as _i11.Future<_i8.GoogleSignInAccount?>);

  @override
  _i11.Future<bool> isSignedIn() => (super.noSuchMethod(
        Invocation.method(#isSignedIn, []),
        returnValue: _i11.Future<bool>.value(false),
        returnValueForMissingStub: _i11.Future<bool>.value(false),
      ) as _i11.Future<bool>);

  @override
  _i11.Future<_i8.GoogleSignInAccount?> signIn() => (super.noSuchMethod(
        Invocation.method(#signIn, []),
        returnValue: _i11.Future<_i8.GoogleSignInAccount?>.value(),
        returnValueForMissingStub:
            _i11.Future<_i8.GoogleSignInAccount?>.value(),
      ) as _i11.Future<_i8.GoogleSignInAccount?>);

  @override
  _i11.Future<_i8.GoogleSignInAccount?> signOut() => (super.noSuchMethod(
        Invocation.method(#signOut, []),
        returnValue: _i11.Future<_i8.GoogleSignInAccount?>.value(),
        returnValueForMissingStub:
            _i11.Future<_i8.GoogleSignInAccount?>.value(),
      ) as _i11.Future<_i8.GoogleSignInAccount?>);

  @override
  _i11.Future<_i8.GoogleSignInAccount?> disconnect() => (super.noSuchMethod(
        Invocation.method(#disconnect, []),
        returnValue: _i11.Future<_i8.GoogleSignInAccount?>.value(),
        returnValueForMissingStub:
            _i11.Future<_i8.GoogleSignInAccount?>.value(),
      ) as _i11.Future<_i8.GoogleSignInAccount?>);

  @override
  _i11.Future<bool> requestScopes(List<String>? scopes) => (super.noSuchMethod(
        Invocation.method(#requestScopes, [scopes]),
        returnValue: _i11.Future<bool>.value(false),
        returnValueForMissingStub: _i11.Future<bool>.value(false),
      ) as _i11.Future<bool>);

  @override
  _i11.Future<bool> canAccessScopes(
    List<String>? scopes, {
    String? accessToken,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #canAccessScopes,
          [scopes],
          {#accessToken: accessToken},
        ),
        returnValue: _i11.Future<bool>.value(false),
        returnValueForMissingStub: _i11.Future<bool>.value(false),
      ) as _i11.Future<bool>);
}

/// A class which mocks [GoogleSignInAccount].
///
/// See the documentation for Mockito's code generation for more information.

class MockGoogleSignInAccount extends _i1.Mock
    implements _i8.GoogleSignInAccount {
  @override
  String get email => (super.noSuchMethod(
        Invocation.getter(#email),
        returnValue: _i13.dummyValue<String>(
          this,
          Invocation.getter(#email),
        ),
        returnValueForMissingStub: _i13.dummyValue<String>(
          this,
          Invocation.getter(#email),
        ),
      ) as String);

  @override
  String get id => (super.noSuchMethod(
        Invocation.getter(#id),
        returnValue: _i13.dummyValue<String>(this, Invocation.getter(#id)),
        returnValueForMissingStub: _i13.dummyValue<String>(
          this,
          Invocation.getter(#id),
        ),
      ) as String);

  @override
  _i11.Future<_i8.GoogleSignInAuthentication> get authentication =>
      (super.noSuchMethod(
        Invocation.getter(#authentication),
        returnValue: _i11.Future<_i8.GoogleSignInAuthentication>.value(
          _FakeGoogleSignInAuthentication_12(
            this,
            Invocation.getter(#authentication),
          ),
        ),
        returnValueForMissingStub:
            _i11.Future<_i8.GoogleSignInAuthentication>.value(
          _FakeGoogleSignInAuthentication_12(
            this,
            Invocation.getter(#authentication),
          ),
        ),
      ) as _i11.Future<_i8.GoogleSignInAuthentication>);

  @override
  _i11.Future<Map<String, String>> get authHeaders => (super.noSuchMethod(
        Invocation.getter(#authHeaders),
        returnValue: _i11.Future<Map<String, String>>.value(
          <String, String>{},
        ),
        returnValueForMissingStub: _i11.Future<Map<String, String>>.value(
          <String, String>{},
        ),
      ) as _i11.Future<Map<String, String>>);

  @override
  _i11.Future<void> clearAuthCache() => (super.noSuchMethod(
        Invocation.method(#clearAuthCache, []),
        returnValue: _i11.Future<void>.value(),
        returnValueForMissingStub: _i11.Future<void>.value(),
      ) as _i11.Future<void>);
}

/// A class which mocks [GoogleSignInAuthentication].
///
/// See the documentation for Mockito's code generation for more information.
class MockGoogleSignInAuthentication extends _i1.Mock
    implements _i8.GoogleSignInAuthentication {}
