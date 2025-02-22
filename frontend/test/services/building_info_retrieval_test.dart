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
}

class MyBuildingsAPI {
  Future<List<Building>> getBuilding(
      double latitude, double longitude, String apiKey) async {
    var response = await http.get(Uri.parse(
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$apiKey"));
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
