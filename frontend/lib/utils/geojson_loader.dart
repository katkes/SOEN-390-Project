import 'dart:convert';
import 'package:flutter/services.dart';

/// A utility class responsible for loading and decoding GeoJSON files
/// from the app's asset bundle.
///
/// This loader abstracts the process of reading JSON-encoded files
/// and converting them into usable Dart objects.
///
/// Example:
/// ```dart
/// final loader = GeoJsonLoader();
/// final data = await loader.load('assets/geojson_files/my_map.geojson');
/// ```
class GeoJsonLoader {
  /// The asset bundle used to load files. Defaults to [rootBundle] if none is provided.
  final AssetBundle assetBundle;

  /// Creates a [GeoJsonLoader] with an optional custom [AssetBundle].
  GeoJsonLoader({AssetBundle? bundle}) : assetBundle = bundle ?? rootBundle;

  /// Loads a JSON file from the specified [path] and decodes it into a [Map].
  ///
  /// Returns a `Future<Map<String, dynamic>>` containing the parsed JSON.
  ///
  /// Throws a [FlutterError] if the asset is not found or can't be loaded.
  Future<Map<String, dynamic>> load(String path) async {
    final jsonString = await assetBundle.loadString(path);
    return jsonDecode(jsonString);
  }
}
