import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class MappedinMapScreen extends StatefulWidget {
  @override
  MappedinMapScreenState createState() => MappedinMapScreenState();
}

class MappedinMapScreenState extends State<MappedinMapScreen> {
  InAppWebViewController? webViewController;
  bool _isMapLoaded = false;
  String _mapStatus = "Loading map...";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mappedin Map")),
      body: Stack(
        children: [
          InAppWebView(
            initialFile: "assets/mappedin.html",
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              // debugEnabled: true, // Helpful for troubleshooting
            ),
            onWebViewCreated: (controller) {
              webViewController = controller;

              // Register handlers for communication with JavaScript
              controller.addJavaScriptHandler(
                handlerName: 'mapLoaded',
                callback: (args) {
                  setState(() {
                    _isMapLoaded = true;
                    _mapStatus = args[0];
                  });
                  print("Map loaded: ${args[0]}");
                },
              );

              controller.addJavaScriptHandler(
                handlerName: 'mapError',
                callback: (args) {
                  setState(() {
                    _mapStatus = "Error: ${args[0]}";
                  });
                  print("Map error: ${args[0]}");
                },
              );
            },
            onLoadStop: (controller, url) {
              print("WebView loaded: $url");
            },
            onConsoleMessage: (controller, consoleMessage) {
              print("Console: ${consoleMessage.message}");
            },
          ),
          if (!_isMapLoaded)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(_mapStatus),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
