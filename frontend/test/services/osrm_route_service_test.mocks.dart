// Mocks generated by Mockito 5.4.5 from annotations
// in soen_390/test/services/osrm_route_service_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i7;

import 'package:mockito/mockito.dart' as _i1;
import 'package:osrm/osrm.dart' as _i6;
import 'package:osrm/src/services/match.dart' as _i5;
import 'package:osrm/src/services/nearest.dart' as _i3;
import 'package:osrm/src/services/route.dart' as _i4;
import 'package:osrm/src/shared/core.dart' as _i2;

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

class _FakeOsrmSource_0 extends _i1.SmartFake implements _i2.OsrmSource {
  _FakeOsrmSource_0(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

class _FakeNearestResponse_1 extends _i1.SmartFake
    implements _i3.NearestResponse {
  _FakeNearestResponse_1(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

class _FakeRouteResponse_2 extends _i1.SmartFake implements _i4.RouteResponse {
  _FakeRouteResponse_2(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

class _FakeMatchResponse_3 extends _i1.SmartFake implements _i5.MatchResponse {
  _FakeMatchResponse_3(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

/// A class which mocks [Osrm].
///
/// See the documentation for Mockito's code generation for more information.
class MockOsrm extends _i1.Mock implements _i6.Osrm {
  MockOsrm() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.OsrmSource get source => (super.noSuchMethod(
        Invocation.getter(#source),
        returnValue: _FakeOsrmSource_0(this, Invocation.getter(#source)),
      ) as _i2.OsrmSource);

  @override
  _i7.Future<_i3.NearestResponse> nearest(_i3.NearestOptions? options) =>
      (super.noSuchMethod(
        Invocation.method(#nearest, [options]),
        returnValue: _i7.Future<_i3.NearestResponse>.value(
          _FakeNearestResponse_1(
            this,
            Invocation.method(#nearest, [options]),
          ),
        ),
      ) as _i7.Future<_i3.NearestResponse>);

  @override
  _i7.Future<_i4.RouteResponse> route(_i4.RouteRequest? options) =>
      (super.noSuchMethod(
        Invocation.method(#route, [options]),
        returnValue: _i7.Future<_i4.RouteResponse>.value(
          _FakeRouteResponse_2(this, Invocation.method(#route, [options])),
        ),
      ) as _i7.Future<_i4.RouteResponse>);

  @override
  _i7.Future<_i5.MatchResponse> match(_i5.MatchOptions? options) =>
      (super.noSuchMethod(
        Invocation.method(#match, [options]),
        returnValue: _i7.Future<_i5.MatchResponse>.value(
          _FakeMatchResponse_3(this, Invocation.method(#match, [options])),
        ),
      ) as _i7.Future<_i5.MatchResponse>);
}
