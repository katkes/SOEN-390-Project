import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:osrm/osrm.dart';
import 'package:soen_390/services/osrm_route_service.dart';
import '../services/interfaces/route_service_interface.dart';
import 'package:soen_390/services/http_service.dart';

/// Provides an instance of [Osrm] client.
///
/// This client is responsible for handling requests to the OSRM API,
/// which is used for route calculations.
final osrmProvider = Provider<Osrm>((ref) {
  return Osrm();
});

/// Provides an implementation of [IRouteService] using [OsrmRouteService].
///
/// This service is responsible for fetching routes using the OSRM client.
/// It allows dependency injection via Riverpod for better state management
/// and testability.
final routeServiceProvider = Provider<IRouteService>((ref) {
  final osrmClient = ref.read(osrmProvider);
  return OsrmRouteService(osrmClient);
});

/// Provides an instance of [HttpService] to manage HTTP requests.
final httpServiceProvider = Provider<HttpService>((ref) {
  return HttpService();
});
