import 'package:flutter/material.dart';
import 'package:soen_390/utils/route_utils.dart';
import 'package:soen_390/services/interfaces/route_service_interface.dart';

void displayRoutes({
  required BuildContext context,
  required List<Map<String, dynamic>> confirmedRoutes,
  required Function(List<Map<String, dynamic>>) updateRoutes,
  required List<String> waypoints,
  required List<RouteResult> routes,
  required String transportMode,
}) {
  final newRoutes = routes.map((route) {
    return {
      "title":
          "${shortenAddress(waypoints.first)} to ${shortenAddress(waypoints.last)}",
      "timeRange": formatTimeRange(route.duration),
      "duration": formatDuration(route.duration),
      "description":
          waypoints.map((waypoint) => shortenAddress(waypoint)).join(" → "),
      "icons": getIconsForTransport(transportMode),
      "routeData": route,
    };
  }).toList();

  updateRoutes(newRoutes);
}
