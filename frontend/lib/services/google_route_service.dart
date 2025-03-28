import 'dart:async';
import 'package:latlong2/latlong.dart';
import 'package:soen_390/models/route_query_options.dart';
import 'package:soen_390/models/route_result.dart';
import 'package:soen_390/services/interfaces/base_google_service.dart';
import 'package:soen_390/utils/google_directions_url_builder.dart';
import 'package:soen_390/utils/location_service.dart';
import 'package:soen_390/utils/route_result_parser.dart';
import 'interfaces/route_service_interface.dart';

/// A service to retrieve routes from the Google Maps Directions API.
///
/// This class allows fetching multiple routes for different transportation modes
/// (driving, walking, bicycling, transit) and enables live navigation with rerouting.
class GoogleRouteService extends BaseGoogleService implements IRouteService {
  /// Stores the selected route for live navigation.
  RouteResult? _selectedRoute;

  /// Handles device location tracking and permissions.
  final LocationService locationService;
  // Handles the URL building
  final GoogleDirectionsUrlBuilder urlBuilder;
  //handles the parsing
  final RouteResultParser parser;

  /// Creates a new instance of `GoogleRouteService`.
  ///
  /// - [locationService]: Manages location tracking.
  /// - [httpClient]: Handles HTTP requests.
  /// - [apiKey]: Optional API key for requests. Defaults to the value in `..env`.
  ///
  /// Throws an exception if the API key is missing.
  GoogleRouteService({
    required this.locationService,
    required this.urlBuilder,
    required this.parser, // <-- new
    required super.httpClient,
    super.apiHelper,
    super.apiKey,
  });

  /// Fetches the best driving route between two locations.
  ///
  /// - [from]: The starting location as `LatLng`.
  /// - [to]: The destination location as `LatLng`.
  ///
  /// Returns a `RouteResult` containing distance, duration, and route points.
  /// Returns `null` if no route is found.
  @override
  Future<RouteResult?> getRoute({
    required LatLng from,
    required LatLng to,
  }) async {
    final List<RouteResult>? routes = await _fetchRoute(
        RouteQueryOptions(from: from, to: to, mode: 'driving'));
    if (routes == null || routes.isEmpty) return null;
    return routes.first;
  }

  /// Retrieves multiple route options for different transport modes.
  ///
  /// - [from]: The starting location as `LatLng`.
  /// - [to]: The destination location as `LatLng`.
  /// - [departureTime]: (Optional) Departure time for transit routes.
  /// - [arrivalTime]: (Optional) Desired arrival time for transit routes.
  ///
  /// Returns a map where keys are transport modes (`driving`, `walking`, etc.)
  /// and values are lists of `RouteResult` options for that mode.
  @override
  Future<Map<String, List<RouteResult>>> getRoutes({
    required LatLng from,
    required LatLng to,
    DateTime? departureTime,
    DateTime? arrivalTime,
  }) async {
    Map<String, List<RouteResult>> routes = {};
    List<String> transportModes = [
      'driving',
      'walking',
      'bicycling',
      'transit'
    ];

    for (String mode in transportModes) {
      final List<RouteResult>? results = await _fetchRoute(RouteQueryOptions(
        from: from,
        to: to,
        mode: mode,
        departureTime: departureTime,
        arrivalTime: arrivalTime,
        alternatives: true,
      ));

      if (results != null) {
        routes[mode] = results;
      }
    }

    return routes;
  }

  /// Fetches routes from Google Maps API.
  ///
  /// - [from]: The starting location as `LatLng`.
  /// - [to]: The destination location as `LatLng`.
  /// - [mode]: The transportation mode (`driving`, `walking`, `bicycling`, `transit`).
  /// - [departureTime]: (Optional) Departure time for transit routes.
  /// - [arrivalTime]: (Optional) Desired arrival time for transit routes.
  /// - [alternatives]: If `true`, fetches alternative routes.
  ///
  /// Returns a list of `RouteResult` containing multiple possible routes.
  Future<List<RouteResult>?> _fetchRoute(RouteQueryOptions options) async {
    final url = urlBuilder.buildRequestUrl(options);

    try {
      final data = await apiHelper.fetchJson(httpClient, Uri.parse(url));
      return parser.parseRouteResults(data);
    } catch (e) {
      print("Exception during route fetch: $e");
      return null;
    }
  }

  /// Allows the UI to select a route from the retrieved options.
  ///
  /// - [routes]: A list of available `RouteResult` options.
  /// - [index]: The index of the chosen route.
  ///
  /// Returns the selected `RouteResult`, or `null` if the index is invalid.
  @override
  RouteResult? selectRoute(List<RouteResult> routes, int index) {
    if (routes.isEmpty) {
      print("ERROR: No routes available.");
      return null;
    }
    if (index < 0 || index >= routes.length) {
      print("ERROR: Invalid route index selected.");
      return null;
    }
    _selectedRoute = routes[index];
    print("Route ${index + 1} selected.");
    return _selectedRoute;
  }

  @override
  Future<List<RouteResult>?> getRoutesFromOptions(RouteQueryOptions options) {
    return _fetchRoute(options);
  }
}
