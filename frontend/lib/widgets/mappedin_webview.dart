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

class MappedinWebView extends StatefulWidget {
  /// Optional controller override for testing.
  final WebViewController? controllerOverride;
  const MappedinWebView({super.key, this.controllerOverride});

  @override
  MappedinWebViewState createState() => MappedinWebViewState();
}

class MappedinWebViewState extends State<MappedinWebView> {
  late final WebViewController controller;
  String statusMessage = "Nothing";

  @override
  void initState() {
    super.initState();
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
        }
      },
    );

    loadHtmlFromAssets();
  }

  /// Loads the html file into the weview. It also inserts the js file into html and replaces the
  /// labels with secrets from the .env file
  Future<void> loadHtmlFromAssets() async {
    final fileHtmlContents =
        await rootBundle.loadString('assets/mappedin.html');
    final fileJsContents = await rootBundle.loadString('assets/mappedin.js');
    final combinedHtml = fileHtmlContents.replaceFirst(
      'JAVASCRIPTCODE',
      fileJsContents,
    );
    List<String> apiLabels = [
      "MAPPEDIN_API_KEY",
      "MAPPEDIN_API_SECRET",
      "MAPPEDIN_API_MAP_ID",
    ];
    List<String> apiKeys = [
      dotenv.env['MAPPEDIN_API_KEY'] ?? "",
      dotenv.env['MAPPEDIN_API_SECRET'] ?? "",
      "67968294965a13000bcdfe74",
    ];
    Map<String, String> keymap = Map.fromIterables(apiLabels, apiKeys);
    final fileHtmlWithKeys = keymap.entries.fold(
      combinedHtml,
      (prev, e) => prev.replaceAll(e.key, e.value),
    );

    controller.loadHtmlString(fileHtmlWithKeys);
  }

  /// Sends a request to the embedded JavaScript to generate directions.
  ///
  /// - [departure]: The starting location name.
  /// - [destination]: The destination location name.
  /// - [accessible]: If the route should be accessible.
  showDirections(String departure, String destination, bool accessible) async {
    await controller.runJavaScript(
        "getDirections('$departure', '$destination', '$accessible')");
  }

  /// Sends a request to the embedded JavaScript to change the visible floor.
  ///
  /// - [floorName]: The name of the floor to switch to.
  setFloor(String floorName) async {
    await controller.runJavaScript("setFloor('$floorName')");
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: controller);
  }
}
