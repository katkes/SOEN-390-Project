//
// library;
//
// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:soen_390/widgets/building_details.dart';
//
// void main() {
//   group('CampusMap Widget Tests', () {
//     testWidgets('renders CampusMap widget correctly', (WidgetTester tester) async {
//       await tester.pumpWidget(
//         const MaterialApp(
//           home: CampusMap(),
//         ),
//       );
//
//       expect(find.byType(CampusMap), findsOneWidget);
//       expect(find.byType(FlutterMap), findsOneWidget);
//       expect(find.byType(Scaffold), findsOneWidget);
//     });
//
//     testWidgets('renders empty CampusMap without errors', (WidgetTester tester) async {
//       await tester.pumpWidget(
//         const MaterialApp(
//           home: CampusMap(),
//         ),
//       );
//
//       await tester.pumpAndSettle();
//
//       expect(find.byType(PolygonLayer), findsNothing);
//     });
//   });
// }
