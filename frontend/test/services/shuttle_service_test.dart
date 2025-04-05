import 'package:flutter_test/flutter_test.dart';
import 'package:soen_390/services/shuttle_service.dart';

void main() {
  group('ShuttleService Tests', () {
    test('getFridaySchedule returns correct data structure', () {
      final service = ShuttleService();
      final schedule = service.getFridaySchedule();
      
      // Test departures lists
      expect(schedule.loyDepartures, isA<List<String>>());
      expect(schedule.loyDepartures.isNotEmpty, true);
      expect(schedule.loyDepartures.first, '9:15');
      expect(schedule.loyDepartures.last, '18:15');
      
      expect(schedule.sgwDepartures, isA<List<String>>());
      expect(schedule.sgwDepartures.isNotEmpty, true);
      expect(schedule.sgwDepartures.first, '9:45');
      expect(schedule.sgwDepartures.last, '18:15');
      
      // Test last bus info
      expect(schedule.lastBus, isA<Map<String, String>>());
      expect(schedule.lastBus['LOY'], '18:15');
      expect(schedule.lastBus['SGW'], '18:15');
      
      // Test stops
      expect(schedule.stops, isA<Map<String, ShuttleStopLocation>>());
      expect(schedule.stops['LOY']?.coordinates, '45°27\'28.2"N 73°38\'20.3"W');
      expect(schedule.stops['SGW']?.coordinates, '45°29\'49.6"N 73°34\'42.5"W');
      expect(schedule.stops['LOY']?.name, 'LOY');
      expect(schedule.stops['SGW']?.name, 'SGW');
    });
  });
  
  group('ShuttleStopLocation Tests', () {
    test('ShuttleStopLocation constructor creates instance with correct properties', () {
      const name = 'Test Location';
      const coordinates = '45°00\'00.0"N 73°00\'00.0"W';
      
      final location = ShuttleStopLocation(name: name, coordinates: coordinates);
      
      expect(location.name, name);
      expect(location.coordinates, coordinates);
    });
  });
  
  group('ShuttleSchedule Tests', () {
    test('ShuttleSchedule constructor creates instance with correct properties', () {
      final loyDepartures = ['9:00', '10:00'];
      final sgwDepartures = ['9:30', '10:30'];
      final lastBus = {'LOY': '22:00', 'SGW': '22:30'};
      final stops = {
        'LOY': ShuttleStopLocation(name: 'LOY', coordinates: '45°27\'28.2"N 73°38\'20.3"W'),
        'SGW': ShuttleStopLocation(name: 'SGW', coordinates: '45°29\'49.6"N 73°34\'42.5"W'),
      };
      
      final schedule = ShuttleSchedule(
        loyDepartures: loyDepartures,
        sgwDepartures: sgwDepartures,
        lastBus: lastBus,
        stops: stops,
      );
      
      expect(schedule.loyDepartures, loyDepartures);
      expect(schedule.sgwDepartures, sgwDepartures);
      expect(schedule.lastBus, lastBus);
      expect(schedule.stops, stops);
    });
  });
}