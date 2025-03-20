import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MappedinWebView extends StatefulWidget {
  const MappedinWebView({super.key});

  @override
  MappedinWebViewState createState() => MappedinWebViewState();
}

class MappedinWebViewState extends State<MappedinWebView> {
  late final WebViewController _controller;
  Map<String, dynamic> _directions = {};

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted);

    _controller.addJavaScriptChannel(
      "Directions",
      onMessageReceived: (JavaScriptMessage message) {
        try {
          final Map<String, dynamic> msg = jsonDecode(message.message);
          if (msg['type'] == 'error') {
            // TODO Error handling with some ui element
            print(msg);
          } else {
            _directions = jsonDecode(message.message);
          }
        } catch (e) {
          debugPrint("Error parsing message: $e");
        }
      },
    );

    _controller.addJavaScriptChannel(
      "Floors",
      onMessageReceived: (JavaScriptMessage message) {
        try {
          final Map<String, dynamic> msg = jsonDecode(message.message);
          if (msg['type'] == 'error') {
            // TODO Error handling with some ui element
            print(msg);
          } else {
            print(msg);

          }
        } catch (e) {
          debugPrint("Error parsing message: $e");
        }
      },
    );

    _loadHtmlFromAssets();
  }

  Future<void> _loadHtmlFromAssets() async {
    final String fileHtmlContents =
        await rootBundle.loadString('assets/mappedin.html');
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
      fileHtmlContents,
      (prev, e) => prev.replaceAll(e.key, e.value),
    );
    _controller.loadHtmlString(fileHtmlWithKeys);
  }

  // Expose a method to run JavaScript.
  runJS(String jsCode) async {
    await _controller.runJavaScript(jsCode);
  }

  showDirections(String departure, String destination) async {
    await _controller
        .runJavaScript("getDirections('$departure', '$destination')");
    print(_directions);
  }

  setFloor(String floorName) async {
    await _controller.runJavaScript("setFloor('$floorName')");
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _controller);
  }
}
