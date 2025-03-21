import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:googleapis/calendar/v3.dart';

/// A service class that manages caching of calendar events using SharedPreferences.
///
/// The [CacheService] provides functionality to store and retrieve calendar events
/// locally per calendar using the device's SharedPreferences storage. This allows the app to
/// maintain a local cache of events for offline access or performance optimization.
///
/// Caching is handled **per calendar** using dynamically generated keys based on
/// each calendar's ID, ensuring separation of cached data.
///
/// ## Constructor:
/// - Requires an instance of [SharedPreferences] for local storage.
/// - Requires a [CalendarApi] instance, though it's not directly used in caching.
///
/// ## Example usage:
/// ```dart
/// final cacheService = CacheService(sharedPreferences, calendarApi);
///
/// // Store events for a specific calendar
/// await cacheService.storeEvents(events, calendarId: 'primary');
///
/// // Retrieve cached events for a specific calendar
/// final events = await cacheService.getStoredEvents(calendarId: 'primary');
/// ```
///
/// ## Methods:
/// - [storeEvents] - Stores a list of events in cache for a given calendar ID.
/// - [getStoredEvents] - Retrieves cached events for a specific calendar ID.
class CacheService {
  final SharedPreferences _preferences;
  final CalendarApi calendarApi;

  CacheService(this._preferences, this.calendarApi);

  /// Stores events in cache for a specific calendar.
  ///
  /// ## Parameters:
  /// - [events]: List of `Event` objects to store.
  /// - [calendarId]: The ID of the calendar to associate with the cached events.
  Future<void> storeEvents(List<Event> events,
      {required String calendarId}) async {
    final eventList = events.map((e) => jsonEncode(e.toJson())).toList();
    final cacheKey = _getCacheKey(calendarId);
    await _preferences.setStringList(cacheKey, eventList);
  }

  /// Retrieves cached events for a specific calendar.
  ///
  /// ## Parameters:
  /// - [calendarId]: The ID of the calendar for which to retrieve cached events.
  ///
  /// ## Returns:
  /// - A `List<Event>` from cache, or an empty list if no cached data exists.
  Future<List<Event>> getStoredEvents({required String calendarId}) async {
    final cacheKey = _getCacheKey(calendarId);
    final eventList = _preferences.getStringList(cacheKey) ?? [];
    return eventList.map((e) => Event.fromJson(jsonDecode(e))).toList();
  }

  /// Generates a unique cache key per calendar based on the calendar ID.
  ///
  /// ## Parameters:
  /// - [calendarId]: The ID of the calendar to generate a cache key for.
  ///
  /// ## Returns:
  /// - A `String` key in the format `cached_events_<calendarId>`.
  String _getCacheKey(String calendarId) {
    return "cached_events_$calendarId";
  }
}
