import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soen_390/screens/Home/landing_page_screen.dart';
import 'package:soen_390/screens/indoor/mappedin_map_controller.dart';
import 'package:soen_390/utils/navigation_utils.dart';

import 'landing_page_screen_test.mocks.dart';

// Generate mocks
@GenerateMocks([MappedinMapController, NavigationUtils])
void main() {
  // ignore: unused_local_variable
  late MockMappedinMapController mockMappedinMapController;
  // ignore: unused_local_variable
  late MockNavigationUtils mockNavigationUtils;

  setUp(() {
    mockMappedinMapController = MockMappedinMapController();
    mockNavigationUtils = MockNavigationUtils();
  });

  Widget createTestableWidget(Widget child) {
    return ProviderScope(
      child: MaterialApp(
        home: child,
      ),
    );
  }

  testWidgets('CUHomeScreen shows the correct theme',
      (WidgetTester tester) async {
    await tester.pumpWidget(createTestableWidget(const CUHomeScreen()));

    expect(find.text('CU Explorer'), findsOneWidget);
    expect(find.byType(IconButton), findsOneWidget);

    expect(find.byIcon(Icons.dark_mode), findsOneWidget);

    await tester.tap(find.byIcon(Icons.dark_mode));
    await tester.pump();

    expect(find.byIcon(Icons.light_mode), findsOneWidget);
  });
}
