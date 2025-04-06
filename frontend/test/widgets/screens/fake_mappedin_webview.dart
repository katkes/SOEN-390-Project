import 'package:flutter/material.dart';
import 'package:soen_390/widgets/mappedin_webview.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:soen_390/screens/indoor/mappedin_map_controller.dart';

class FakeMappedinMapController extends MappedinMapController {
  FakeMappedinMapController() : super();

  @override
  String get currentMapId => 'test-map-id';
}

class FakeMappedinWebView extends MappedinWebView {
  FakeMappedinWebView({super.key});

  @override
  FakeMappedinWebViewState createState() => FakeMappedinWebViewState();
}

class FakeMappedinWebViewState extends State<MappedinWebView>
    implements MappedinWebViewState {
  int showDirectionsCallCount = 0;
  int setFloorCallCount = 0;

  @override
  late WebViewController controller = WebViewController();

  @override
  late String statusMessage = '';

  @override
  Future<void> showDirections(String from, String to, bool accessible) async {
    showDirectionsCallCount++;
  }

  @override
  Future<void> setFloor(String floor) async {
    setFloorCallCount++;
  }

  @override
  Future<void> loadHtmlFromAssets() {
    return Future.value();
  }

  @override
  void searchRoom(String roomNumber) {}

  @override
  TextEditingController get searchController => TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  @override
  Future<void> navigateToRoom(String roomNumber) {
    // TODO: implement navigateToRoom
    throw UnimplementedError();
  }

  @override
  Future<void> reloadWithMapId(String mapId) {
    // TODO: implement reloadWithMapId
    throw UnimplementedError();
  }

  @override
  Future<bool> waitForMapLoaded() {
    // TODO: implement waitForMapLoaded
    throw UnimplementedError();
  }
}
