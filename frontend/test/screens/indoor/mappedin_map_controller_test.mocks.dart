// Mocks generated by Mockito 5.4.5 from annotations
// in soen_390/test/screens/indoor/mappedin_map_controller_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i7;
import 'dart:ui' as _i8;

import 'package:flutter/foundation.dart' as _i5;
import 'package:flutter/material.dart' as _i3;
import 'package:flutter/services.dart' as _i9;
import 'package:mockito/mockito.dart' as _i1;
import 'package:mockito/src/dummies.dart' as _i6;
import 'package:soen_390/widgets/mappedin_webview.dart' as _i4;
import 'package:webview_flutter/webview_flutter.dart' as _i2;

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

class _FakeWebViewController_0 extends _i1.SmartFake
    implements _i2.WebViewController {
  _FakeWebViewController_0(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class _FakeTextEditingController_1 extends _i1.SmartFake
    implements _i3.TextEditingController {
  _FakeTextEditingController_1(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class _FakeMappedinWebView_2 extends _i1.SmartFake
    implements _i4.MappedinWebView {
  _FakeMappedinWebView_2(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);

  @override
  String toString({_i3.DiagnosticLevel? minLevel = _i3.DiagnosticLevel.info}) =>
      super.toString();
}

class _FakeBuildContext_3 extends _i1.SmartFake implements _i3.BuildContext {
  _FakeBuildContext_3(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class _FakeWidget_4 extends _i1.SmartFake implements _i3.Widget {
  _FakeWidget_4(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);

  @override
  String toString({_i3.DiagnosticLevel? minLevel = _i3.DiagnosticLevel.info}) =>
      super.toString();
}

class _FakeDiagnosticsNode_5 extends _i1.SmartFake
    implements _i3.DiagnosticsNode {
  _FakeDiagnosticsNode_5(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);

  @override
  String toString({
    _i5.TextTreeConfiguration? parentConfiguration,
    _i3.DiagnosticLevel? minLevel = _i3.DiagnosticLevel.info,
  }) => super.toString();
}

/// A class which mocks [MappedinWebViewState].
///
/// See the documentation for Mockito's code generation for more information.
class MockMappedinWebViewState extends _i1.Mock
    implements _i4.MappedinWebViewState {
  MockMappedinWebViewState() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.WebViewController get controller =>
      (super.noSuchMethod(
            Invocation.getter(#controller),
            returnValue: _FakeWebViewController_0(
              this,
              Invocation.getter(#controller),
            ),
          )
          as _i2.WebViewController);

  @override
  set controller(_i2.WebViewController? _controller) => super.noSuchMethod(
    Invocation.setter(#controller, _controller),
    returnValueForMissingStub: null,
  );

  @override
  _i3.TextEditingController get searchController =>
      (super.noSuchMethod(
            Invocation.getter(#searchController),
            returnValue: _FakeTextEditingController_1(
              this,
              Invocation.getter(#searchController),
            ),
          )
          as _i3.TextEditingController);

  @override
  String get statusMessage =>
      (super.noSuchMethod(
            Invocation.getter(#statusMessage),
            returnValue: _i6.dummyValue<String>(
              this,
              Invocation.getter(#statusMessage),
            ),
          )
          as String);

  @override
  set statusMessage(String? _statusMessage) => super.noSuchMethod(
    Invocation.setter(#statusMessage, _statusMessage),
    returnValueForMissingStub: null,
  );

  @override
  _i4.MappedinWebView get widget =>
      (super.noSuchMethod(
            Invocation.getter(#widget),
            returnValue: _FakeMappedinWebView_2(
              this,
              Invocation.getter(#widget),
            ),
          )
          as _i4.MappedinWebView);

  @override
  _i3.BuildContext get context =>
      (super.noSuchMethod(
            Invocation.getter(#context),
            returnValue: _FakeBuildContext_3(this, Invocation.getter(#context)),
          )
          as _i3.BuildContext);

  @override
  bool get mounted =>
      (super.noSuchMethod(Invocation.getter(#mounted), returnValue: false)
          as bool);

  @override
  void dispose() => super.noSuchMethod(
    Invocation.method(#dispose, []),
    returnValueForMissingStub: null,
  );

  @override
  void initState() => super.noSuchMethod(
    Invocation.method(#initState, []),
    returnValueForMissingStub: null,
  );

  @override
  _i7.Future<void> reloadWithMapId(String? mapId) =>
      (super.noSuchMethod(
            Invocation.method(#reloadWithMapId, [mapId]),
            returnValue: _i7.Future<void>.value(),
            returnValueForMissingStub: _i7.Future<void>.value(),
          )
          as _i7.Future<void>);

  @override
  _i7.Future<void> loadHtmlFromAssets() =>
      (super.noSuchMethod(
            Invocation.method(#loadHtmlFromAssets, []),
            returnValue: _i7.Future<void>.value(),
            returnValueForMissingStub: _i7.Future<void>.value(),
          )
          as _i7.Future<void>);

  @override
  _i7.Future<void> showDirections(
    String? departure,
    String? destination,
    bool? accessibility,
  ) =>
      (super.noSuchMethod(
            Invocation.method(#showDirections, [
              departure,
              destination,
              accessibility,
            ]),
            returnValue: _i7.Future<void>.value(),
            returnValueForMissingStub: _i7.Future<void>.value(),
          )
          as _i7.Future<void>);

  @override
  _i7.Future<void> setFloor(String? floorName) =>
      (super.noSuchMethod(
            Invocation.method(#setFloor, [floorName]),
            returnValue: _i7.Future<void>.value(),
            returnValueForMissingStub: _i7.Future<void>.value(),
          )
          as _i7.Future<void>);

  @override
  _i7.Future<void> navigateToRoom(String? roomNumber) =>
      (super.noSuchMethod(
            Invocation.method(#navigateToRoom, [roomNumber]),
            returnValue: _i7.Future<void>.value(),
            returnValueForMissingStub: _i7.Future<void>.value(),
          )
          as _i7.Future<void>);

  @override
  dynamic searchRoom(String? roomNumber) =>
      super.noSuchMethod(Invocation.method(#searchRoom, [roomNumber]));

  @override
  _i3.Widget build(_i3.BuildContext? context) =>
      (super.noSuchMethod(
            Invocation.method(#build, [context]),
            returnValue: _FakeWidget_4(
              this,
              Invocation.method(#build, [context]),
            ),
          )
          as _i3.Widget);

  @override
  void didUpdateWidget(_i4.MappedinWebView? oldWidget) => super.noSuchMethod(
    Invocation.method(#didUpdateWidget, [oldWidget]),
    returnValueForMissingStub: null,
  );

  @override
  void reassemble() => super.noSuchMethod(
    Invocation.method(#reassemble, []),
    returnValueForMissingStub: null,
  );

  @override
  void setState(_i8.VoidCallback? fn) => super.noSuchMethod(
    Invocation.method(#setState, [fn]),
    returnValueForMissingStub: null,
  );

  @override
  void deactivate() => super.noSuchMethod(
    Invocation.method(#deactivate, []),
    returnValueForMissingStub: null,
  );

  @override
  void activate() => super.noSuchMethod(
    Invocation.method(#activate, []),
    returnValueForMissingStub: null,
  );

  @override
  void didChangeDependencies() => super.noSuchMethod(
    Invocation.method(#didChangeDependencies, []),
    returnValueForMissingStub: null,
  );

  @override
  void debugFillProperties(_i9.DiagnosticPropertiesBuilder? properties) =>
      super.noSuchMethod(
        Invocation.method(#debugFillProperties, [properties]),
        returnValueForMissingStub: null,
      );

  @override
  String toString({_i3.DiagnosticLevel? minLevel = _i3.DiagnosticLevel.info}) =>
      super.toString();

  @override
  String toStringShort() =>
      (super.noSuchMethod(
            Invocation.method(#toStringShort, []),
            returnValue: _i6.dummyValue<String>(
              this,
              Invocation.method(#toStringShort, []),
            ),
          )
          as String);

  @override
  _i3.DiagnosticsNode toDiagnosticsNode({
    String? name,
    _i5.DiagnosticsTreeStyle? style,
  }) =>
      (super.noSuchMethod(
            Invocation.method(#toDiagnosticsNode, [], {
              #name: name,
              #style: style,
            }),
            returnValue: _FakeDiagnosticsNode_5(
              this,
              Invocation.method(#toDiagnosticsNode, [], {
                #name: name,
                #style: style,
              }),
            ),
          )
          as _i3.DiagnosticsNode);
}
