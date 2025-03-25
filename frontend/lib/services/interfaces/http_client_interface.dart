import 'package:http/http.dart' as http;

abstract class IHttpClient {
  Future<http.Response> get(Uri url);
}
