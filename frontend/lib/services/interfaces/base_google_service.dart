import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:soen_390/services/interfaces/http_client_interface.dart';
import 'package:soen_390/utils/google_api_helper.dart';

/// An abstract base class that provides shared setup for services interacting with Google APIs.
///
/// This class encapsulates common dependencies and validation logic needed when using
/// Google Maps or Places APIs, including:
/// - An API key loaded from the environment using `flutter_dotenv`
/// - A custom [IHttpClient] for making HTTP requests
/// - A [GoogleApiHelper] for consistent response validation
///
/// This class is meant to be extended by other services that require access
/// to Google API features.
///
/// Example:
/// ```dart
/// class MyGoogleService extends BaseGoogleService {
///   MyGoogleService({required IHttpClient client})
///     : super(httpClient: client);
/// }
/// ```
abstract class BaseGoogleService {
  /// The API key used to authenticate requests to the Google Maps API.
  ///
  /// This key is loaded from the environment using `dotenv.env['GOOGLE_MAPS_API_KEY']`
  /// unless explicitly provided via the constructor.
  final String apiKey;

  /// The HTTP client used for making network requests.
  final IHttpClient httpClient;

  /// Helper utility for performing API calls and validating responses.
  final GoogleApiHelper apiHelper;

  /// Constructs a [BaseGoogleService] instance with the required [httpClient],
  /// and optional [apiHelper] and [apiKey].
  ///
  /// - If [apiHelper] is not provided, a default [GoogleApiHelper] is created.
  /// - If [apiKey] is not provided, it is loaded from the `.env` file using the
  ///   `flutter_dotenv` package (`GOOGLE_MAPS_API_KEY`).
  ///
  /// Throws:
  /// - [Exception] if the API key is missing or empty.
  BaseGoogleService({
    required this.httpClient,
    GoogleApiHelper? apiHelper,
    String? apiKey,
  })  : apiHelper = apiHelper ?? GoogleApiHelper(),
        apiKey = apiKey ?? dotenv.env['GOOGLE_MAPS_API_KEY'] ?? "" {
    if (this.apiKey.isEmpty) {
      throw Exception("Missing Google Maps API Key");
    }
  }
}
