/*
 *
 * This screen loads a local HTML file (assets/mappedin.html) that embeds a Mappedin map.
 * The HTML is loaded using rootBundle and then displayed in an InAppWebView.
 * WebView settings enable JavaScript and useHybridComposition (for Android).
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MappedinMapScreen extends StatefulWidget {
  const MappedinMapScreen({super.key});

  @override
  MappedinMapScreenState createState() => MappedinMapScreenState();
}

class MappedinMapScreenState extends State<MappedinMapScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    // Create and configure the WebView controller
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted);
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
      "67968294965a13000bcdfe74", //Library building for testing purpose, we need to make it so that we choose the building we want and it takes the building code for that specific building
    ];

    Map<String, String> keymap = Map.fromIterables(apiLabels, apiKeys);

    final fileHtmlWithKeys = keymap.entries
        .fold(fileHtmlContents, (prev, e) => prev.replaceAll(e.key, e.value));

    _controller.loadHtmlString(fileHtmlWithKeys);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inddor Navigation')),
      body: WebViewWidget(controller: _controller),
    );
  }
}
