import 'package:latlong2/latlong.dart';
import 'package:osrm/osrm.dart';

// This file contains the logic to calculate a route between two points using the OSRM API.
// Just give it two LatLng points and it will return the distance, duration and the route points.

// This class is used to store the result of a route calculation.
class RouteResult {
  final double distance;
  final double duration;
  final List<LatLng> routePoints;

  RouteResult({
    required this.distance,
    required this.duration,
    required this.routePoints,
  });
}

Future<RouteResult?> getRouteFromCoordinates({
  required LatLng from,
  required LatLng to,
}) async {
  final osrm = Osrm(); // Osrm client to interact with the API
  final options = RouteRequest(
    coordinates: [
      (from.longitude, from.latitude),
      (to.longitude, to.latitude),
    ],
    profile: OsrmRequestProfile.foot, // Walking profile
    overview: OsrmOverview.full,
  );

  final route = await osrm.route(options);
  final firstRoute = route.routes.first;
  final distance = firstRoute.distance?.toDouble() ?? 0.0;
  final duration = firstRoute.duration?.toDouble() ?? 0.0;

  // Ensure geometry exists before processing
  final routePoints =
      route.routes.first.geometry?.lineString?.coordinates.map((e) {
            final loc = e.toLocation();
            return LatLng(loc.lat, loc.lng);
          }).toList() ??
          [];

  return RouteResult(
    distance: distance,
    duration: duration,
    routePoints: routePoints,
  );
}
