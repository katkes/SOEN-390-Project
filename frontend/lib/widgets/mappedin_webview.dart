/// A Flutter widget that embeds a custom WebView for displaying and interacting
/// with Mappedin indoor maps using local HTML/JS assets.
///
/// This widget sets up two-way communication between Dart and JavaScript via
/// channels for directions and floor selection. It dynamically loads and injects
/// API keys into the HTML before rendering. Useful for integrating interactive
/// indoor navigation features within a Flutter app.
///
/// Channels:
/// - `Directions`: Receives directions or error messages from JS.
/// - `Floors`: Receives floor change events or errors from JS.
///
/// Usage:
///   await _webViewKey.currentState?.showDirections("124", "817");
///   await _webViewKey.currentState?.setFloor("Floor 2");
library;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import "package:soen_390/screens/indoor_accessibility/indoor_accessibility_preference.dart";
import "package:soen_390/providers/theme_provider.dart";

class MappedinWebView extends StatefulWidget {
  /// Optional controller override for testing.
  final WebViewController? controllerOverride;

  final String? mapId;
  const MappedinWebView({
    super.key,
    this.controllerOverride,
    this.mapId,
  });

  @override
  MappedinWebViewState createState() => MappedinWebViewState();
}

class MappedinWebViewState extends State<MappedinWebView> {
  late final WebViewController controller;
  final TextEditingController searchController =
      TextEditingController(); // Add this line
  String statusMessage = "Nothing";
  String? _currentMapId;

  @override
  void dispose() {
    searchController
        .dispose(); // Dispose the controller to prevent memory leaks
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _currentMapId = widget.mapId;
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted);

    /// Registers a JavaScript channel to receive direction updates from the WebView.
    ///
    /// - Channel name: `"DirectionsChannel"`
    /// - Receives: A JSON string with the following structure:
    ///   {
    ///     "type": "success" | "error",
    ///     "payload": String | { "message": String }
    ///   }
    /// - Updates the [statusMessage] based on success or error.
    controller.addJavaScriptChannel(
      "DirectionsChannel",
      onMessageReceived: (JavaScriptMessage message) {
        try {
          final Map<String, dynamic> msg = jsonDecode(message.message);
          if (msg['type'] == 'error') {
            setState(() {
              statusMessage = "Directions Error: ${msg['payload']['message']}";
            });
          } else {
            setState(() {
              statusMessage = "Directions: ${msg['payload']}";
            });
          }
        } catch (e) {
          debugPrint("Error parsing Directions message: $e");
          setState(() {
            statusMessage = "Error parsing directions response";
          });
        }
      },
    );

    /// Registers a JavaScript channel to receive floor selection events from the WebView.
    ///
    /// - Channel name: `"FloorsChannel"`
    /// - Receives: A JSON string with the following structure:
    ///   {
    ///     "type": "success" | "error",
    ///     "payload": { "floorName": String } | { "message": String }
    ///   }
    /// - Updates the [statusMessage] to reflect the current floor or error.
    controller.addJavaScriptChannel(
      "FloorsChannel",
      onMessageReceived: (JavaScriptMessage message) {
        try {
          final Map<String, dynamic> msg = jsonDecode(message.message);
          if (msg['type'] == 'error') {
            setState(() {
              statusMessage = "Floor Error: ${msg['payload']['message']}";
            });
          } else {
            setState(() {
              statusMessage = "Floor changed to ${msg['payload']['floorName']}";
            });
          }
        } catch (e) {
          debugPrint("Error parsing Floors message: $e");
          setState(() {
            statusMessage = "Error parsing floor response";
          });
        }
      },
    );
    loadHtmlFromAssets();
  }

  /// Reloads the WebView with a new map ID
  Future<void> reloadWithMapId(String mapId) async {
    setState(() {
      _currentMapId = mapId;
    });
    await loadHtmlFromAssets();
  }

  /// Loads the HTML file into the WebView and injects JavaScript code and API keys.
  ///
  /// Throws an exception if:
  /// - Required assets cannot be loaded
  /// - Environment variables are missing
  /// - API keys cannot be injected
  Future<void> loadHtmlFromAssets() async {
    try {
      final fileHtmlContents =
          await rootBundle.loadString('assets/mappedin.html');
      final fileJsContents = await rootBundle.loadString('assets/mappedin.js');

      if (fileHtmlContents.isEmpty || fileJsContents.isEmpty) {
        throw Exception('Failed to load required assets');
      }

      final combinedHtml = fileHtmlContents.replaceFirst(
        'JAVASCRIPTCODE',
        fileJsContents,
      );

      // Validate environment variables
      final apiKey = dotenv.env['MAPPEDIN_API_KEY'];
      final apiSecret = dotenv.env['MAPPEDIN_API_SECRET'];
      final defaultMapId = '67968294965a13000bcdfe74';
    
      final mapId = _currentMapId ?? widget.mapId ?? defaultMapId;

      if (apiKey == null || apiSecret == null) {
        throw Exception('Missing required environment variables');
      }

      final keymap = {
        'MAPPEDIN_API_KEY': apiKey,
        'MAPPEDIN_API_SECRET': apiSecret,
        'MAPPEDIN_API_MAP_ID': mapId,
      };

      final fileHtmlWithKeys = keymap.entries.fold(
        combinedHtml,
        (prev, e) => prev.replaceAll(e.key, e.value),
      );

      await controller.loadHtmlString(fileHtmlWithKeys);
    } catch (e) {
      debugPrint('Error loading HTML assets: $e');
    }
  }

  /// Sends a request to the embedded JavaScript to generate directions.
  ///
  /// - [departure]: The starting location name.
  /// - [destination]: The destination location name.
  /// - [accessibility]: If the route should be accessible (currently unused).
  Future<void> showDirections(
      String departure, String destination, bool accessibility) async {
    try {
      final preference =
          await IndoorAccessibilityState.getMobilityStatusPreference();
      await controller.runJavaScript(
          "getDirections('$departure', '$destination', '$preference')");
    } catch (e) {
      debugPrint('Error showing directions: $e');
      setState(() {
        statusMessage = 'Failed to show directions: $e';
      });
    }
  }

  /// Sends a request to the embedded JavaScript to change the visible floor.
  ///
  /// - [floorName]: The name of the floor to switch to.
  Future<void> setFloor(String floorName) async {
    try {
      await controller.runJavaScript("setFloor('$floorName')");
    } catch (e) {
      debugPrint('Error setting floor: $e');
      setState(() {
        statusMessage = 'Failed to change floor: $e';
      });
    }
  }

  /// Navigates to a specific room on the map
  ///
  /// - [roomNumber]: The room number to navigate to (e.g., "907")
  Future<void> navigateToRoom(String roomNumber) async {
    try {
      await showDirections("Entrance", roomNumber, false);
    } catch (e) {
      debugPrint('Error navigating to room: $e');
      setState(() {
        statusMessage = 'Failed to navigate to room: $e';
      });
    }
  }

  /// Calls JavaScript function to highlight a room
  searchRoom(String roomNumber) {
    controller.runJavaScript("search('$roomNumber')");
    controller.runJavaScript("setCameraTo('$roomNumber')");
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// Search Bar for Room Numbers
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: "Search room number",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            onSubmitted: (value) {
              if (value.isNotEmpty) {
                searchRoom(value);
              }
            },
          ),
        ),

        /// The Mappedin WebView
        Expanded(
          child: WebViewWidget(controller: controller),
        ),
      ],
    );

    // return WebViewWidget(controller: controller);
  }
}
