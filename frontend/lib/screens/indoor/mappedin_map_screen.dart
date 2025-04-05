import 'package:flutter/material.dart';
import 'package:soen_390/widgets/mappedin_webview.dart';

class MappedinMapController {
  final GlobalKey<MappedinWebViewState> webViewKey =
      GlobalKey<MappedinWebViewState>();
  String? _currentMapId;

  String? get currentMapId => _currentMapId;

  Future<bool> switchBuilding(String mapId) async {
    try {
      _currentMapId = mapId;
      await webViewKey.currentState?.reloadWithMapId(mapId);
      return true;
    } catch (e) {
      debugPrint('Error switching building: $e');
      return false;
    }
  }
}

class MappedinMapScreen extends StatefulWidget {
  const MappedinMapScreen({super.key});

  @override
  State<MappedinMapScreen> createState() => _MappedinMapScreenState();
}

class _MappedinMapScreenState extends State<MappedinMapScreen> {
  final MappedinMapController _controller = MappedinMapController();
  String? _selectedBuilding;

  final Map<String, String> buildingMapIds = {
    "Hall Building": "67968294965a13000bcdfe74",
    "JMSB": "67e1ac8eaa7c59000baf8dcf",
    "Library Building": "67ba2570a39568000bc4b334",
  };

  @override
  void initState() {
    super.initState();
    _selectedBuilding = "Hall Building";
    final defaultMapId = buildingMapIds[_selectedBuilding]!;
    _controller.switchBuilding(defaultMapId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Indoor Navigation',
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xff912338),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          DropdownButton<String>(
            hint: const Text("Select Building",
                style: TextStyle(color: Colors.white)),
            value: _selectedBuilding,
            dropdownColor: Colors.black,
            style: const TextStyle(color: Colors.white),
            underline: Container(),
            iconEnabledColor: Colors.white,
            onChanged: (String? buildingName) async {
              if (buildingName != null) {
                setState(() => _selectedBuilding = buildingName);
                final mapId = buildingMapIds[buildingName]!;
                await _controller.switchBuilding(mapId);
              }
            },
            items: buildingMapIds.keys.map((name) {
              return DropdownMenuItem<String>(
                value: name,
                child: Text(name),
              );
            }).toList(),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: MappedinWebView(
        key: _controller.webViewKey,
      ),
    );
  }
}
