import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart'; 
import 'package:soen_390/services/http_service.dart';
import 'package:soen_390/services/google_route_service.dart';
import '../services/interfaces/route_service_interface.dart';
import 'package:soen_390/utils/location_service.dart';
import 'package:soen_390/services/building_to_coordinates.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';




/// Provides an instance of [GeolocatorPlatform].
final geolocatorProvider = Provider<GeolocatorPlatform>((ref) {
  return GeolocatorPlatform.instance;
});

/// Provides an instance of [LocationService].
final locationServiceProvider = Provider<LocationService>((ref) {
  final geolocator = ref.read(geolocatorProvider);
  return LocationService(geolocator: geolocator); //
});

/// Provides an instance of [HttpService] to manage HTTP requests.
final httpServiceProvider = Provider<HttpService>((ref) {
  return HttpService();
});

/// Provides an implementation of [IRouteService] using [GoogleRouteService].
///
/// This service is responsible for fetching routes via Google Maps API.
final routeServiceProvider = Provider<IRouteService>((ref) {
  final locationService = ref.read(locationServiceProvider);
  final httpService = ref.read(httpServiceProvider);

  return GoogleRouteService(
    locationService: locationService,
    httpService: httpService,
  );
});

final buildingToCoordinatesProvider = Provider<GeocodingService>((ref) {

  final apiKey = dotenv.env['GOOGLE_PLACES_API_KEY'];
  final httpService = ref.read(httpServiceProvider);

  return GeocodingService(
    httpService: httpService,
    apiKey: apiKey, // Pass the API key if available
  );

});

