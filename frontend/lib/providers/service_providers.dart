import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soen_390/services/http_service.dart';
import 'package:soen_390/services/google_route_service.dart';
import '../services/interfaces/route_service_interface.dart';
import 'package:soen_390/utils/location_service.dart';
import 'package:soen_390/services/building_to_coordinates.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:soen_390/services/auth_service.dart';
import 'package:soen_390/core/secure_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final flutterSecureStorage = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

/// Provides an instance of [LocationService].
final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService.instance;
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

/// Provides an instance of [GeocodingService] for building coordinate lookups.
final buildingToCoordinatesProvider = Provider<GeocodingService>((ref) {
  final apiKey = dotenv.env['GOOGLE_PLACES_API_KEY'];
  final httpService = ref.read(httpServiceProvider);

  return GeocodingService(
    httpService: httpService,
    apiKey: apiKey, // Pass the API key if available
  );
});

/// Provides an instance of [GoogleSignIn] with required scopes.
final googleSignInProvider = Provider<GoogleSignIn>((ref) {
  return GoogleSignIn(
    clientId: dotenv.env['IOS_CLIENT_ID'],
    serverClientId: dotenv.env['WEB_CLIENT_ID'],
    scopes: ['https://www.googleapis.com/auth/calendar'],
  );
});

/// Provides an instance of [SecureStorage].
final secureStorageProvider = Provider<SecureStorage>((ref) {
  return SecureStorage(ref.watch(flutterSecureStorage));
});

/// Provides an instance of [AuthClientFactory].
final authClientFactoryProvider = Provider<AuthClientFactory>((ref) {
  return AuthClientFactory();
});

/// Provides an instance of [AuthService] for authentication management.
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(
    googleSignIn: ref.watch(googleSignInProvider),
    httpService: ref.watch(httpServiceProvider),
    secureStorage: ref.watch(secureStorageProvider),
    authClientFactory: ref.watch(authClientFactoryProvider),
  );
});
