// This file provides a simple way to work with indoor maps in the app.
// It handles showing buildings, navigating to rooms, and managing the map screen.
// Use this service whenever you need to work with the Mappedin indoor maps.
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:soen_390/screens/indoor/mappedin_map_screen.dart';
import 'package:soen_390/screens/indoor/mappedin_map_controller.dart';

/// A service that helps you work with the Mappedin indoor maps.
///
/// This service makes it easy to:
/// 1. Open the indoor map screen
/// 2. Navigate to specific rooms
/// 3. Show different buildings
/// 4. Handle errors with user-friendly messages
///
/// How to use this service:
/// 1. Create a MappedinMapController first
/// 2. Create this service with that controller
/// 3. Use the service methods to interact with the map
///
/// Example:
/// ```dart
/// // Create the controller
/// final controller = MappedinMapController();
///
/// // Create the service
/// final navigationService = MappedinNavigationService(controller);
///
/// // Use the service to show a building
/// await navigationService.showBuilding(context, 'Hall Building');
///
/// // Or navigate to a room
/// await navigationService.navigateToRoom(context, 'H-937');
/// ```
class MappedinNavigationService {
  final MappedinMapController _controller;

  MappedinNavigationService(this._controller);

  /// Opens the indoor map screen and waits for it to be ready to use.
  Future<void> openMapScreen(BuildContext context) async {
    final completer = Completer<void>();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MappedinMapScreen(
          controller: _controller,
          onWebViewReady: () {
            if (!completer.isCompleted) {
              completer.complete();
            }
          },
        ),
      ),
    );

    // Wait for the WebView to be ready to send directions
    return completer.future;
  }

  /// Opens the map and navigates to a specific room.
  ///
  /// This method:
  /// 1. Opens the map screen
  /// 2. Waits for the map to be ready
  /// 3. Navigates to the specified room
  ///
  /// Returns true if navigation was successful, false if there was an error.
  ///
  /// Example:
  /// ```dart
  /// final success = await navigationService.navigateToRoom(context, 'H-937');
  /// if (success) {
  ///   print('Successfully navigated to the room');
  /// }
  /// ```
  Future<bool> navigateToRoom(BuildContext context, String roomNumber) async {
    try {
      // First open the map screen and wait for it to be ready
      await openMapScreen(context);
      // Then navigate to the room
      return await _controller.navigateToRoom(roomNumber);
    } catch (e) {
      debugPrint('Error navigating to room: $e');
      return false;
    }
  }

  /// Shows a specific building on the map and opens the map screen.
  ///
  /// This method:
  /// 1. Tries to switch to the specified building
  /// 2. Opens the map screen if successful
  /// 3. Shows an error message if something goes wrong
  ///
  /// Returns true if successful, false if there was an error.
  ///
  /// Example:
  /// ```dart
  /// final success = await navigationService.showBuilding(context, 'Hall Building');
  /// if (success) {
  ///   print('Successfully showed the building');
  /// }
  /// ```
  Future<bool> showBuilding(BuildContext context, String buildingName) async {
    try {
      final success = await _controller.selectBuildingByName(buildingName);
      if (!success) {
        _showErrorMessage(
            context, 'Failed to switch to $buildingName Building');
        return false;
      }
      await openMapScreen(context);
      return true;
    } catch (e) {
      _showErrorMessage(context, 'Error showing building: $e');
      return false;
    }
  }

  /// Shows an error message at the bottom of the screen.
  /// This is used internally by the service to show user-friendly error messages.
  void _showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
