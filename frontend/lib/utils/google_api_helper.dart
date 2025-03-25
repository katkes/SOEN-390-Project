import 'dart:convert';
import '../services/interfaces/http_client_interface.dart';

/// A utility class for interacting with Google APIs and handling common response validation.
///
/// The [GoogleApiHelper] provides a method to perform HTTP GET requests using a custom
/// [IHttpClient] and parse the response into a JSON map while checking for expected status.
///
/// This is particularly useful when working with Google APIs that return structured JSON
/// responses with a `status` field indicating success or failure.
class GoogleApiHelper {
  /// Fetches JSON data from the given [url] using the provided [client].
  ///
  /// The response is expected to have a `status` field in the JSON body
  /// that matches [expectedStatus] (default is `'OK'`).
  ///
  /// Throws an [Exception] if:
  /// - The HTTP status code is not 200
  /// - The response JSON's `status` field does not match [expectedStatus]
  ///
  /// Returns a `Future<Map<String, dynamic>>` containing the decoded JSON.
  ///
  /// Example:
  /// ```dart
  /// final helper = GoogleApiHelper();
  /// final data = await helper.fetchJson(client, Uri.parse('https://maps.googleapis.com/maps/api/...'));
  /// ```
  Future<Map<String, dynamic>> fetchJson(
    IHttpClient client,
    Uri url, {
    String expectedStatus = 'OK',
  }) async {
    final response = await client.get(url);

    if (response.statusCode != 200) {
      throw Exception('HTTP Error: ${response.statusCode}');
    }

    final data = jsonDecode(response.body);

    if (data['status'] != expectedStatus) {
      throw Exception('API Error: ${data['status']}');
    }

    return data;
  }
}
