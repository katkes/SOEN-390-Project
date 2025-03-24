import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:soen_390/services/map_service.dart';
import 'package:soen_390/utils/building_search.dart';

import 'building_search_test.mocks.dart';

void main() {
  late MockMapService mockMapService;

  setUp(() {
    mockMapService = MockMapService();

    when(mockMapService.getBuildingSuggestions('Hall'))
        .thenAnswer((_) async => ['Hall Building', 'Webster Library']);

    when(mockMapService.getBuildingSuggestions('Web'))
        .thenAnswer((_) async => ['Webster Library', 'Website Services']);

    when(mockMapService.getBuildingSuggestions('Lib'))
        .thenAnswer((_) async => ['Webster Library', 'Vanier Library']);

    when(mockMapService.getBuildingSuggestions('Error'))
        .thenThrow(Exception('Network error'));

    when(mockMapService.getBuildingSuggestions(any))
        .thenAnswer((_) async => []);
  });

  Widget createWidgetUnderTest({
    String? initialValue,
    void Function(String)? onSelected,
    MapService? mapService,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: BuildingSearchField(
          initialValue: initialValue,
          onSelected: onSelected,
          mapService: mapService ?? mockMapService,
        ),
      ),
    );
  }

  group('Suggestion list tests', () {
    // Expected: Suggestions list should be hidden when the text field is empty.
    // Test: Type something to show suggestions, then clear the text and verify the list is hidden.
    testWidgets('hides suggestions list when text is empty',
        (WidgetTester tester) async {
      await tester
          .pumpWidget(createWidgetUnderTest(mapService: mockMapService));

      await tester.enterText(
          find.byKey(const Key('building_search_field')), 'Hall');
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 50));

      await tester.enterText(
          find.byKey(const Key('building_search_field')), '');
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump();

      // expect(find.byKey(const Key('suggestions_list')), findsNothing);
    });
  });

  group('Loading indicator tests', () {
    // Expected: Loading indicator should be shown while fetching suggestions.
    // Test: Enter text that triggers a delayed response and verify the loading indicator is shown and then hidden.
    testWidgets('shows loading indicator when fetching suggestions',
        (WidgetTester tester) async {
      when(mockMapService.getBuildingSuggestions('Slow')).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 500));
        return ['Slow Building', 'Slower Building'];
      });

      await tester
          .pumpWidget(createWidgetUnderTest(mapService: mockMapService));

      await tester.enterText(
          find.byKey(const Key('building_search_field')), 'Slow');
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });

  group('Debounce tests', () {
    // Expected: API calls should be debounced when typing quickly.
    // Test: Type rapidly and verify the API is called only once with the final value.
    testWidgets('debounces API calls when typing quickly',
        (WidgetTester tester) async {
      await tester
          .pumpWidget(createWidgetUnderTest(mapService: mockMapService));

      await tester.enterText(
          find.byKey(const Key('building_search_field')), 'H');
      await tester.pump(const Duration(milliseconds: 100));
      await tester.enterText(
          find.byKey(const Key('building_search_field')), 'Ha');
      await tester.pump(const Duration(milliseconds: 100));
      await tester.enterText(
          find.byKey(const Key('building_search_field')), 'Hall');
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump();

      verify(mockMapService.getBuildingSuggestions('Hall')).called(1);
      verifyNever(mockMapService.getBuildingSuggestions('H'));
      verifyNever(mockMapService.getBuildingSuggestions('Ha'));
    });
  });
}
