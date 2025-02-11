import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:soen_390/widgets/campus_switch_button.dart'; 

void main() {
  group('CampusSwitch Widget Tests', () {
    testWidgets('displays initial selection correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CampusSwitch(
            onSelectionChanged: (_) {},
            onLocationChanged: (_) {},
            initialSelection: 'SGW',
          ),
        ),
      );

      expect(find.text('SGW'), findsOneWidget);
      expect(find.text('Loyola'), findsOneWidget);
    });

    testWidgets('switching campus updates selection and triggers callbacks', (WidgetTester tester) async {
      String? selectedCampus;
      LatLng? selectedLocation;

      await tester.pumpWidget(
        MaterialApp(
          home: CampusSwitch(
            onSelectionChanged: (campus) => selectedCampus = campus,
            onLocationChanged: (location) => selectedLocation = location,
            initialSelection: 'SGW',
          ),
        ),
      );

      
      await tester.tap(find.text('Loyola'));
      await tester.pumpAndSettle();
      expect(selectedCampus, 'Loyola');
      expect(selectedLocation, LatLng(45.4581, -73.6391));

 
      await tester.tap(find.text('SGW'));
      await tester.pumpAndSettle();

      expect(selectedCampus, 'SGW');
      expect(selectedLocation, LatLng(45.497856, -73.579588));
    });
  });
}
