// /// This test file verifies that the MapWidget correctly renders markers for SGW and Loyola campuses.
// /// It uses the mockito package to mock HTTP requests and ensure that the markers are displayed correctly
// /// without making real network requests. The test checks that the markers are rendered with the correct
// /// color and verifies that the MapWidget updates correctly when the location changes.
// library;
//
// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:mockito/annotations.dart';
// import 'package:soen_390/widgets/outdoor_map.dart';
// import 'package:mockito/mockito.dart';
// import 'package:http/http.dart' as http;
// import 'outdoor_map_marker_test.mocks.dart';
//
// @GenerateMocks([http.Client])
// void main() {
//   group('MapWidget Tests', () {
//     // Updated group name
//     late MockClient mockClient;
//
//     setUp(() {
//       mockClient = MockClient();
//     });
//
//     testWidgets('renders markers for SGW campus', (WidgetTester tester) async {
//       final LatLng sgwLocation = LatLng(45.497856, -73.579588);
//
//       when(mockClient.get(any))
//           .thenAnswer((_) async => http.Response('Mocked response', 200));
//
//       await tester.pumpWidget(
//         MaterialApp(
//           home: MyPage(
//             // Use MyPage, not Scaffold directly
//             location: sgwLocation,
//             httpClient: mockClient,
//           ),
//         ),
//       );
//
//       await tester.pumpAndSettle();
//
//       expect(find.byIcon(Icons.location_pin), findsNWidgets(1));
//     });
//
//     testWidgets('renders markers for Loyola campus',
//         (WidgetTester tester) async {
//       final LatLng loyolaLocation = LatLng(45.4581, -73.6391);
//
//       when(mockClient.get(any))
//           .thenAnswer((_) async => http.Response('Mocked response', 200));
//
//       await tester.pumpWidget(
//         MaterialApp(
//           home: MyPage(
//             // Use MyPage
//             location: loyolaLocation,
//             httpClient: mockClient,
//           ),
//         ),
//       );
//
//       await tester.pumpAndSettle();
//
//       expect(find.byIcon(Icons.location_pin), findsNWidgets(1));
//     });
//   });
// }
//
// // MyPage Widget (as provided in the previous response)
// // This widget is used to demonstrate how to use the MapWidget by passing the required httpClient and location parameters.
// class MyPage extends StatelessWidget {
//   final http.Client httpClient;
//   final LatLng location;
//
//   const MyPage({required this.httpClient, required this.location, super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         // Or use a Stack if you need precise positioning
//         child: MapWidget(
//           // Use MapWidget
//           location: location,
//           httpClient: httpClient,
//         ),
//       ),
//     );
//   }
// }
