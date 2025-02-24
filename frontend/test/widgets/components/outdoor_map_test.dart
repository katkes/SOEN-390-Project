// library;
//
// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:mockito/annotations.dart';
// import 'package:mockito/mockito.dart';
// import 'package:http/http.dart' as http;
// import 'package:soen_390/widgets/outdoor_map.dart';
// import 'outdoor_map_test.mocks.dart';
//
// @GenerateMocks([http.Client])
// void main() {
//   late MockClient mockClient;
//   final LatLng testLocation = LatLng(45.497856, -73.579588);
//
//   setUp(() {
//     mockClient = MockClient();
//   });
//
//   group('OutdoorMap Widget Tests', () {
//     testWidgets('renders MapWidget correctly', (WidgetTester tester) async {
//       await tester.pumpWidget(
//         MaterialApp(
//           home: Scaffold(
//             body: MapWidget(location: testLocation),
//           ),
//         ),
//       );
//
//       expect(find.byType(FlutterMap), findsOneWidget);
//     });
//
//     testWidgets('loads markers successfully', (WidgetTester tester) async {
//       await tester.pumpWidget(
//         MaterialApp(
//           home: Scaffold(
//             body: MapWidget(location: testLocation),
//           ),
//         ),
//       );
//
//       await tester.pumpAndSettle();
//       expect(find.byType(MarkerLayer), findsOneWidget);
//     });
//
//     testWidgets('handles API calls for additional data', (WidgetTester tester) async {
//       when(mockClient.get(any)).thenAnswer((_) async => http.Response('{"status": "success"}', 200));
//
//       await tester.pumpWidget(
//         MaterialApp(
//           home: OutdoorMap(httpClient: mockClient),
//         ),
//       );
//
//       await tester.pumpAndSettle();
//
//       verify(mockClient.get(any)).called(1);
//     });
//
//     testWidgets('does not call API when not needed', (WidgetTester tester) async {
//       await tester.pumpWidget(
//         MaterialApp(
//           home: OutdoorMap(), // No httpClient passed, should not make an API call
//         ),
//       );
//
//       await tester.pumpAndSettle();
//
//       verifyNever(mockClient.get(any));
//     });
//   });
// }
