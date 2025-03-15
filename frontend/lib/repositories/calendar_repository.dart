import 'package:googleapis/calendar/v3.dart';
import '../services/calendar_service.dart';
import '../services/cache_service.dart';

/// A repository class that manages calendar-related operations and caching.
///
/// This repository acts as an intermediary between the calendar service and cache service,
/// providing methods to fetch and manage calendar events and calendars while implementing
/// a caching strategy for better performance.
///
/// The repository uses [CalendarService] for fetching fresh data and [CacheService]
/// for storing and retrieving cached data.
///
/// Example:
/// ```dart
/// final repository = CalendarRepository(calendarService, cacheService);
/// final events = await repository.getEvents();
/// ```
///
/// See also:
///
/// * [CalendarService], which handles direct API calls for calendar operations
/// * [CacheService], which manages local storage of calendar data
class CalendarRepository {
  final CalendarService _calendarService;
  final CacheService _cacheService;

  CalendarRepository(this._calendarService, this._cacheService);

  Future<List<Event>> getEvents({bool useCache = true}) async {
    if (useCache) {
      final cachedEvents = await _cacheService.getStoredEvents();
      if (cachedEvents.isNotEmpty) return cachedEvents;
    }

    final events = await _calendarService.fetchEvents();
    if (events.isNotEmpty) {
      await _cacheService.storeEvents(events);
    }
    return events;
  }

  Future<List<CalendarListEntry>> getCalendars() async {
    return await _calendarService.fetchCalendars();
  }
}
