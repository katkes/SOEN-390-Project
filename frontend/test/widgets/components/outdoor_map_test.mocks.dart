// Mocks generated by Mockito 5.4.5 from annotations
// in soen_390/test/widgets/components/outdoor_map_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i7;

import 'package:http/http.dart' as _i2;
import 'package:latlong2/latlong.dart' as _i9;
import 'package:mockito/mockito.dart' as _i1;
import 'package:mockito/src/dummies.dart' as _i12;
import 'package:soen_390/models/route_result.dart' as _i8;
import 'package:soen_390/services/google_maps_api_client.dart' as _i11;
import 'package:soen_390/services/interfaces/http_client_interface.dart' as _i4;
import 'package:soen_390/services/interfaces/maps_api_client.dart' as _i3;
import 'package:soen_390/services/interfaces/route_service_interface.dart'
    as _i6;
import 'package:soen_390/utils/google_api_helper.dart' as _i5;
import 'package:soen_390/widgets/building_popup.dart' as _i10;

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

class _FakeMapsApiClient_1 extends _i1.SmartFake implements _i3.MapsApiClient {
  _FakeMapsApiClient_1(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class _FakeIHttpClient_2 extends _i1.SmartFake implements _i4.IHttpClient {
  _FakeIHttpClient_2(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class _FakeGoogleApiHelper_3 extends _i1.SmartFake
    implements _i5.GoogleApiHelper {
  _FakeGoogleApiHelper_3(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

/// A class which mocks [IRouteService].
///
/// See the documentation for Mockito's code generation for more information.
class MockIRouteService extends _i1.Mock implements _i6.IRouteService {
  @override
  _i7.Future<_i8.RouteResult?> getRoute({
    required _i9.LatLng? from,
    required _i9.LatLng? to,
  }) =>
      (super.noSuchMethod(
            Invocation.method(#getRoute, [], {#from: from, #to: to}),
            returnValue: _i7.Future<_i8.RouteResult?>.value(),
            returnValueForMissingStub: _i7.Future<_i8.RouteResult?>.value(),
          )
          as _i7.Future<_i8.RouteResult?>);
}

/// A class which mocks [IHttpClient].
///
/// See the documentation for Mockito's code generation for more information.
class MockIHttpClient extends _i1.Mock implements _i4.IHttpClient {
  @override
  _i7.Future<_i2.Response> get(Uri? url) =>
      (super.noSuchMethod(
            Invocation.method(#get, [url]),
            returnValue: _i7.Future<_i2.Response>.value(
              _FakeResponse_0(this, Invocation.method(#get, [url])),
            ),
            returnValueForMissingStub: _i7.Future<_i2.Response>.value(
              _FakeResponse_0(this, Invocation.method(#get, [url])),
            ),
          )
          as _i7.Future<_i2.Response>);
}

/// A class which mocks [BuildingPopUps].
///
/// See the documentation for Mockito's code generation for more information.
class MockBuildingPopUps extends _i1.Mock implements _i10.BuildingPopUps {
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
  _i7.Future<Map<String, dynamic>> fetchBuildingInformation(
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
            returnValue: _i7.Future<Map<String, dynamic>>.value(
              <String, dynamic>{},
            ),
            returnValueForMissingStub: _i7.Future<Map<String, dynamic>>.value(
              <String, dynamic>{},
            ),
          )
          as _i7.Future<Map<String, dynamic>>);
}

/// A class which mocks [GoogleMapsApiClient].
///
/// See the documentation for Mockito's code generation for more information.
class MockGoogleMapsApiClient extends _i1.Mock
    implements _i11.GoogleMapsApiClient {
  @override
  String get apiKey =>
      (super.noSuchMethod(
            Invocation.getter(#apiKey),
            returnValue: _i12.dummyValue<String>(
              this,
              Invocation.getter(#apiKey),
            ),
            returnValueForMissingStub: _i12.dummyValue<String>(
              this,
              Invocation.getter(#apiKey),
            ),
          )
          as String);

  @override
  _i4.IHttpClient get httpClient =>
      (super.noSuchMethod(
            Invocation.getter(#httpClient),
            returnValue: _FakeIHttpClient_2(
              this,
              Invocation.getter(#httpClient),
            ),
            returnValueForMissingStub: _FakeIHttpClient_2(
              this,
              Invocation.getter(#httpClient),
            ),
          )
          as _i4.IHttpClient);

  @override
  _i5.GoogleApiHelper get apiHelper =>
      (super.noSuchMethod(
            Invocation.getter(#apiHelper),
            returnValue: _FakeGoogleApiHelper_3(
              this,
              Invocation.getter(#apiHelper),
            ),
            returnValueForMissingStub: _FakeGoogleApiHelper_3(
              this,
              Invocation.getter(#apiHelper),
            ),
          )
          as _i5.GoogleApiHelper);

  @override
  _i7.Future<Map<String, dynamic>> fetchBuildingInformation(
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
            returnValue: _i7.Future<Map<String, dynamic>>.value(
              <String, dynamic>{},
            ),
            returnValueForMissingStub: _i7.Future<Map<String, dynamic>>.value(
              <String, dynamic>{},
            ),
          )
          as _i7.Future<Map<String, dynamic>>);

  @override
  _i7.Future<Map<String, dynamic>> fetchPlaceDetailsById(String? placeId) =>
      (super.noSuchMethod(
            Invocation.method(#fetchPlaceDetailsById, [placeId]),
            returnValue: _i7.Future<Map<String, dynamic>>.value(
              <String, dynamic>{},
            ),
            returnValueForMissingStub: _i7.Future<Map<String, dynamic>>.value(
              <String, dynamic>{},
            ),
          )
          as _i7.Future<Map<String, dynamic>>);
}
