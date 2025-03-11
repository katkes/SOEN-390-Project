import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:googleapis/calendar/v3.dart';

class CacheService {
  final SharedPreferences _preferences;

  CacheService(this._preferences);

  Future<void> storeEvents(List<Event> events) async {
    final eventList = events.map((e) => jsonEncode(e.toJson())).toList();
    await _preferences.setStringList("cached_events", eventList);
  }

  Future<List<Event>> getStoredEvents() async {
    final eventList = _preferences.getStringList("cached_events") ?? [];
    return eventList.map((e) => Event.fromJson(jsonDecode(e))).toList();
  }
}
