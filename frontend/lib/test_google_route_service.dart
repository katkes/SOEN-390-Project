import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:soen_390/utils/location_service.dart';
import 'package:soen_390/services/http_service.dart';
import 'package:soen_390/services/google_route_service.dart';
import 'package:soen_390/services/interfaces/route_service_interface.dart';
import 'package:geolocator/geolocator.dart';

void main() async {
  await dotenv.load(); // Load environment variables

  // ✅ Pass GeolocatorPlatform.instance to fix the error
  final locationService =
      LocationService(geolocator: GeolocatorPlatform.instance);
  final httpService = HttpService();

  // Ensure API key is loaded correctly
  final String apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
  if (apiKey.isEmpty) {
    print("❌ ERROR: Missing API Key in .env file!");
    return;
  }

  final routeService = GoogleRouteService(
    locationService: locationService,
    httpService: httpService,
    apiKey: apiKey,
  );

  // Define test locations (New York to Los Angeles)
  LatLng start = const LatLng(40.7128, -74.0060);
  LatLng end = const LatLng(34.0522, -118.2437);

  print("🔍 Fetching route from New York to Los Angeles...");
  RouteResult? route = await routeService.getRoute(from: start, to: end);

  if (route == null) {
    print("❌ No route found.");
  } else {
    print("✅ Route Found!");
    print("📍 Distance: ${route.distance / 1000} km");
    print("🕒 Duration: ${(route.duration / 60).toStringAsFixed(2)} mins");
    print("📍 Route Points: ${route.routePoints.length} points");
  }
}
