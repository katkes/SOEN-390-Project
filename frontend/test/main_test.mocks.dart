// Mocks generated by Mockito 5.4.5 from annotations
// in soen_390/test/main_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i5;
import 'dart:convert' as _i8;
import 'dart:typed_data' as _i10;

import 'package:http/http.dart' as _i2;
import 'package:latlong2/latlong.dart' as _i6;
import 'package:mockito/mockito.dart' as _i1;
import 'package:mockito/src/dummies.dart' as _i9;
import 'package:soen_390/services/building_info_api.dart' as _i3;
import 'package:soen_390/services/http_service.dart' as _i7;
import 'package:soen_390/services/interfaces/route_service_interface.dart'
    as _i4;

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

/// A class which mocks [IRouteService].
///
/// See the documentation for Mockito's code generation for more information.
class MockIRouteService extends _i1.Mock implements _i4.IRouteService {
  @override
  _i5.Future<_i4.RouteResult?> getRoute({
    required _i6.LatLng? from,
    required _i6.LatLng? to,
  }) =>
      (super.noSuchMethod(
            Invocation.method(#getRoute, [], {#from: from, #to: to}),
            returnValue: _i5.Future<_i4.RouteResult?>.value(),
            returnValueForMissingStub: _i5.Future<_i4.RouteResult?>.value(),
          )
          as _i5.Future<_i4.RouteResult?>);
}

/// A class which mocks [HttpService].
///
/// See the documentation for Mockito's code generation for more information.
class MockHttpService extends _i1.Mock implements _i7.HttpService {
  @override
  _i2.Client get client =>
      (super.noSuchMethod(
            Invocation.getter(#client),
            returnValue: _FakeClient_0(this, Invocation.getter(#client)),
            returnValueForMissingStub: _FakeClient_0(
              this,
              Invocation.getter(#client),
            ),
          )
          as _i2.Client);

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
  _i5.Future<_i2.Response> head(Uri? url, {Map<String, String>? headers}) =>
      (super.noSuchMethod(
            Invocation.method(#head, [url], {#headers: headers}),
            returnValue: _i5.Future<_i2.Response>.value(
              _FakeResponse_1(
                this,
                Invocation.method(#head, [url], {#headers: headers}),
              ),
            ),
            returnValueForMissingStub: _i5.Future<_i2.Response>.value(
              _FakeResponse_1(
                this,
                Invocation.method(#head, [url], {#headers: headers}),
              ),
            ),
          )
          as _i5.Future<_i2.Response>);

  @override
  _i5.Future<_i2.Response> get(Uri? url, {Map<String, String>? headers}) =>
      (super.noSuchMethod(
            Invocation.method(#get, [url], {#headers: headers}),
            returnValue: _i5.Future<_i2.Response>.value(
              _FakeResponse_1(
                this,
                Invocation.method(#get, [url], {#headers: headers}),
              ),
            ),
            returnValueForMissingStub: _i5.Future<_i2.Response>.value(
              _FakeResponse_1(
                this,
                Invocation.method(#get, [url], {#headers: headers}),
              ),
            ),
          )
          as _i5.Future<_i2.Response>);

  @override
  _i5.Future<_i2.Response> post(
    Uri? url, {
    Map<String, String>? headers,
    Object? body,
    _i8.Encoding? encoding,
  }) =>
      (super.noSuchMethod(
            Invocation.method(
              #post,
              [url],
              {#headers: headers, #body: body, #encoding: encoding},
            ),
            returnValue: _i5.Future<_i2.Response>.value(
              _FakeResponse_1(
                this,
                Invocation.method(
                  #post,
                  [url],
                  {#headers: headers, #body: body, #encoding: encoding},
                ),
              ),
            ),
            returnValueForMissingStub: _i5.Future<_i2.Response>.value(
              _FakeResponse_1(
                this,
                Invocation.method(
                  #post,
                  [url],
                  {#headers: headers, #body: body, #encoding: encoding},
                ),
              ),
            ),
          )
          as _i5.Future<_i2.Response>);

  @override
  _i5.Future<_i2.Response> put(
    Uri? url, {
    Map<String, String>? headers,
    Object? body,
    _i8.Encoding? encoding,
  }) =>
      (super.noSuchMethod(
            Invocation.method(
              #put,
              [url],
              {#headers: headers, #body: body, #encoding: encoding},
            ),
            returnValue: _i5.Future<_i2.Response>.value(
              _FakeResponse_1(
                this,
                Invocation.method(
                  #put,
                  [url],
                  {#headers: headers, #body: body, #encoding: encoding},
                ),
              ),
            ),
            returnValueForMissingStub: _i5.Future<_i2.Response>.value(
              _FakeResponse_1(
                this,
                Invocation.method(
                  #put,
                  [url],
                  {#headers: headers, #body: body, #encoding: encoding},
                ),
              ),
            ),
          )
          as _i5.Future<_i2.Response>);

  @override
  _i5.Future<_i2.Response> patch(
    Uri? url, {
    Map<String, String>? headers,
    Object? body,
    _i8.Encoding? encoding,
  }) =>
      (super.noSuchMethod(
            Invocation.method(
              #patch,
              [url],
              {#headers: headers, #body: body, #encoding: encoding},
            ),
            returnValue: _i5.Future<_i2.Response>.value(
              _FakeResponse_1(
                this,
                Invocation.method(
                  #patch,
                  [url],
                  {#headers: headers, #body: body, #encoding: encoding},
                ),
              ),
            ),
            returnValueForMissingStub: _i5.Future<_i2.Response>.value(
              _FakeResponse_1(
                this,
                Invocation.method(
                  #patch,
                  [url],
                  {#headers: headers, #body: body, #encoding: encoding},
                ),
              ),
            ),
          )
          as _i5.Future<_i2.Response>);

  @override
  _i5.Future<_i2.Response> delete(
    Uri? url, {
    Map<String, String>? headers,
    Object? body,
    _i8.Encoding? encoding,
  }) =>
      (super.noSuchMethod(
            Invocation.method(
              #delete,
              [url],
              {#headers: headers, #body: body, #encoding: encoding},
            ),
            returnValue: _i5.Future<_i2.Response>.value(
              _FakeResponse_1(
                this,
                Invocation.method(
                  #delete,
                  [url],
                  {#headers: headers, #body: body, #encoding: encoding},
                ),
              ),
            ),
            returnValueForMissingStub: _i5.Future<_i2.Response>.value(
              _FakeResponse_1(
                this,
                Invocation.method(
                  #delete,
                  [url],
                  {#headers: headers, #body: body, #encoding: encoding},
                ),
              ),
            ),
          )
          as _i5.Future<_i2.Response>);

  @override
  _i5.Future<String> read(Uri? url, {Map<String, String>? headers}) =>
      (super.noSuchMethod(
            Invocation.method(#read, [url], {#headers: headers}),
            returnValue: _i5.Future<String>.value(
              _i9.dummyValue<String>(
                this,
                Invocation.method(#read, [url], {#headers: headers}),
              ),
            ),
            returnValueForMissingStub: _i5.Future<String>.value(
              _i9.dummyValue<String>(
                this,
                Invocation.method(#read, [url], {#headers: headers}),
              ),
            ),
          )
          as _i5.Future<String>);

  @override
  _i5.Future<_i10.Uint8List> readBytes(
    Uri? url, {
    Map<String, String>? headers,
  }) =>
      (super.noSuchMethod(
            Invocation.method(#readBytes, [url], {#headers: headers}),
            returnValue: _i5.Future<_i10.Uint8List>.value(_i10.Uint8List(0)),
            returnValueForMissingStub: _i5.Future<_i10.Uint8List>.value(
              _i10.Uint8List(0),
            ),
          )
          as _i5.Future<_i10.Uint8List>);

  @override
  _i5.Future<_i2.StreamedResponse> send(_i2.BaseRequest? request) =>
      (super.noSuchMethod(
            Invocation.method(#send, [request]),
            returnValue: _i5.Future<_i2.StreamedResponse>.value(
              _FakeStreamedResponse_2(
                this,
                Invocation.method(#send, [request]),
              ),
            ),
            returnValueForMissingStub: _i5.Future<_i2.StreamedResponse>.value(
              _FakeStreamedResponse_2(
                this,
                Invocation.method(#send, [request]),
              ),
            ),
          )
          as _i5.Future<_i2.StreamedResponse>);

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
  _i3.MapsApiClient get mapsApiClient =>
      (super.noSuchMethod(
            Invocation.getter(#mapsApiClient),
            returnValue: _FakeMapsApiClient_3(
              this,
              Invocation.getter(#mapsApiClient),
            ),
            returnValueForMissingStub: _FakeMapsApiClient_3(
              this,
              Invocation.getter(#mapsApiClient),
            ),
          )
          as _i3.MapsApiClient);

  @override
  _i5.Future<Map<String, dynamic>> fetchBuildingInformation(
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
            returnValue: _i5.Future<Map<String, dynamic>>.value(
              <String, dynamic>{},
            ),
            returnValueForMissingStub: _i5.Future<Map<String, dynamic>>.value(
              <String, dynamic>{},
            ),
          )
          as _i5.Future<Map<String, dynamic>>);
}

/// A class which mocks [GoogleMapsApiClient].
///
/// See the documentation for Mockito's code generation for more information.
class MockGoogleMapsApiClient extends _i1.Mock
    implements _i3.GoogleMapsApiClient {
  @override
  String get apiKey =>
      (super.noSuchMethod(
            Invocation.getter(#apiKey),
            returnValue: _i9.dummyValue<String>(
              this,
              Invocation.getter(#apiKey),
            ),
            returnValueForMissingStub: _i9.dummyValue<String>(
              this,
              Invocation.getter(#apiKey),
            ),
          )
          as String);

  @override
  _i2.Client get client =>
      (super.noSuchMethod(
            Invocation.getter(#client),
            returnValue: _FakeClient_0(this, Invocation.getter(#client)),
            returnValueForMissingStub: _FakeClient_0(
              this,
              Invocation.getter(#client),
            ),
          )
          as _i2.Client);

  @override
  _i5.Future<Map<String, dynamic>> fetchBuildingInformation(
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
            returnValue: _i5.Future<Map<String, dynamic>>.value(
              <String, dynamic>{},
            ),
            returnValueForMissingStub: _i5.Future<Map<String, dynamic>>.value(
              <String, dynamic>{},
            ),
          )
          as _i5.Future<Map<String, dynamic>>);
}
