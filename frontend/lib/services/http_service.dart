import 'package:http/http.dart' as http;

class HttpService {
  final http.Client _client;

  HttpService({http.Client? client}) : _client = client ?? http.Client();

  http.Client get client => _client;

  void dispose() {
    _client.close();
  }
}
