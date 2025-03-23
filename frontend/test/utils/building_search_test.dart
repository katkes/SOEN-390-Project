import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:soen_390/services/map_service.dart';
import 'package:soen_390/utils/building_search.dart';

@GenerateMocks([MapService])
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
          mapService: mapService,
        ),
      ),
    );
  }

  testWidgets('BuildingSearchField renders correctly with initial value',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest(
      initialValue: 'Hall Building',
    ));

    expect(find.byType(TextField), findsOneWidget);

    expect(find.text('Building'), findsOneWidget);

    expect(find.text('Hall Building'), findsOneWidget);
  });

  testWidgets('BuildingSearchField renders without initial value',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byType(TextField), findsOneWidget);

    // Verify the label is present
    expect(find.text('Building'), findsOneWidget);

    // Verify no text is in the input
    final TextField textField = tester.widget(find.byType(TextField));
    expect(textField.controller!.text, '');
  });

  testWidgets('BuildingSearchField renders without initial value',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Building'), findsOneWidget);
    final TextField textField = tester.widget(find.byType(TextField));
    expect(textField.controller!.text, '');
  });
  testWidgets('Respects widget.initialValue during initialization',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest(
      initialValue: 'Vanier Library',
    ));

    final TextField textField = tester.widget(find.byType(TextField));
    expect(textField.controller!.text, 'Vanier Library');
  });
  testWidgets('displays the initial value in the text field',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: BuildingSearchField(
            initialValue: "EV Building", mapService: mockMapService),
      ),
    ));

    expect(find.byKey(const Key('building_search_field')), findsOneWidget);
    expect(find.text('EV Building'), findsOneWidget);
  });
}
