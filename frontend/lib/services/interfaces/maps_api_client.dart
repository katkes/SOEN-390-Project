abstract class MapsApiClient {
  Future<Map<String, dynamic>> fetchBuildingInformation(
    double latitude,
    double longitude,
    String locationName,
  );

  Future<Map<String, dynamic>> fetchPlaceDetailsById(String placeId);
}
