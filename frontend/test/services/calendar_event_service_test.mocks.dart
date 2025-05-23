// Mocks generated by Mockito 5.4.5 from annotations
// in soen_390/test/services/calendar_event_service_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i3;

import 'package:googleapis/calendar/v3.dart' as _i4;
import 'package:mockito/mockito.dart' as _i1;
import 'package:soen_390/repositories/calendar_repository.dart' as _i2;

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

/// A class which mocks [CalendarRepository].
///
/// See the documentation for Mockito's code generation for more information.
class MockCalendarRepository extends _i1.Mock
    implements _i2.CalendarRepository {
  MockCalendarRepository() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.Future<List<_i4.Event>> getEvents({
    String? calendarId = 'primary',
    bool? useCache = true,
  }) =>
      (super.noSuchMethod(
        Invocation.method(#getEvents, [], {
          #calendarId: calendarId,
          #useCache: useCache,
        }),
        returnValue: _i3.Future<List<_i4.Event>>.value(<_i4.Event>[]),
      ) as _i3.Future<List<_i4.Event>>);

  @override
  _i3.Future<void> removeEventFromCache(String? eventId, String? calendarId) =>
      (super.noSuchMethod(
        Invocation.method(#removeEventFromCache, [eventId, calendarId]),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);

  @override
  _i3.Future<List<_i4.CalendarListEntry>> getCalendars() => (super.noSuchMethod(
        Invocation.method(#getCalendars, []),
        returnValue: _i3.Future<List<_i4.CalendarListEntry>>.value(
          <_i4.CalendarListEntry>[],
        ),
      ) as _i3.Future<List<_i4.CalendarListEntry>>);
}
