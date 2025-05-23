// Mocks generated by Mockito 5.4.5 from annotations
// in soen_390/test/repositories/geojson_repository_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i4;

import 'package:flutter/services.dart' as _i2;
import 'package:mockito/mockito.dart' as _i1;
import 'package:soen_390/utils/geojson_loader.dart' as _i3;

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

class _FakeAssetBundle_0 extends _i1.SmartFake implements _i2.AssetBundle {
  _FakeAssetBundle_0(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

/// A class which mocks [GeoJsonLoader].
///
/// See the documentation for Mockito's code generation for more information.
class MockGeoJsonLoader extends _i1.Mock implements _i3.GeoJsonLoader {
  MockGeoJsonLoader() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.AssetBundle get assetBundle => (super.noSuchMethod(
        Invocation.getter(#assetBundle),
        returnValue: _FakeAssetBundle_0(
          this,
          Invocation.getter(#assetBundle),
        ),
      ) as _i2.AssetBundle);

  @override
  _i4.Future<Map<String, dynamic>> load(String? path) => (super.noSuchMethod(
        Invocation.method(#load, [path]),
        returnValue: _i4.Future<Map<String, dynamic>>.value(
          <String, dynamic>{},
        ),
      ) as _i4.Future<Map<String, dynamic>>);
}
