import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:soen_390/services/http_service.dart';

// Create a mock for the http.Client
class MockClient extends Mock implements http.Client {}

void main() {
  group('HttpService', () {
    late HttpService httpService;
    late MockClient mockClient;

    setUp(() {
      mockClient = MockClient();
      httpService = HttpService(client: mockClient);
    });

    tearDown(() {
      httpService.dispose();
    });

    test('constructor initializes with provided client', () {
      expect(httpService.client, equals(mockClient));
    });

    test('constructor initializes with default client if none provided', () {
      final defaultService = HttpService();
      expect(defaultService.client, isA<http.Client>());
    });

    test('dispose closes the client', () {
      httpService.dispose();
      verify(mockClient.close()).called(1);
    });

    test('dispose closes the default client', () {
      final defaultService = HttpService();
      final client = defaultService.client;
      defaultService.dispose();
      expect(() => client.get(Uri.parse('http://example.com')),
          throwsA(isA<http.ClientException>())); //check if client is closed.
    });
  });
}
