import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:soen_390/services/shuttle_information_api.dart';

// Generate a Mock Client
@GenerateMocks([http.Client])
import 'shuttle_information_api_test.mocks.dart';

void main() {
  late MockClient mockHttpClient;
  late ConcordiaBusApi busApiService;

  setUp(() {
    mockHttpClient = MockClient();
    busApiService = ConcordiaBusApi(
      httpClient: mockHttpClient,
      onUpdate: (data) {},
    );
  });

  test('fetchBusData returns bus positions', () async {
    // Mock session response
    when(mockHttpClient.get(any, headers: anyNamed('headers')))
        .thenAnswer((_) async => http.Response('', 200, headers: {'set-cookie': 'SESSION_COOKIE'}));

    // Mock bus data response
    when(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
        .thenAnswer((_) async => http.Response(
              jsonEncode({
                "d": {
                  "Points": [
                    {
                      "ID": "BUS0",
                      "Longitude": -73.6319199,
                      "Latitude": 45.4499321
                    },
                    {
                      "ID": "BUS1",
                      "Longitude": -73.7131042,
                      "Latitude": 45.7183762
                    }
                  ]
                }
              }),
              200,
            ));

    // Call fetchBusData
    final result = await busApiService.fetchBusData();

    // Expect correct bus positions
    expect(result, [
      {'x': -73.6319199, 'y': 45.4499321},
      {'x': -73.7131042, 'y': 45.7183762},
    ]);
  });

  test('fetchBusData throws an error on failure', () async {
    // Mock failed response
    when(mockHttpClient.get(any, headers: anyNamed('headers')))
        .thenAnswer((_) async => http.Response('Unauthorized', 401));

    expect(() async => await busApiService.fetchBusData(), throwsException);
  });
}
