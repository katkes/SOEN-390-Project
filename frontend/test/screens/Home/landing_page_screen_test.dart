import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soen_390/screens/home/landing_page_screen.dart';
import 'package:soen_390/providers/navigation_provider.dart';
import 'package:soen_390/providers/theme_provider.dart' as tp;
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'cu_home_screen_test.mocks.dart';

@GenerateMocks([tp.ThemeNotifier, NavigationNotifier])
void main() {
  late MockThemeNotifier mockThemeNotifier;
  late MockNavigationNotifier mockNavigationNotifier;

  setUp(() {
    mockThemeNotifier = MockThemeNotifier();
    mockNavigationNotifier = MockNavigationNotifier();

    when(mockThemeNotifier.state).thenReturn(ThemeData.light());
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        tp.themeProvider.overrideWith((ref) => mockThemeNotifier),
        navigationProvider.overrideWith((ref) => mockNavigationNotifier),
      ],
      child: const MaterialApp(
        home: CUHomeScreen(),
      ),
    );
  }

  testWidgets('renders CUHomeScreen with feature cards', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('CU Explorer'), findsOneWidget);
    expect(find.text('Campus Map'), findsOneWidget);
    expect(find.text('Find My Way'), findsOneWidget);
    expect(find.text('Indoor Maps'), findsOneWidget);
    expect(find.text('Calendar'), findsOneWidget);
    expect(find.text('Your Location'), findsOneWidget);
  });

  testWidgets('taps Campus Map card and triggers navigation', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Campus Map'));
    await tester.pumpAndSettle();

    verify(mockNavigationNotifier.setSelectedIndex(1)).called(1);
  });

  testWidgets('taps Calendar card and triggers navigation', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Calendar'));
    await tester.pumpAndSettle();

    verify(mockNavigationNotifier.setSelectedIndex(2)).called(1);
  });

  testWidgets('toggles theme mode on icon tap', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.dark_mode));
    await tester.pumpAndSettle();

    verify(mockThemeNotifier.toggleTheme()).called(1);
  });
}
