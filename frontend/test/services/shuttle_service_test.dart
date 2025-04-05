import 'package:flutter_test/flutter_test.dart';
import 'package:soen_390/services/shuttle_service.dart';

void main() {
  // Group of tests for the ShuttleService class
  group('ShuttleService', () {
    late ShuttleService shuttleService;

    // Set up a new instance of ShuttleService before each test
    setUp(() {
      shuttleService = ShuttleService();
    });

    // Test to verify the correctness of the Friday schedule data
    test('getFridaySchedule returns correct schedule data', () {
      final fridaySchedule = shuttleService.getFridaySchedule();

      // Verify the number of departures for both campuses
      expect(fridaySchedule.loyDepartures.length, 23);
      expect(fridaySchedule.sgwDepartures.length, 22);

      // Verify the last bus times for both campuses
      expect(fridaySchedule.lastBus['LOY'], '18:15');
      expect(fridaySchedule.lastBus['SGW'], '18:15');

      // Verify the number of stops and their details
      expect(fridaySchedule.stops.length, 2);
      expect(fridaySchedule.stops['LOY']?.name, 'LOY');
      expect(fridaySchedule.stops['LOY']?.coordinates, '45°27\'28.2"N 73°38\'20.3"W');
      expect(fridaySchedule.stops['SGW']?.coordinates, '45°29\'49.6"N 73°34\'42.5"W');

      // Verify specific departure times
      expect(fridaySchedule.loyDepartures.first, '9:15');
      expect(fridaySchedule.loyDepartures.last, '18:15');
      expect(fridaySchedule.sgwDepartures.first, '9:45');
      expect(fridaySchedule.sgwDepartures.last, '18:15');
    });

    // Test to verify the correctness of the Monday-Thursday schedule data
    test('getMondayThursdaySchedule returns correct schedule data', () {
      final mondayThursdaySchedule = shuttleService.getMondayThursdaySchedule();

      // Verify the number of departures for both campuses
      expect(mondayThursdaySchedule.loyDepartures.length, 34);
      expect(mondayThursdaySchedule.sgwDepartures.length, 33);

      // Verify the last bus times for both campuses
      expect(mondayThursdaySchedule.lastBus['LOY'], '18:30');
      expect(mondayThursdaySchedule.lastBus['SGW'], '18:30');

      // Verify the number of stops and their details
      expect(mondayThursdaySchedule.stops.length, 2);
      expect(mondayThursdaySchedule.stops['LOY']?.name, 'LOY');
      expect(mondayThursdaySchedule.stops['LOY']?.coordinates, '45°27\'28.2"N 73°38\'20.3"W');
      expect(mondayThursdaySchedule.stops['SGW']?.coordinates, '45°29\'49.6"N 73°34\'42.5"W');

      // Verify specific departure times
      expect(mondayThursdaySchedule.loyDepartures.first, '9:15');
      expect(mondayThursdaySchedule.loyDepartures.last, '18:30');
      expect(mondayThursdaySchedule.sgwDepartures.first, '9:30');
      expect(mondayThursdaySchedule.sgwDepartures.last, '18:30');
    });
  });

  // Group of tests for the ShuttleStopLocation class
  group('ShuttleStopLocation', () {
    // Test to verify the creation of a ShuttleStopLocation with correct values
    test('should create a ShuttleStopLocation with correct values', () {
      const name = 'LOY';
      const coordinates = '45°27\'28.2"N 73°38\'20.3"W';

      final location = ShuttleStopLocation(name: name, coordinates: coordinates);

      // Verify the name and coordinates of the location
      expect(location.name, name);
      expect(location.coordinates, coordinates);
    });
  });

  // Group of tests for the ShuttleSchedule class
  group('ShuttleSchedule', () {
    // Test to verify the creation of a ShuttleSchedule with correct values
    test('should create a ShuttleSchedule with correct values', () {
      final loyDepartures = ['9:15', '9:30'];
      final sgwDepartures = ['9:45', '10:00'];
      final lastBus = {'LOY': '18:15', 'SGW': '18:15'};
      final stops = {
        'LOY': ShuttleStopLocation(name: 'LOY', coordinates: '45°27\'28.2"N 73°38\'20.3"W'),
        'SGW': ShuttleStopLocation(name: 'SGW', coordinates: '45°29\'49.6"N 73°34\'42.5"W')
      };

      final schedule = ShuttleSchedule(
        loyDepartures: loyDepartures,
        sgwDepartures: sgwDepartures,
        lastBus: lastBus,
        stops: stops,
      );

      // Verify the schedule details
      expect(schedule.loyDepartures, loyDepartures);
      expect(schedule.sgwDepartures, sgwDepartures);
      expect(schedule.lastBus, lastBus);
      expect(schedule.stops, stops);
    });
  });
}