import 'dart:convert';
import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:soen_390/utils/location_service.dart';
import 'package:soen_390/services/http_service.dart';
import 'interfaces/route_service_interface.dart';

/// A service to retrieve routes from the Google Maps Directions API.
///
/// This class allows fetching multiple routes for different transportation modes
/// (driving, walking, bicycling, transit) and enables live navigation with rerouting.
class GoogleRouteService implements IRouteService {
  /// Stores the selected route for live navigation.
  RouteResult? _selectedRoute;

  /// The Google Maps API Key used for requests.
  final String apiKey;

  /// Handles device location tracking and permissions.
  final LocationService locationService;

  /// A wrapper around the HTTP client for making requests.
  final HttpService httpService;

  /// Creates a new instance of `GoogleRouteService`.
  ///
  /// - [locationService]: Manages location tracking.
  /// - [httpService]: Handles HTTP requests.
  /// - [apiKey]: Optional API key for requests. Defaults to the value in `..env`.
  ///
  /// Throws an exception if the API key is missing.
  GoogleRouteService({
    required this.locationService,
    required this.httpService,
    String? apiKey, // Allow passing an API key for testing
  }) : apiKey = apiKey ?? dotenv.env['GOOGLE_MAPS_API_KEY'] ?? "" {
    if (this.apiKey.isEmpty) {
      throw Exception(
          "ERROR: Missing Google Maps API Key! Provide one or check your ..env file.");
    }
  }

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
    final List<RouteResult>? routes =
        await _fetchRoute(from: from, to: to, mode: 'driving');
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
      final List<RouteResult>? results = await _fetchRoute(
        from: from,
        to: to,
        mode: mode,
        departureTime: departureTime,
        arrivalTime: arrivalTime,
        alternatives: true,
      );
      if (results != null) {
        routes[mode] = results;
      }
    }

    return routes;
  }

  /// Checks if a route between two locations is inter-campus.
  ///
  /// A route is considered inter-campus if it starts at Loyola (LOY) and ends at St. George's West (SGW),
  /// or vice versa, but not necessarily passing through both.
  ///
  /// - [from]: The starting location of the route.
  /// - [to]: The ending location of the route.
  ///
  /// Returns True if the route is inter-campus, false otherwise.
  static bool isRouteInterCampus({
    required LatLng from,
    required LatLng to,
  }) {
    final fromSGW = LocationService.checkIfPositionIsAtSGW(from);
    final fromLOY = LocationService.checkIfPositionIsAtLOY(from);

    final toSGW = LocationService.checkIfPositionIsAtSGW(to);
    final toLOY = LocationService.checkIfPositionIsAtLOY(to);

    if ((fromLOY && toSGW) || (fromSGW && toLOY)) {
      return true;
    }
    return false;
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
  Future<List<RouteResult>?> _fetchRoute({
    required LatLng from,
    required LatLng to,
    required String mode,
    DateTime? departureTime,
    DateTime? arrivalTime,
    bool alternatives = false,
  }) async {
    final url = _buildRequestUrl(
      from: from,
      to: to,
      mode: mode,
      departureTime: departureTime,
      arrivalTime: arrivalTime,
      alternatives: alternatives,
    );

    final response = await httpService.client.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return _processApiResponse(response.body);
    }
    return null;
  }

  /// Builds a Google Maps Directions API request URL with the specified parameters.
  ///
  /// - [from]: Starting location coordinates.
  /// - [to]: Destination location coordinates.
  /// - [mode]: Transportation mode such as `driving`, `walking`, `bicycling`, or `transit`.
  /// - [departureTime]: Optional departure time for transit directions.
  ///   Only applied for non-walking modes.
  /// - [arrivalTime]: Optional arrival time for transit directions.
  ///   Only applied for transit mode.
  /// - [alternatives]: Whether to request alternative routes.
  ///
  /// Returns a properly formatted URL string for the Google Maps Directions API.
  String _buildRequestUrl({
    required LatLng from,
    required LatLng to,
    required String mode,
    DateTime? departureTime,
    DateTime? arrivalTime,
    bool alternatives = false,
  }) {
    String url = "https://maps.googleapis.com/maps/api/directions/json?"
        "origin=${from.latitude},${from.longitude}"
        "&destination=${to.latitude},${to.longitude}"
        "&mode=$mode"
        "&key=$apiKey";

    if (alternatives) {
      url += "&alternatives=true";
    }

    if (departureTime != null && mode != "walking") {
      url += "&departure_time=${departureTime.millisecondsSinceEpoch ~/ 1000}";
    } else if (arrivalTime != null && mode == "transit") {
      url += "&arrival_time=${arrivalTime.millisecondsSinceEpoch ~/ 1000}";
    }

    return url;
  }

  /// Processes the Google Maps Directions API response JSON.
  ///
  /// This function handles parsing the response body, validating it contains
  /// expected data, and transforming it into RouteResult objects.
  ///
  /// - [responseBody]: The raw JSON response string from the Directions API.
  ///
  /// Returns a list of RouteResult objects if successful, or null if:
  /// - The response contains no routes
  /// - The API returned a non-OK status
  ///
  /// Logs detailed error information when route retrieval fails.
  List<RouteResult>? _processApiResponse(String responseBody) {
    final data = jsonDecode(responseBody);
  
    if (!data.containsKey('routes') || data['routes'].isEmpty) {
      print(" No routes found. Full API Response: ${jsonEncode(data)}");
      return null;
    }
  
    if (data['status'] != 'OK') {
      print(
          "API Error: ${data['status']} - Full Response: ${jsonEncode(data)}");
      return null;
    }

    return _extractRouteResults(data);
  }

  /// Extracts and transforms route data from parsed API response.
  ///
  /// This function takes the parsed JSON data from the Google Maps Directions API
  /// and transforms it into a list of RouteResult objects containing information about
  /// each possible route.
  ///
  /// - [data]: The parsed JSON data from the Directions API response.
  ///
  /// For each route in the response:
  /// - Extracts distance and duration values
  /// - Decodes polyline points for map display
  /// - Processes navigation steps using _extractSteps
  ///
  /// Returns a list of RouteResult objects representing each possible route.
  List<RouteResult> _extractRouteResults(Map<String, dynamic> data) {
    List<RouteResult> results = [];
  
    for (var route in data['routes']) {
      for (var leg in route['legs']) {
        final distance = leg['distance']['value'].toDouble();
        final duration = leg['duration']['value'].toDouble();
        final polylinePoints = route.containsKey('overview_polyline')
            ? _decodePolyline(route['overview_polyline']['points'])
            : <LatLng>[];

        List<StepResult> steps = _extractSteps(leg['steps']);

        results.add(RouteResult(
          distance: distance,
          duration: duration,
          routePoints: polylinePoints,
          steps: steps,
        ));
      }
    }
  
    return results;
  }

  /// Allows the UI to select a route from the retrieved options.
  ///
  /// - [routes]: A list of available `RouteResult` options.
  /// - [index]: The index of the chosen route.
  ///
  /// Returns the selected `RouteResult`, or `null` if the index is invalid.
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

  /// Starts live navigation with dynamic rerouting.
  ///
  /// - [to]: The destination `LatLng`.
  /// - [mode]: The selected transport mode.
  /// - [onUpdate]: Callback that provides updated route information when rerouted.
  ///
  /// This function continuously checks the user's position. If they go off-route,
  /// it recalculates the best path.
  Future<void> startLiveNavigation({
    required LatLng to,
    required String mode,
    required Function(RouteResult) onUpdate,
  }) async {
    if (_selectedRoute == null) {
      print("ERROR: No route selected! Call `selectRoute()` first.");
      return;
    }

    // Check if location services are enabled BEFORE starting navigation
    final isLocationEnabled = await locationService.isLocationEnabled();

    if (!isLocationEnabled) {
      print("ERROR: Location services are disabled. Cannot start navigation.");
      return;
    }

    RouteResult route = _selectedRoute!;
    locationService.createLocationStream();

    locationService.getPositionStream().listen((Position position) async {
      LatLng newUserLocation = LatLng(position.latitude, position.longitude);

      if (!_isUserOnRoute(newUserLocation, route.routePoints)) {
        print("User off route! Recalculating...");
        RouteResult? updatedRoute = await _fetchRoute(
          from: newUserLocation,
          to: to,
          mode: mode,
        ).then((value) =>
            (value != null && value.isNotEmpty) ? value.first : null);

        if (updatedRoute != null) {
          route = updatedRoute;
          onUpdate(updatedRoute);
        }
      } else {
        onUpdate(route);
      }
    });
  }

  List<StepResult> _extractSteps(List<dynamic> stepsData) {
    List<StepResult> steps = [];

    for (var step in stepsData) {
      steps.add(StepResult(
        distance: step['distance']['value'].toDouble(),
        duration: step['duration']['value'].toDouble(),
        instruction: step['html_instructions'] ?? "No instruction available",
        maneuver: step.containsKey('maneuver') ? step['maneuver'] : "unknown",
        startLocation: LatLng(
            step['start_location']['lat'], step['start_location']['lng']),
        endLocation:
            LatLng(step['end_location']['lat'], step['end_location']['lng']),
      ));
    }
    return steps;
  }

  /// Decodes a Google Maps polyline string into a list of `LatLng` points.
  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    if (encoded.isEmpty) return points;

    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

  /// Checks if the user is still following the route.
  bool _isUserOnRoute(LatLng userLocation, List<LatLng> routePoints) {
    const double deviationThreshold = 30;
    return routePoints.any((point) =>
        Geolocator.distanceBetween(userLocation.latitude,
            userLocation.longitude, point.latitude, point.longitude) <
        deviationThreshold);
  }
}
