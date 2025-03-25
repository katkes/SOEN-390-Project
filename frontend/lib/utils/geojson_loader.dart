// geojson_loader.dart
import 'dart:convert';
import 'package:flutter/services.dart';

class GeoJsonLoader {
  final AssetBundle assetBundle;

  GeoJsonLoader({AssetBundle? bundle}) : assetBundle = bundle ?? rootBundle;

  Future<Map<String, dynamic>> load(String path) async {
    final jsonString = await assetBundle.loadString(path);
    return jsonDecode(jsonString);
  }
}
