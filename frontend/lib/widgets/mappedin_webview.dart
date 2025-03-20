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
  late final WebViewController _controller;
  String statusMessage = "Nothing";

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted);

    // Directions Channel
    _controller.addJavaScriptChannel(
      "Directions",
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

    // Floor selection Channel
    _controller.addJavaScriptChannel(
      "Floors",
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

    _loadHtmlFromAssets();
  }

  Future<void> _loadHtmlFromAssets() async {
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

    void printLargeString(String text, {int chunkSize = 1000}) {
      for (int i = 0; i < text.length; i += chunkSize) {
        print(text.substring(
            i, i + chunkSize > text.length ? text.length : i + chunkSize));
      }
    }

    printLargeString(fileHtmlWithKeys);

    _controller.loadHtmlString(fileHtmlWithKeys);
  }

  showDirections(String departure, String destination) async {
    await _controller
        .runJavaScript("getDirections('$departure', '$destination')");
  }

  setFloor(String floorName) async {
    await _controller.runJavaScript("setFloor('$floorName')");
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: WebViewWidget(controller: _controller)),
        // Display the current status message
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(statusMessage, key: const Key('statusText')),
        ),
      ],
    );
  }
}
