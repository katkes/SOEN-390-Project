import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soen_390/services/map_service.dart';
import 'package:soen_390/utils/building_search.dart';
import 'package:mockito/mockito.dart';

// Mock class for MapService
class MockMapService extends Mock implements MapService {
  @override
  Future<List<String>> getBuildingSuggestions(String input) {
    return super.noSuchMethod(
      Invocation.method(#getBuildingSuggestions, [input]),
      returnValue: Future.value(['Building 1', 'Building 2', 'Building 3']),
    );
  }
}

void main() {
  group('BuildingSearchField Widget Tests', () {
    testWidgets('Initial state and rendering', (WidgetTester tester) async {
      mockOnSelected(String buildingName) {}

      await tester.pumpWidget(MaterialApp(
        home: BuildingSearchField(
          onSelected: mockOnSelected,
          initialValue: 'Building A',
        ),
      ));

      expect(find.text('Building A'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });
    test('getBuildingSuggestions returns valid suggestions', () async {
      final mapService = MapService();

      final result = await mapService.getBuildingSuggestions('Library');

      expect(result, isNotEmpty);
      expect(result.first.toLowerCase(), contains('library'));
    });
  });
}
