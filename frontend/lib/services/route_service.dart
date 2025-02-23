import 'package:latlong2/latlong.dart';
import 'package:osrm/osrm.dart';

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
  final osrm = Osrm();
  final options = RouteRequest(
    coordinates: [
      (from.longitude, from.latitude),
      (to.longitude, to.latitude),
    ],
    overview: OsrmOverview.full,
  );
  final route = await osrm.route(options);
  if (route.routes.isNotEmpty) {
    final distance = route.routes.first.distance?.toDouble() ?? 0.0;
    final duration = route.routes.first.duration?.toDouble() ?? 0.0;
    final routePoints =
        route.routes.first.geometry?.lineString?.coordinates.map((e) {
              final loc = e.toLocation();
              return LatLng(loc.lat, loc.lng);
            }).toList() ??
            [];
    return RouteResult(
        distance: distance, duration: duration, routePoints: routePoints);
  }
  return null;
}
