import 'package:soen_390/services/interfaces/maps_api_client.dart';

class BuildingPopUps {
  final MapsApiClient mapsApiClient;

  BuildingPopUps({required this.mapsApiClient});

  Future<Map<String, dynamic>> fetchBuildingInformation(
      double latitude, double longitude, String locationName) {
    return mapsApiClient.fetchBuildingInformation(
        latitude, longitude, locationName);
  }
}
