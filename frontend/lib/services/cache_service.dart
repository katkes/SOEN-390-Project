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

  /// Removes a specific event from the cache for a given calendar.
  /// This method is used to update the cache when an event is deleted.
  /// The event is identified by its unique ID.
  /// If the event is not found in the cache, no action is taken.
  /// ## Parameters:
  /// - [eventId]: The ID of the event to remove from cache.
  /// - [calendarId]: The ID of the calendar associated with the event.
  ///
  /// ## Returns:
  /// - A `Future<void>` indicating the completion of the operation.

  Future<void> removeEventFromCache(String eventId,
      {required String calendarId}) async {
    final cacheKey = _getCacheKey(calendarId);
    final eventList = _preferences.getStringList(cacheKey) ?? [];

    // Remove event from the list
    final updatedEventList = eventList
        .where((e) => Event.fromJson(jsonDecode(e)).id != eventId)
        .toList();

    // Store the updated list back to cache
    await _preferences.setStringList(cacheKey, updatedEventList);
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
