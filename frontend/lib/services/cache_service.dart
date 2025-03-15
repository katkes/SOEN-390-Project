import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:googleapis/calendar/v3.dart';

/// A service class that manages caching of calendar events using SharedPreferences.
///
/// The [CacheService] provides functionality to store and retrieve calendar events
/// locally using the device's SharedPreferences storage. This allows the app to
/// maintain a local cache of events for offline access or performance optimization.
///
/// The service requires an instance of [SharedPreferences] and [CalendarApi] to be
/// injected through the constructor.
///
/// Example usage:
/// ```dart
/// final cacheService = CacheService(sharedPreferences, calendarApi);
/// await cacheService.storeEvents(events); // Store events in cache
/// final events = await cacheService.getStoredEvents(); // Retrieve cached events
/// ```
class CacheService {
  final SharedPreferences _preferences;
  final CalendarApi calendarApi;

  CacheService(this._preferences, this.calendarApi);

  Future<void> storeEvents(List<Event> events) async {
    final eventList = events.map((e) => jsonEncode(e.toJson())).toList();
    await _preferences.setStringList("cached_events", eventList);
  }

  Future<List<Event>> getStoredEvents() async {
    final eventList = _preferences.getStringList("cached_events") ?? [];
    return eventList.map((e) => Event.fromJson(jsonDecode(e))).toList();
  }
}
