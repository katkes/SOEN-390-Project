import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:soen_390/models/route_result.dart';
import 'package:soen_390/screens/indoor/mappedin_map_screen.dart';
import 'package:soen_390/screens/waypoint/waypoint_selection_screens.dart';
import 'package:soen_390/screens/indoor/mappedin_map_controller.dart';
import 'package:soen_390/providers/service_providers.dart';
import 'package:soen_390/providers/navigation_provider.dart';

class NavigationUtils {
  /// Opens the Waypoint Selection Screen and handles the result.
  static Future<void> openWaypointSelection(
      {required BuildContext context,
      required WidgetRef ref,
      required Function(List<LatLng>) onRouteSelected,
      required bool inMain}) async {
    final buildingToCoordinatesService =
        ref.watch(buildingToCoordinatesProvider);
    final locationService = ref.watch(locationServiceProvider);
    final routeService = ref.watch(routeServiceProvider);
    final campusRouteChecker = ref.watch(campusRouteCheckerProvider);
    final waypointValidator = ref.watch(waypointValidatorProvider);
    final routeCacheManager = ref.watch(routeCacheManagerProvider);

    final RouteResult selectedRouteData = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WaypointSelectionScreen(
          routeService: routeService,
          geocodingService: buildingToCoordinatesService,
          locationService: locationService,
          campusRouteChecker: campusRouteChecker,
          waypointValidator: waypointValidator,
          routeCacheManager: routeCacheManager,
        ),
      ),
    );

    onRouteSelected(selectedRouteData.routePoints);

    if (!inMain) {
      ref.read(navigationProvider.notifier).setSelectedIndex(1);
    }
  }

  /// Opens the Mappedin Map Screen and optionally navigates to a building or room.
  static Future<void> openMappedinMap({
    required BuildContext context,
    required MappedinMapController mappedinController,
    String? buildingName,
    String? roomName,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    bool success = true;

    if (buildingName != null) {
      success = await mappedinController.selectBuildingByName(buildingName);
      if (!success) {
        messenger.showSnackBar(
          SnackBar(content: Text('Failed to switch to $buildingName Building')),
        );
        return;
      }
    }

    if (roomName != null) {
      success = await mappedinController.navigateToRoom(roomName);
      if (!success) {
        messenger.showSnackBar(
          SnackBar(content: Text('Failed to navigate to $roomName')),
        );
        return;
      }
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MappedinMapScreen(
          controller: mappedinController,
        ),
      ),
    );
  }
}
