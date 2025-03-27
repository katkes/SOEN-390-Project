// Mocks generated by Mockito 5.4.5 from annotations
// in soen_390/test/services/google_poi_service_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i4;

import 'package:http/http.dart' as _i2;
import 'package:mockito/mockito.dart' as _i1;
import 'package:soen_390/services/interfaces/http_client_interface.dart' as _i3;
import 'package:soen_390/utils/google_api_helper.dart' as _i5;

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

/// A class which mocks [IHttpClient].
///
/// See the documentation for Mockito's code generation for more information.
class MockIHttpClient extends _i1.Mock implements _i3.IHttpClient {
  @override
  _i4.Future<_i2.Response> get(Uri? url) =>
      (super.noSuchMethod(
            Invocation.method(#get, [url]),
            returnValue: _i4.Future<_i2.Response>.value(
              _FakeResponse_0(this, Invocation.method(#get, [url])),
            ),
            returnValueForMissingStub: _i4.Future<_i2.Response>.value(
              _FakeResponse_0(this, Invocation.method(#get, [url])),
            ),
          )
          as _i4.Future<_i2.Response>);
}

/// A class which mocks [GoogleApiHelper].
///
/// See the documentation for Mockito's code generation for more information.
class MockGoogleApiHelper extends _i1.Mock implements _i5.GoogleApiHelper {
  @override
  _i4.Future<Map<String, dynamic>> fetchJson(
    _i3.IHttpClient? client,
    Uri? url, {
    String? expectedStatus = 'OK',
  }) =>
      (super.noSuchMethod(
            Invocation.method(
              #fetchJson,
              [client, url],
              {#expectedStatus: expectedStatus},
            ),
            returnValue: _i4.Future<Map<String, dynamic>>.value(
              <String, dynamic>{},
            ),
            returnValueForMissingStub: _i4.Future<Map<String, dynamic>>.value(
              <String, dynamic>{},
            ),
          )
          as _i4.Future<Map<String, dynamic>>);
}
