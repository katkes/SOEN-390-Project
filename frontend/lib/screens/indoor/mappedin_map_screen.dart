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
import "package:soen_390/screens/indoor_accessibility/indoor_accessibility_preference.dart";


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
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            _sendBooleanToJS();
          },
        ),
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
      "67968294965a13000bcdfe74", //Library building for testing purpose, we need to make it so that we choose the building we want and it takes the building code for that specific building
    ];

    Map<String, String> keymap = Map.fromIterables(apiLabels, apiKeys);

    final fileHtmlWithKeys = keymap.entries
        .fold(fileHtmlContents, (prev, e) => prev.replaceAll(e.key, e.value));

    _controller.loadHtmlString(fileHtmlWithKeys);
  }

  //this function is necessary to send the preference boolean value to JS for
  //mappedIN indoor navigation
  void _sendBooleanToJS() async {
    bool myBoolean = await IndoorAccessibilityState.getMobilityStatusPreference();
    await _controller.runJavaScript("receiveSharedPreferenceForMobilityImpairment($myBoolean);");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Indoor Navigation',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xff912338),
        iconTheme: const IconThemeData(color: Colors.white),
        actions:[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8), // Adjust padding as needed
            child: SizedBox(
              height: 40, // Control button height
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const IndoorAccessibilityPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, // White button for contrast
                  foregroundColor: const Color(0xff912338), // Text color
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Rounded edges
                  ),
                ),
                child: const Text(
                  'Specify Disability',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
          children: [
            Expanded(
              child: WebViewWidget(controller: _controller),
            ),
          ])
    );
  }



}//end of state class
