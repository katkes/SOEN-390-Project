import 'package:soen_390/models/route_result.dart';

/// A simple in-memory caching utility for storing and retrieving route results
/// based on travel mode and unique route keys.
///
/// This class helps reduce unnecessary API calls by reusing previously fetched
/// route data.
///
/// Routes are cached using a two-level key structure:
/// - First-level key: the travel mode (e.g., "walking", "transit")
/// - Second-level key: a unique identifier for the route query (e.g., origin→destination)
///
/// Example usage:
/// ```dart
/// final cache = RouteCacheManager();
/// final key = "45.5,-73.6→45.4,-73.7";
///
/// if (cache.hasCached("walking", key)) {
///   final cachedRoutes = cache.getCached("walking", key);
/// } else {
///   cache.setCache("walking", key, newRoutes);
/// }
/// ```
class RouteCacheManager {
  /// Internal cache map organized by [mode] and a custom [key] per route.
  ///
  /// Structure: `{ mode: { key: List<RouteResult> } }`
  final Map<String, Map<String, List<RouteResult>>> _cache = {};

  /// Checks if the cache contains a route for the given [mode] and [key].
  ///
  /// Returns `true` if cached routes exist, `false` otherwise.
  bool hasCached(String mode, String key) =>
      _cache.containsKey(mode) && _cache[mode]!.containsKey(key);

  /// Retrieves cached routes for the given [mode] and [key], if available.
  ///
  /// Returns:
  /// - A `List<RouteResult>` if found in cache.
  /// - `null` if no cached result exists for the given key.
  List<RouteResult>? getCached(String mode, String key) => _cache[mode]?[key];

  /// Stores a list of [routes] in the cache under the given [mode] and [key].
  ///
  /// If the [mode] does not yet exist in the cache, it will be created.
  void setCache(String mode, String key, List<RouteResult> routes) {
    _cache.putIfAbsent(mode, () => {})[key] = routes;
  }

  /// Clears all entries in the route cache.
  void clear() => _cache.clear();
}
