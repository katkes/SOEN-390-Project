import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([http.Client])
import 'building_retrieval_test.mocks.dart';

void main() async {
  group('Testing MyBuildingsAPI', () {
    final client = MockClient();

    test('testing place search request', () async {
      MyBuildingsAPI service = MyBuildingsAPI();
      when(client.get(
              Uri.parse("https://maps.googleapis.com/maps/api/geocode/json")))
          .thenAnswer((_) async =>
              http.Response('{"placeId": 1, "name": "test"}', 200));

      expect(await service.getBuilding(), isA<Map<String, dynamic>>());
    });

    test('testing place details request', () async {
      MyBuildingsAPI service = MyBuildingsAPI();
      when(client.get(Uri.parse(
              "https://maps.googleapis.com/maps/api/place/details/json")))
          .thenAnswer((_) async => http.Response(
              '{"name": "test", "phone": "403-555-1234", "website": "www.test.com", "rating": 4.5, "opening_hours": "9am-5pm", "types": ["restaurant", "cafe"]}',
              200));

      expect(await service.getBuildingDetails(), isA<Map<String, dynamic>>());
    });

    test('testing place photo request', () async {
      MyBuildingsAPI service = MyBuildingsAPI();
      when(client.get(
              Uri.parse("https://maps.googleapis.com/maps/api/place/photo")))
          .thenAnswer(
              (_) async => http.Response('{"photo": "photoTestUrl"}', 200));

      expect(await service.getBuildingDetails(), isA<Map<String, dynamic>>());
    });
  });
}

class MyBuildingsAPI {
  Future<Map<String, dynamic>> getBuilding() async {
    var response = await http
        .get(Uri.parse("https://maps.googleapis.com/maps/api/geocode/json"));
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> getBuildingDetails() async {
    var response = await http.get(
        Uri.parse("https://maps.googleapis.com/maps/api/place/details/json"));
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> getBuildingPhoto() async {
    var response = await http
        .get(Uri.parse("https://maps.googleapis.com/maps/api/place/photo"));
    return jsonDecode(response.body);
  }
}
