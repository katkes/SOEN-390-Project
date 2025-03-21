import 'package:googleapis/calendar/v3.dart';
import '../services/calendar_service.dart';
import '../services/cache_service.dart';

/// A repository class that manages calendar-related operations and caching.
///
/// This repository acts as an intermediary between [CalendarService] and [CacheService],
/// providing a higher-level interface to fetch and manage calendar events and calendar lists,
/// while applying a caching strategy for performance and offline access.
///
/// Events are cached **per calendar**, enabling fine-grained control over
/// event data for different calendars.
///
/// ## Constructor:
/// - Requires a [CalendarService] to handle API calls.
/// - Requires a [CacheService] to manage local storage.
///
/// ## Example:
/// ```dart
/// final repository = CalendarRepository(calendarService, cacheService);
///
/// // Get events from primary calendar with caching
/// final events = await repository.getEvents();
///
/// // Get events from a specific calendar without caching
/// final events = await repository.getEvents(calendarId: 'abc123@group.calendar.google.com', useCache: false);
/// ```
///
/// ## Methods:
/// - [getEvents] - Fetches events from a specified calendar, with optional caching.
/// - [getCalendars] - Retrieves the list of calendars available for the authenticated user.
///
/// See also:
/// * [CalendarService] - Handles direct API calls.
/// * [CacheService] - Manages cached calendar data using SharedPreferences.
class CalendarRepository {
  final CalendarService _calendarService;
  final CacheService _cacheService;

  CalendarRepository(this._calendarService, this._cacheService);

  /// Fetches a list of events from a specified calendar, with optional caching.
  ///
  /// ## Parameters:
  /// - [calendarId]: *(optional)* The ID of the calendar to fetch events from. Defaults to `'primary'`.
  /// - [useCache]: *(optional)* Whether to use cached data if available. Defaults to `true`.
  ///
  /// ## Returns:
  /// - A `List<Event>` from the calendar, either from cache or freshly fetched.
  ///
  /// Cached data is stored per calendar using the calendar ID as a key.
  Future<List<Event>> getEvents(calendarid,
      {String calendarId = 'primary', bool useCache = true}) async {
    if (useCache) {
      final cachedEvents =
          await _cacheService.getStoredEvents(calendarId: calendarId);
      if (cachedEvents.isNotEmpty) return cachedEvents;
    }

    final events = await _calendarService.fetchEvents(calendarId);
    if (events.isNotEmpty) {
      await _cacheService.storeEvents(events, calendarId: calendarId);
    }
    return events;
  }

  /// Fetches the list of calendars available for the authenticated user.
  ///
  /// ## Returns:
  /// - A `List<CalendarListEntry>` representing available calendars.
  Future<List<CalendarListEntry>> getCalendars() async {
    return await _calendarService.fetchCalendars();
  }
}
