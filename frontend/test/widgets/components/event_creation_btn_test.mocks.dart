// Mocks generated by Mockito 5.4.5 from annotations
// in soen_390/test/widgets/components/event_creation_btn_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i7;

import 'package:google_sign_in/google_sign_in.dart' as _i4;
import 'package:googleapis/calendar/v3.dart' as _i10;
import 'package:googleapis_auth/googleapis_auth.dart' as _i8;
import 'package:http/http.dart' as _i5;
import 'package:mockito/mockito.dart' as _i1;
import 'package:soen_390/core/secure_storage.dart' as _i2;
import 'package:soen_390/repositories/auth_repository.dart' as _i11;
import 'package:soen_390/services/auth_service.dart' as _i6;
import 'package:soen_390/services/calendar_service.dart' as _i9;
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

/// A class which mocks [AuthService].
///
/// See the documentation for Mockito's code generation for more information.
class MockAuthService extends _i1.Mock implements _i6.AuthService {
  MockAuthService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.SecureStorage get secureStorage => (super.noSuchMethod(
        Invocation.getter(#secureStorage),
        returnValue: _FakeSecureStorage_0(
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
      ) as _i3.HttpService);

  @override
  _i4.GoogleSignIn get googleSignIn => (super.noSuchMethod(
        Invocation.getter(#googleSignIn),
        returnValue: _FakeGoogleSignIn_2(
          this,
          Invocation.getter(#googleSignIn),
        ),
      ) as _i4.GoogleSignIn);

  @override
  _i7.Future<_i8.AuthClient?> signIn() => (super.noSuchMethod(
        Invocation.method(#signIn, []),
        returnValue: _i7.Future<_i8.AuthClient?>.value(),
      ) as _i7.Future<_i8.AuthClient?>);

  @override
  _i7.Future<void> signOut() => (super.noSuchMethod(
        Invocation.method(#signOut, []),
        returnValue: _i7.Future<void>.value(),
        returnValueForMissingStub: _i7.Future<void>.value(),
      ) as _i7.Future<void>);

  @override
  void dispose() => super.noSuchMethod(
        Invocation.method(#dispose, []),
        returnValueForMissingStub: null,
      );
}

/// A class which mocks [CalendarService].
///
/// See the documentation for Mockito's code generation for more information.
class MockCalendarService extends _i1.Mock implements _i9.CalendarService {
  MockCalendarService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i7.Future<List<_i10.Event>> fetchEvents([String? calendarId = 'primary']) =>
      (super.noSuchMethod(
        Invocation.method(#fetchEvents, [calendarId]),
        returnValue: _i7.Future<List<_i10.Event>>.value(<_i10.Event>[]),
      ) as _i7.Future<List<_i10.Event>>);

  @override
  _i7.Future<List<_i10.CalendarListEntry>> fetchCalendars() =>
      (super.noSuchMethod(
        Invocation.method(#fetchCalendars, []),
        returnValue: _i7.Future<List<_i10.CalendarListEntry>>.value(
          <_i10.CalendarListEntry>[],
        ),
      ) as _i7.Future<List<_i10.CalendarListEntry>>);

  @override
  _i7.Future<_i10.Event?> createEvent(String? calendarId, _i10.Event? event) =>
      (super.noSuchMethod(
        Invocation.method(#createEvent, [calendarId, event]),
        returnValue: _i7.Future<_i10.Event?>.value(),
      ) as _i7.Future<_i10.Event?>);

  @override
  _i7.Future<_i10.Event?> updateEvent(
    String? calendarId,
    String? eventId,
    _i10.Event? updatedEvent,
  ) =>
      (super.noSuchMethod(
        Invocation.method(#updateEvent, [
          calendarId,
          eventId,
          updatedEvent,
        ]),
        returnValue: _i7.Future<_i10.Event?>.value(),
      ) as _i7.Future<_i10.Event?>);

  @override
  _i7.Future<void> deleteEvent(String? calendarId, String? eventId) =>
      (super.noSuchMethod(
        Invocation.method(#deleteEvent, [calendarId, eventId]),
        returnValue: _i7.Future<void>.value(),
        returnValueForMissingStub: _i7.Future<void>.value(),
      ) as _i7.Future<void>);
}

/// A class which mocks [HttpService].
///
/// See the documentation for Mockito's code generation for more information.
class MockHttpService extends _i1.Mock implements _i3.HttpService {
  MockHttpService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i5.Client get client => (super.noSuchMethod(
        Invocation.getter(#client),
        returnValue: _FakeClient_3(this, Invocation.getter(#client)),
      ) as _i5.Client);

  @override
  _i7.Future<_i5.Response> get(Uri? url) => (super.noSuchMethod(
        Invocation.method(#get, [url]),
        returnValue: _i7.Future<_i5.Response>.value(
          _FakeResponse_4(this, Invocation.method(#get, [url])),
        ),
      ) as _i7.Future<_i5.Response>);

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
  MockSecureStorage() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i7.Future<void> storeToken(String? key, String? value) =>
      (super.noSuchMethod(
        Invocation.method(#storeToken, [key, value]),
        returnValue: _i7.Future<void>.value(),
        returnValueForMissingStub: _i7.Future<void>.value(),
      ) as _i7.Future<void>);

  @override
  _i7.Future<String?> getToken(String? key) => (super.noSuchMethod(
        Invocation.method(#getToken, [key]),
        returnValue: _i7.Future<String?>.value(),
      ) as _i7.Future<String?>);

  @override
  _i7.Future<void> deleteToken(String? key) => (super.noSuchMethod(
        Invocation.method(#deleteToken, [key]),
        returnValue: _i7.Future<void>.value(),
        returnValueForMissingStub: _i7.Future<void>.value(),
      ) as _i7.Future<void>);
}

/// A class which mocks [AuthRepository].
///
/// See the documentation for Mockito's code generation for more information.
class MockAuthRepository extends _i1.Mock implements _i11.AuthRepository {
  MockAuthRepository() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i7.Future<_i8.AuthClient?> getAuthClient() => (super.noSuchMethod(
        Invocation.method(#getAuthClient, []),
        returnValue: _i7.Future<_i8.AuthClient?>.value(),
      ) as _i7.Future<_i8.AuthClient?>);

  @override
  _i7.Future<void> signOut() => (super.noSuchMethod(
        Invocation.method(#signOut, []),
        returnValue: _i7.Future<void>.value(),
        returnValueForMissingStub: _i7.Future<void>.value(),
      ) as _i7.Future<void>);
}
