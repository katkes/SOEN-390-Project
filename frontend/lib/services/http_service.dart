import 'package:http/http.dart' as http;
import 'package:soen_390/services/interfaces/http_client_interface.dart';

/// A concrete implementation of [IHttpClient] that wraps the [http.Client] class.
///
/// This service provides a reusable HTTP client for making network requests.
/// It can be injected into other services or repositories to facilitate testing
/// and separation of concerns.
///
/// Example usage:
/// ```dart
/// final httpService = HttpService();
/// final response = await httpService.get(Uri.parse('https://example.com'));
/// print(response.body);
/// httpService.dispose();
/// ```
class HttpService implements IHttpClient {
  /// Internal HTTP client used to make requests.
  final http.Client _client;

  /// Creates an instance of [HttpService] with an optional [http.Client].
  ///
  /// If no client is provided, a new [http.Client] is instantiated.
  HttpService({http.Client? client}) : _client = client ?? http.Client();

  /// Sends an HTTP GET request to the specified [url].
  ///
  /// This method overrides the [get] method from [IHttpClient].
  ///
  /// Returns a [Future] that completes with the [http.Response].
  @override
  Future<http.Response> get(Uri url) => _client.get(url);

  /// Returns the internal [http.Client] instance.
  ///
  /// Useful if more advanced operations are needed beyond the [get] method.
  http.Client get client => _client;

  /// Closes the internal [http.Client] to free up resources.
  ///
  /// Should be called when the client is no longer needed, such as in a
  /// `dispose()` method or cleanup routine.
  void dispose() {
    _client.close();
  }
}
