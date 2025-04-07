// Mocks generated by Mockito 5.4.5 from annotations
// in soen_390/test/widgets/screens/calendar/event_edit_popup_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i5;

import 'package:flutter/material.dart' as _i3;
import 'package:googleapis/calendar/v3.dart' as _i6;
import 'package:mockito/mockito.dart' as _i1;
import 'package:soen_390/repositories/calendar_repository.dart' as _i2;
import 'package:soen_390/screens/calendar/calendar_event_service.dart' as _i7;
import 'package:soen_390/screens/indoor/mappedin_map_controller.dart' as _i8;
import 'package:soen_390/services/calendar_service.dart' as _i4;
import 'package:soen_390/widgets/mappedin_webview.dart' as _i9;

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

class _FakeCalendarRepository_0 extends _i1.SmartFake
    implements _i2.CalendarRepository {
  _FakeCalendarRepository_0(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

class _FakeGlobalKey_1<T extends _i3.State<_i3.StatefulWidget>>
    extends _i1.SmartFake implements _i3.GlobalKey<T> {
  _FakeGlobalKey_1(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

/// A class which mocks [CalendarService].
///
/// See the documentation for Mockito's code generation for more information.
class MockCalendarService extends _i1.Mock implements _i4.CalendarService {
  MockCalendarService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i5.Future<List<_i6.Event>> fetchEvents([String? calendarId = 'primary']) =>
      (super.noSuchMethod(
        Invocation.method(#fetchEvents, [calendarId]),
        returnValue: _i5.Future<List<_i6.Event>>.value(<_i6.Event>[]),
      ) as _i5.Future<List<_i6.Event>>);

  @override
  _i5.Future<List<_i6.CalendarListEntry>> fetchCalendars() =>
      (super.noSuchMethod(
        Invocation.method(#fetchCalendars, []),
        returnValue: _i5.Future<List<_i6.CalendarListEntry>>.value(
          <_i6.CalendarListEntry>[],
        ),
      ) as _i5.Future<List<_i6.CalendarListEntry>>);

  @override
  _i5.Future<_i6.Event?> createEvent(String? calendarId, _i6.Event? event) =>
      (super.noSuchMethod(
        Invocation.method(#createEvent, [calendarId, event]),
        returnValue: _i5.Future<_i6.Event?>.value(),
      ) as _i5.Future<_i6.Event?>);

  @override
  _i5.Future<_i6.Event?> updateEvent(
    String? calendarId,
    String? eventId,
    _i6.Event? updatedEvent,
  ) =>
      (super.noSuchMethod(
        Invocation.method(#updateEvent, [
          calendarId,
          eventId,
          updatedEvent,
        ]),
        returnValue: _i5.Future<_i6.Event?>.value(),
      ) as _i5.Future<_i6.Event?>);

  @override
  _i5.Future<void> deleteEvent(String? calendarId, String? eventId) =>
      (super.noSuchMethod(
        Invocation.method(#deleteEvent, [calendarId, eventId]),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);
}

/// A class which mocks [CalendarEventService].
///
/// See the documentation for Mockito's code generation for more information.
class MockCalendarEventService extends _i1.Mock
    implements _i7.CalendarEventService {
  MockCalendarEventService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.CalendarRepository get calendarRepository => (super.noSuchMethod(
        Invocation.getter(#calendarRepository),
        returnValue: _FakeCalendarRepository_0(
          this,
          Invocation.getter(#calendarRepository),
        ),
      ) as _i2.CalendarRepository);

  @override
  _i5.Future<Map<DateTime, List<_i6.Event>>> fetchCalendarEvents(
    String? calendarId, {
    bool? useCache = true,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #fetchCalendarEvents,
          [calendarId],
          {#useCache: useCache},
        ),
        returnValue: _i5.Future<Map<DateTime, List<_i6.Event>>>.value(
          <DateTime, List<_i6.Event>>{},
        ),
      ) as _i5.Future<Map<DateTime, List<_i6.Event>>>);

  @override
  List<_i6.Event> getEventsForDay(
    DateTime? day,
    Map<DateTime, List<_i6.Event>>? eventsByDay,
  ) =>
      (super.noSuchMethod(
        Invocation.method(#getEventsForDay, [day, eventsByDay]),
        returnValue: <_i6.Event>[],
      ) as List<_i6.Event>);

  @override
  _i5.Future<List<_i6.CalendarListEntry>> fetchCalendars() =>
      (super.noSuchMethod(
        Invocation.method(#fetchCalendars, []),
        returnValue: _i5.Future<List<_i6.CalendarListEntry>>.value(
          <_i6.CalendarListEntry>[],
        ),
      ) as _i5.Future<List<_i6.CalendarListEntry>>);

  @override
  _i5.Future<void> deleteEventFromCache(String? eventId, String? calendarId) =>
      (super.noSuchMethod(
        Invocation.method(#deleteEventFromCache, [eventId, calendarId]),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);
}

/// A class which mocks [MappedinMapController].
///
/// See the documentation for Mockito's code generation for more information.
class MockMappedinMapController extends _i1.Mock
    implements _i8.MappedinMapController {
  MockMappedinMapController() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.GlobalKey<_i9.MappedinWebViewState> get webViewKey => (super.noSuchMethod(
        Invocation.getter(#webViewKey),
        returnValue: _FakeGlobalKey_1<_i9.MappedinWebViewState>(
          this,
          Invocation.getter(#webViewKey),
        ),
      ) as _i3.GlobalKey<_i9.MappedinWebViewState>);

  @override
  set webViewKey(_i3.GlobalKey<_i9.MappedinWebViewState>? _webViewKey) =>
      super.noSuchMethod(
        Invocation.setter(#webViewKey, _webViewKey),
        returnValueForMissingStub: null,
      );

  @override
  _i5.Future<void> waitForWebViewReady() => (super.noSuchMethod(
        Invocation.method(#waitForWebViewReady, []),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<bool> selectBuildingByName(String? buildingName) =>
      (super.noSuchMethod(
        Invocation.method(#selectBuildingByName, [buildingName]),
        returnValue: _i5.Future<bool>.value(false),
      ) as _i5.Future<bool>);

  @override
  _i5.Future<bool> selectBuildingById(String? mapId) => (super.noSuchMethod(
        Invocation.method(#selectBuildingById, [mapId]),
        returnValue: _i5.Future<bool>.value(false),
      ) as _i5.Future<bool>);

  @override
  bool setMapId(String? mapId) => (super.noSuchMethod(
        Invocation.method(#setMapId, [mapId]),
        returnValue: false,
      ) as bool);

  @override
  _i5.Future<bool> navigateToRoom(String? roomNumber, bool reverse) =>
      (super.noSuchMethod(
        Invocation.method(#navigateToRoom, [roomNumber]),
        returnValue: _i5.Future<bool>.value(false),
      ) as _i5.Future<bool>);
}
