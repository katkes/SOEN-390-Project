library;

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

abstract class BusApiService {
  Future<List<Map<String, double>>> fetchBusData();
}

class ConcordiaBusApi implements BusApiService {
  final http.Client httpClient;
  Timer? _timer;
  final Function(List<Map<String, double>>) onUpdate;

  ConcordiaBusApi({required this.httpClient, required this.onUpdate}) {
    _fetchBusData();
    _timer = Timer.periodic(Duration(seconds: 15), (timer) => _fetchBusData());
  }

  void dispose() {
    _timer?.cancel();
  }

  Future<void> _fetchBusData() async {
    try {
      List<Map<String, double>> busPositions = await fetchBusData();
      onUpdate(busPositions);
    } catch (e) {
      print('Error fetching bus data: $e');
    }
  }

  @override
  Future<List<Map<String, double>>> fetchBusData() async {
    try {
      var sessionResponse = await httpClient.get(
        Uri.parse('https://shuttle.concordia.ca/concordiabusmap/Map.aspx'),
        headers: {'Host': 'shuttle.concordia.ca'},
      );
      
      if (sessionResponse.statusCode != 200) {
        throw Exception('Failed to get session');
      }

      var cookies = sessionResponse.headers['set-cookie'];
      var response = await httpClient.post(
        Uri.parse('https://shuttle.concordia.ca/concordiabusmap/WebService/GService.asmx/GetGoogleObject'),
        headers: {
          'Host': 'shuttle.concordia.ca',
          'Content-Type': 'application/json; charset=UTF-8',
          'Cookie': cookies ?? '',
        },
        body: jsonEncode({}),
      );
      
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        return _extractBusPositions(jsonData['d']['Points']);
      } else {
        throw Exception('Failed to get bus data');
      }
    } catch (e) {
      throw Exception('Error fetching bus data: $e');
    }
  }

    List<Map<String, double>> _extractBusPositions(List<dynamic> points) {
    return points
        .where((point) => point['ID'].startsWith('BUS'))
        .map((point) => {
              'x': (point['Longitude'] as num).toDouble(),
              'y': (point['Latitude'] as num).toDouble(),
            })
        .toList();
  }

}


