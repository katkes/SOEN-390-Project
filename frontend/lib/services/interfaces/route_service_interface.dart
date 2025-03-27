import 'package:latlong2/latlong.dart';
import 'package:soen_390/models/route_query_options.dart';
import 'package:soen_390/models/route_result.dart';

/// An abstract class that defines the contract for a routing service.
///
/// This abstraction enables easy switching between different routing providers,
/// such as Google Maps, Mapbox, or OSRM, without modifying existing logic.
abstract class IRouteService {
  /// Retrieves a route between the specified [from] and [to] locations.
  ///
  /// Returns a [RouteResult] containing distance, duration, and route points
  /// or `null` if no route could be determined.
  Future<RouteResult?> getRoute({
    required LatLng from,
    required LatLng to,
  });
  Future<Map<String, List<RouteResult>>> getRoutes({
    required LatLng from,
    required LatLng to,
    DateTime? departureTime,
    DateTime? arrivalTime,
  });

  RouteResult? selectRoute(List<RouteResult> routes, int index);

  Future<List<RouteResult>?> getRoutesFromOptions(RouteQueryOptions options);
}
