// Mocks generated by Mockito 5.4.5 from annotations
// in soen_390/test/repositories/auth_repository_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i8;
import 'dart:convert' as _i9;
import 'dart:typed_data' as _i11;

import 'package:google_sign_in/google_sign_in.dart' as _i4;
import 'package:googleapis_auth/googleapis_auth.dart' as _i6;
import 'package:http/http.dart' as _i5;
import 'package:mockito/mockito.dart' as _i1;
import 'package:mockito/src/dummies.dart' as _i10;
import 'package:soen_390/core/secure_storage.dart' as _i2;
import 'package:soen_390/services/auth_service.dart' as _i7;
import 'package:soen_390/services/http_service.dart' as _i3;

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

class _FakeSecureStorage_0 extends _i1.SmartFake implements _i2.SecureStorage {
  _FakeSecureStorage_0(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

class _FakeHttpService_1 extends _i1.SmartFake implements _i3.HttpService {
  _FakeHttpService_1(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

class _FakeGoogleSignIn_2 extends _i1.SmartFake implements _i4.GoogleSignIn {
  _FakeGoogleSignIn_2(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

class _FakeClient_3 extends _i1.SmartFake implements _i5.Client {
  _FakeClient_3(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

class _FakeResponse_4 extends _i1.SmartFake implements _i5.Response {
  _FakeResponse_4(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

class _FakeAccessCredentials_5 extends _i1.SmartFake
    implements _i6.AccessCredentials {
  _FakeAccessCredentials_5(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

class _FakeStreamedResponse_6 extends _i1.SmartFake
    implements _i5.StreamedResponse {
  _FakeStreamedResponse_6(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

/// A class which mocks [AuthService].
///
/// See the documentation for Mockito's code generation for more information.
class MockAuthService extends _i1.Mock implements _i7.AuthService {
  @override
  _i2.SecureStorage get secureStorage => (super.noSuchMethod(
        Invocation.getter(#secureStorage),
        returnValue: _FakeSecureStorage_0(
          this,
          Invocation.getter(#secureStorage),
        ),
        returnValueForMissingStub: _FakeSecureStorage_0(
          this,
          Invocation.getter(#secureStorage),
        ),
      ) as _i2.SecureStorage);

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
  _i4.GoogleSignIn get googleSignIn => (super.noSuchMethod(
        Invocation.getter(#googleSignIn),
        returnValue: _FakeGoogleSignIn_2(
          this,
          Invocation.getter(#googleSignIn),
        ),
        returnValueForMissingStub: _FakeGoogleSignIn_2(
          this,
          Invocation.getter(#googleSignIn),
        ),
      ) as _i4.GoogleSignIn);

  @override
  _i8.Future<_i6.AuthClient?> signIn() => (super.noSuchMethod(
        Invocation.method(#signIn, []),
        returnValue: _i8.Future<_i6.AuthClient?>.value(),
        returnValueForMissingStub: _i8.Future<_i6.AuthClient?>.value(),
      ) as _i8.Future<_i6.AuthClient?>);

  @override
  _i8.Future<void> signOut() => (super.noSuchMethod(
        Invocation.method(#signOut, []),
        returnValue: _i8.Future<void>.value(),
        returnValueForMissingStub: _i8.Future<void>.value(),
      ) as _i8.Future<void>);

  @override
  void dispose() => super.noSuchMethod(
        Invocation.method(#dispose, []),
        returnValueForMissingStub: null,
      );
}

/// A class which mocks [HttpService].
///
/// See the documentation for Mockito's code generation for more information.
class MockHttpService extends _i1.Mock implements _i3.HttpService {
  @override
  _i5.Client get client => (super.noSuchMethod(
        Invocation.getter(#client),
        returnValue: _FakeClient_3(this, Invocation.getter(#client)),
        returnValueForMissingStub: _FakeClient_3(
          this,
          Invocation.getter(#client),
        ),
      ) as _i5.Client);

  @override
  _i8.Future<_i5.Response> get(Uri? url) => (super.noSuchMethod(
        Invocation.method(#get, [url]),
        returnValue: _i8.Future<_i5.Response>.value(
          _FakeResponse_4(this, Invocation.method(#get, [url])),
        ),
        returnValueForMissingStub: _i8.Future<_i5.Response>.value(
          _FakeResponse_4(this, Invocation.method(#get, [url])),
        ),
      ) as _i8.Future<_i5.Response>);

  @override
  void dispose() => super.noSuchMethod(
        Invocation.method(#dispose, []),
        returnValueForMissingStub: null,
      );
}

/// A class which mocks [SecureStorage].
///
/// See the documentation for Mockito's code generation for more information.
class MockSecureStorage extends _i1.Mock implements _i2.SecureStorage {
  @override
  _i8.Future<void> storeToken(String? key, String? value) =>
      (super.noSuchMethod(
        Invocation.method(#storeToken, [key, value]),
        returnValue: _i8.Future<void>.value(),
        returnValueForMissingStub: _i8.Future<void>.value(),
      ) as _i8.Future<void>);

  @override
  _i8.Future<String?> getToken(String? key) => (super.noSuchMethod(
        Invocation.method(#getToken, [key]),
        returnValue: _i8.Future<String?>.value(),
        returnValueForMissingStub: _i8.Future<String?>.value(),
      ) as _i8.Future<String?>);

  @override
  _i8.Future<void> deleteToken(String? key) => (super.noSuchMethod(
        Invocation.method(#deleteToken, [key]),
        returnValue: _i8.Future<void>.value(),
        returnValueForMissingStub: _i8.Future<void>.value(),
      ) as _i8.Future<void>);
}

/// A class which mocks [AuthClient].
///
/// See the documentation for Mockito's code generation for more information.
class MockAuthClient extends _i1.Mock implements _i6.AuthClient {
  @override
  _i6.AccessCredentials get credentials => (super.noSuchMethod(
        Invocation.getter(#credentials),
        returnValue: _FakeAccessCredentials_5(
          this,
          Invocation.getter(#credentials),
        ),
        returnValueForMissingStub: _FakeAccessCredentials_5(
          this,
          Invocation.getter(#credentials),
        ),
      ) as _i6.AccessCredentials);

  @override
  _i8.Future<_i5.Response> head(Uri? url, {Map<String, String>? headers}) =>
      (super.noSuchMethod(
        Invocation.method(#head, [url], {#headers: headers}),
        returnValue: _i8.Future<_i5.Response>.value(
          _FakeResponse_4(
            this,
            Invocation.method(#head, [url], {#headers: headers}),
          ),
        ),
        returnValueForMissingStub: _i8.Future<_i5.Response>.value(
          _FakeResponse_4(
            this,
            Invocation.method(#head, [url], {#headers: headers}),
          ),
        ),
      ) as _i8.Future<_i5.Response>);

  @override
  _i8.Future<_i5.Response> get(Uri? url, {Map<String, String>? headers}) =>
      (super.noSuchMethod(
        Invocation.method(#get, [url], {#headers: headers}),
        returnValue: _i8.Future<_i5.Response>.value(
          _FakeResponse_4(
            this,
            Invocation.method(#get, [url], {#headers: headers}),
          ),
        ),
        returnValueForMissingStub: _i8.Future<_i5.Response>.value(
          _FakeResponse_4(
            this,
            Invocation.method(#get, [url], {#headers: headers}),
          ),
        ),
      ) as _i8.Future<_i5.Response>);

  @override
  _i8.Future<_i5.Response> post(
    Uri? url, {
    Map<String, String>? headers,
    Object? body,
    _i9.Encoding? encoding,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #post,
          [url],
          {#headers: headers, #body: body, #encoding: encoding},
        ),
        returnValue: _i8.Future<_i5.Response>.value(
          _FakeResponse_4(
            this,
            Invocation.method(
              #post,
              [url],
              {#headers: headers, #body: body, #encoding: encoding},
            ),
          ),
        ),
        returnValueForMissingStub: _i8.Future<_i5.Response>.value(
          _FakeResponse_4(
            this,
            Invocation.method(
              #post,
              [url],
              {#headers: headers, #body: body, #encoding: encoding},
            ),
          ),
        ),
      ) as _i8.Future<_i5.Response>);

  @override
  _i8.Future<_i5.Response> put(
    Uri? url, {
    Map<String, String>? headers,
    Object? body,
    _i9.Encoding? encoding,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #put,
          [url],
          {#headers: headers, #body: body, #encoding: encoding},
        ),
        returnValue: _i8.Future<_i5.Response>.value(
          _FakeResponse_4(
            this,
            Invocation.method(
              #put,
              [url],
              {#headers: headers, #body: body, #encoding: encoding},
            ),
          ),
        ),
        returnValueForMissingStub: _i8.Future<_i5.Response>.value(
          _FakeResponse_4(
            this,
            Invocation.method(
              #put,
              [url],
              {#headers: headers, #body: body, #encoding: encoding},
            ),
          ),
        ),
      ) as _i8.Future<_i5.Response>);

  @override
  _i8.Future<_i5.Response> patch(
    Uri? url, {
    Map<String, String>? headers,
    Object? body,
    _i9.Encoding? encoding,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #patch,
          [url],
          {#headers: headers, #body: body, #encoding: encoding},
        ),
        returnValue: _i8.Future<_i5.Response>.value(
          _FakeResponse_4(
            this,
            Invocation.method(
              #patch,
              [url],
              {#headers: headers, #body: body, #encoding: encoding},
            ),
          ),
        ),
        returnValueForMissingStub: _i8.Future<_i5.Response>.value(
          _FakeResponse_4(
            this,
            Invocation.method(
              #patch,
              [url],
              {#headers: headers, #body: body, #encoding: encoding},
            ),
          ),
        ),
      ) as _i8.Future<_i5.Response>);

  @override
  _i8.Future<_i5.Response> delete(
    Uri? url, {
    Map<String, String>? headers,
    Object? body,
    _i9.Encoding? encoding,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #delete,
          [url],
          {#headers: headers, #body: body, #encoding: encoding},
        ),
        returnValue: _i8.Future<_i5.Response>.value(
          _FakeResponse_4(
            this,
            Invocation.method(
              #delete,
              [url],
              {#headers: headers, #body: body, #encoding: encoding},
            ),
          ),
        ),
        returnValueForMissingStub: _i8.Future<_i5.Response>.value(
          _FakeResponse_4(
            this,
            Invocation.method(
              #delete,
              [url],
              {#headers: headers, #body: body, #encoding: encoding},
            ),
          ),
        ),
      ) as _i8.Future<_i5.Response>);

  @override
  _i8.Future<String> read(Uri? url, {Map<String, String>? headers}) =>
      (super.noSuchMethod(
        Invocation.method(#read, [url], {#headers: headers}),
        returnValue: _i8.Future<String>.value(
          _i10.dummyValue<String>(
            this,
            Invocation.method(#read, [url], {#headers: headers}),
          ),
        ),
        returnValueForMissingStub: _i8.Future<String>.value(
          _i10.dummyValue<String>(
            this,
            Invocation.method(#read, [url], {#headers: headers}),
          ),
        ),
      ) as _i8.Future<String>);

  @override
  _i8.Future<_i11.Uint8List> readBytes(
    Uri? url, {
    Map<String, String>? headers,
  }) =>
      (super.noSuchMethod(
        Invocation.method(#readBytes, [url], {#headers: headers}),
        returnValue: _i8.Future<_i11.Uint8List>.value(_i11.Uint8List(0)),
        returnValueForMissingStub: _i8.Future<_i11.Uint8List>.value(
          _i11.Uint8List(0),
        ),
      ) as _i8.Future<_i11.Uint8List>);

  @override
  _i8.Future<_i5.StreamedResponse> send(_i5.BaseRequest? request) =>
      (super.noSuchMethod(
        Invocation.method(#send, [request]),
        returnValue: _i8.Future<_i5.StreamedResponse>.value(
          _FakeStreamedResponse_6(
            this,
            Invocation.method(#send, [request]),
          ),
        ),
        returnValueForMissingStub: _i8.Future<_i5.StreamedResponse>.value(
          _FakeStreamedResponse_6(
            this,
            Invocation.method(#send, [request]),
          ),
        ),
      ) as _i8.Future<_i5.StreamedResponse>);

  @override
  void close() => super.noSuchMethod(
        Invocation.method(#close, []),
        returnValueForMissingStub: null,
      );
}
