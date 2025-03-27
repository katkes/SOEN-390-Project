import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soen_390/models/route_result.dart';
import 'package:soen_390/screens/waypoint/waypoint_selection_screens.dart';
import 'package:soen_390/providers/service_providers.dart';

/// A handler class responsible for opening the waypoint selection screen
/// and managing the result of a route selection.
///
/// This class is used to encapsulate the logic for navigating to the
/// [WaypointSelectionScreen], initializing its required services from
/// Riverpod providers, and returning the selected route (if any) back to
/// the previous screen.
///
/// Useful in contexts like navigation planning, route previews, or any
/// feature that allows users to pick waypoints and destinations.
///
/// Example usage:
/// ```dart
/// final handler = WaypointNavigationHandler(
///   context: context,
///   buildingName: "Hall Building",
///   buildingAddress: "1455 De Maisonneuve Blvd W",
///   onRouteSelected: (route) {
///     // Handle selected route
///   },
/// );
/// await handler.openWaypointSelection();
/// ```
class WaypointNavigationHandler {
  /// The current Flutter [BuildContext], required for navigation and provider access.
  final BuildContext context;

  /// The name of the building (used in the destination string).
  final String buildingName;

  /// The address of the building (used in the destination string).
  final String buildingAddress;

  /// Optional callback triggered when a route is selected from the waypoint screen.
  final void Function(RouteResult)? onRouteSelected;

  /// Creates a [WaypointNavigationHandler] instance.
  ///
  /// Parameters:
  /// - [context]: Required for navigation and reading Riverpod providers.
  /// - [buildingName]: The name of the target building.
  /// - [buildingAddress]: The full address of the building.
  /// - [onRouteSelected]: A callback that will be executed if a route is chosen.
  WaypointNavigationHandler({
    required this.context,
    required this.buildingName,
    required this.buildingAddress,
    this.onRouteSelected,
  });

  /// Opens the waypoint selection screen and awaits the user's route selection.
  ///
  /// This method:
  /// - Reads the required services from the current [ProviderScope] using Riverpod.
  /// - Constructs a full destination string from [buildingName] and [buildingAddress].
  /// - Navigates to the [WaypointSelectionScreen], passing the necessary services.
  /// - Waits for a [RouteResult] to be returned.
  /// - Calls [onRouteSelected] with the selected route (if one is returned).
  /// - Pops the current context with the selected route.
  ///
  /// Returns:
  /// - A [Future] that completes once the waypoint selection screen is closed.
  Future<void> openWaypointSelection() async {
    final container = ProviderScope.containerOf(context);
    final routeService = container.read(routeServiceProvider);
    final locationService = container.read(locationServiceProvider);
    final buildingToCoordinatesService =
        container.read(buildingToCoordinatesProvider);
    final campusRouteChecker = container.read(campusRouteCheckerProvider);
    final waypointValidator = container.read(waypointValidatorProvider);

    final sentDestination =
        "$buildingName, $buildingAddress, Montreal, Quebec, Canada";

    final RouteResult? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WaypointSelectionScreen(
          routeService: routeService,
          geocodingService: buildingToCoordinatesService,
          locationService: locationService,
          initialDestination: sentDestination,
          campusRouteChecker: campusRouteChecker,
          waypointValidator: waypointValidator,
        ),
      ),
    );

    if (result != null && context.mounted) {
      onRouteSelected?.call(result);
      Navigator.pop(context, result);
    }
  }
}
