import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class MappedinMapScreen extends StatefulWidget {
  const MappedinMapScreen({Key? key}) : super(key: key);

  @override
  MappedinMapScreenState createState() => MappedinMapScreenState();
}

class _MappedinMapScreenState extends State<MappedinMapScreen> {
  String? _htmlData;

  @override
  void initState() {
    super.initState();
    _loadLocalHtml();
  }

  Future<void> _loadLocalHtml() async {
    final data = await rootBundle.loadString('assets/mappedin.html');
    setState(() {
      _htmlData = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mappedin Map")),
      body: _htmlData == null
          ? const Center(child: CircularProgressIndicator())
          : InAppWebView(
              initialData: InAppWebViewInitialData(
                data: _htmlData!,
                mimeType: "text/html",
                encoding: "utf-8",
              ),
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                useHybridComposition: true,
              ),
            ),
    );
  }
}
