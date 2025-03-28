import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:soen_390/models/route_result.dart';
import 'package:soen_390/services/geocoding_service.dart';
import 'package:soen_390/services/google_route_service.dart';
import 'package:soen_390/utils/campus_route_checker.dart';
import 'package:soen_390/utils/location_service.dart';
import 'package:soen_390/utils/route_display.dart' as display;
import 'package:soen_390/utils/route_cache_manager.dart';

/// A service class responsible for fetching, caching, and displaying
/// route data based on user-selected waypoints and transport mode.
///
/// [RouteFetcher] handles the full flow of:
/// - Resolving coordinates from user inputs
/// - Fetching directions from [GoogleRouteService]
/// - Validating and caching route data
/// - Detecting cross-campus travel
/// - Displaying the final route in the UI
///
/// It can optionally override the destination coordinates (e.g., for navigation
/// triggered by tapping a campus card or map marker).
class RouteFetcher {
  /// Service used to fetch Google Directions routes.
  final GoogleRouteService routeService;

  /// Service used to geocode waypoint strings into coordinates.
  final GeocodingService geocodingService;

  /// Service used to get the user's current location.
  final LocationService locationService;

  /// Utility that detects if a route spans both SGW and Loyola campuses.
  final CampusRouteChecker campusRouteChecker;

  /// Build context, used for displaying routes.
  final BuildContext context;

  /// Optional latitude override for destination (e.g., passed from map).
  final double? overrideDestLat;

  /// Optional longitude override for destination.
  final double? overrideDestLng;

  /// Callback to update the routes on screen or in state.
  final void Function(List<Map<String, dynamic>>) updateRoutes;

  /// Callback to indicate whether the route crosses campuses.
  final void Function(bool) setCrossCampus;

  /// In-memory cache for storing previously fetched routes.
  final RouteCacheManager cacheManager;

  /// Creates a [RouteFetcher] with all necessary dependencies.
  RouteFetcher({
    required this.routeService,
    required this.geocodingService,
    required this.locationService,
    required this.campusRouteChecker,
    required this.context,
    required this.updateRoutes,
    required this.setCrossCampus,
    required this.cacheManager,
    this.overrideDestLat,
    this.overrideDestLng,
  });

  /// Fetches a route between the first and last waypoint using the selected [googleTransportMode].
  ///
  /// Parameters:
  /// - [waypoints]: A list of location names. The first is the start, the last is the destination.
  /// - [googleTransportMode]: The Google-supported travel mode (`walking`, `driving`, etc.).
  /// - [transportMode]: The app-specific or UI-facing transport mode string.
  ///
  /// Returns:
  /// - A list of up to 4 top-ranked [RouteResult]s if successful, or `null` if resolution fails.
  ///
  /// Throws:
  /// - [Exception] if coordinates cannot be resolved or no routes are found.
  Future<List<RouteResult>?> fetchRoutes(
    List<String> waypoints,
    String googleTransportMode,
    String transportMode,
  ) async {
    final coordinates = await _resolveCoordinates(waypoints);
    if (coordinates == null) return null;

    final start = coordinates['start']!;
    final end = coordinates['end']!;

    final routes = await routeService.getRoutes(from: start, to: end);

    setCrossCampus(campusRouteChecker.isInterCampus(from: start, to: end));

    _validateRoutes(routes, googleTransportMode);

    final topRoutes =
        _processAndCacheRoutes(routes, googleTransportMode, waypoints);

    return topRoutes;
  }

  /// Displays the fetched [routes] visually using the `RouteDisplay` utility.
  ///
  /// Parameters:
  /// - [waypoints]: The original input strings used for labeling.
  /// - [routes]: The list of [RouteResult]s to display.
  /// - [transportMode]: The display-friendly transport mode string.
  void displayRoutes(
    List<String> waypoints,
    List<RouteResult> routes,
    String transportMode,
  ) {
    display.displayRoutes(
      context: context,
      updateRoutes: updateRoutes,
      waypoints: waypoints,
      routes: routes,
      transportMode: transportMode,
    );

    print("Final confirmed route: $waypoints, Mode: $transportMode");
    print(
        "Route details: ${routes.first.distance} meters, ${routes.first.duration} seconds");
  }

  // Private helper methods

  /// Resolves the start and end coordinates based on the provided [waypoints].
  ///
  /// Uses current location if the start is "Your Location", and geocodes otherwise.
  /// If destination overrides are set, they take precedence.
  ///
  /// Returns:
  /// - A map containing 'start' and 'end' [LatLng] coordinates, or throws if resolution fails.
  Future<Map<String, LatLng>?> _resolveCoordinates(
      List<String> waypoints) async {
    LatLng? startPoint;

    if (waypoints.first == 'Your Location') {
      try {
        final position = await locationService.getCurrentLocation();
        startPoint = LatLng(position.latitude, position.longitude);
      } catch (e) {
        throw Exception("Failed to fetch current location: $e");
      }
    } else {
      startPoint = await geocodingService.getCoordinates(waypoints.first);
    }

    LatLng? endPoint;

    if (overrideDestLat != null && overrideDestLng != null) {
      endPoint = LatLng(overrideDestLat!, overrideDestLng!);
    } else {
      endPoint = await geocodingService.getCoordinates(waypoints.last);
    }

    if (startPoint == null || endPoint == null) {
      throw Exception("Failed to resolve coordinates.");
    }

    return {'start': startPoint, 'end': endPoint};
  }

  /// Validates whether [routes] contains usable data for the selected [googleTransportMode].
  ///
  /// Throws:
  /// - [Exception] if no route results exist for the given mode.
  void _validateRoutes(
    Map<String, List<RouteResult>> routes,
    String googleTransportMode,
  ) {
    if (routes.isEmpty ||
        !routes.containsKey(googleTransportMode) ||
        routes[googleTransportMode]!.isEmpty) {
      throw Exception("No routes found for $googleTransportMode");
    }
  }

  /// Selects and caches the top route results for the given [waypoints] and mode.
  ///
  /// Stores the results in [cacheManager] using a key formed from the start and end labels.
  ///
  /// Returns:
  /// - A list of up to 4 top [RouteResult]s.
  List<RouteResult> _processAndCacheRoutes(
    Map<String, List<RouteResult>> routes,
    String googleTransportMode,
    List<String> waypoints,
  ) {
    final selectedRoutes = routes[googleTransportMode]!;
    final topRoutes = selectedRoutes.take(4).toList();

    final waypointKey = "${waypoints.first}-${waypoints.last}";
    cacheManager.setCache(googleTransportMode, waypointKey, selectedRoutes);

    return topRoutes;
  }
}
