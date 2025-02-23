import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  setUpAll(() async {
    await dotenv.load(fileName: ".env");
  });
  test("place search test with Google Places API", () async {
    final String apiKey =
        dotenv.env['GOOGLE_MAPS_API_KEY'] ?? 'API_KEY_NOT_FOUND';
    Building building = Building(
        latitude: 45.497092,
        longitude: -73.5788,
        locationName: "Henry F. Hall Building");
    MyBuildingsAPI api = MyBuildingsAPI();
    await api.getBuilding(building.latitude, building.longitude, apiKey);
    // print(buildings.first.name);
  });

  test("place details test with Google Places API", () async {
    final String apiKey =
        dotenv.env['GOOGLE_MAPS_API_KEY'] ?? 'API_KEY_NOT_FOUND';
    final String placeId = "ChIJN1t_tDeuEmsRUsoyG83frY4";
    MyBuildingsAPI api = MyBuildingsAPI();
    await api.getBuildingDetails(placeId, apiKey);
  });

  test("place photo test with Google Places API", () async {
    final String apiKey =
        dotenv.env['GOOGLE_MAPS_API_KEY'] ?? 'API_KEY_NOT_FOUND';
    final String photoRef =
        "AVzFdbmlwb9IkyAsgFyKaaQfD5GfGOt3IhEtRtzeDtjTOVGly7_K4PcG14VR2OaA8OWSNlm4CW77b2QivaX6yXDjttXg73ETwfIlwQkZLPNXWGawE-u2ZzIBnUmCtCDmTht2ocxJyjpFrYPy6W_OrDg4PoFL3h8ZpHPqPUzAclT4gPyv0KoMCdMZeo592NBLFgt297QMZmGfjID-mIP0R7FttS2i5sB9w9q-Bi1IHQ-kHp5d-ZpdDlByo1ndWMMMwCw2MnJLvESaDuKkbsCNiC_Hxm6LNyoPtUbdNiGT3y6xRVYovqzFStxvDus7NQt3jBJ6OVHfFwr28jQzKOi_BoblHGB92Ek45GhVAsPUHTDQO4lxsKLdYcD6YHJcRFArVoqdsFPNK_TWqUjw8-FlbKy_8oZW-a1wcYzbq-ooxML1Ek87";
    MyBuildingsAPI api = MyBuildingsAPI();
    await api.getBuildingPhoto(photoRef, apiKey);
  });
}

class MyBuildingsAPI {
  Future<List<Building>> getBuilding(
      double latitude, double longitude, String apiKey) async {
    var response = await http.get(Uri.parse(
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$apiKey"));
    print(response.body);
    return [];
  }

  Future<List<Building>> getBuildingDetails(
      String placeId, String apiKey) async {
    var response = await http.get(Uri.parse(
        "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey&fields=formatted_phone_number,website,rating,opening_hours,types,photos"));
    print(response.body);
    return [];
  }

  Future<List<Building>> getBuildingPhoto(
      String photoReference, String apiKey) async {
    var response = await http.get(Uri.parse(
        "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photo_reference=$photoReference&key=$apiKey"));
    print(response.body);
    return [];
  }
}

class Building {
  final double latitude;
  final double longitude;
  final String locationName;

  Building(
      {required this.latitude,
      required this.longitude,
      required this.locationName});

  double get getLatitude {
    return latitude;
  }

  double get getLongitude {
    return longitude;
  }

  String get getLocationName {
    return locationName;
  }
}
