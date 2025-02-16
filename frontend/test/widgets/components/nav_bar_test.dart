import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soen_390/widgets/nav_bar.dart';

void main() {
  testWidgets('NavBar displays correctly and responds to taps',
      (WidgetTester tester) async {
    int tappedIndex = -1;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: NavBar(
            selectedIndex: 0,
            onItemTapped: (index) {
              tappedIndex = index;
            },
          ),
        ),
      ),
    );

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Map'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);

    await tester.tap(find.text('Map'));
    await tester.pump();
    expect(tappedIndex, 1);

    await tester.tap(find.text('Profile'));
    await tester.pump();
    expect(tappedIndex, 2);
  });

  testWidgets('NavBar highlights the correct selected tab',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: NavBar(
            selectedIndex: 1,
            onItemTapped: (_) {},
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.map), findsOneWidget);
    expect(find.byIcon(Icons.map_outlined), findsNothing);

    // Ensure other tabs are unselected
    expect(find.byIcon(Icons.home_outlined), findsOneWidget);
    expect(find.byIcon(Icons.person_outline), findsOneWidget);
  });

  testWidgets('NavBar updates selection visually when tapped',
      (WidgetTester tester) async {
    int selectedIndex = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Scaffold(
              bottomNavigationBar: NavBar(
                selectedIndex: selectedIndex,
                onItemTapped: (index) {
                  setState(() {
                    selectedIndex = index;
                  });
                },
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Map'));
    await tester.pump();
    expect(find.byIcon(Icons.map), findsOneWidget);
    expect(find.byIcon(Icons.map_outlined), findsNothing);

    await tester.tap(find.text('Profile'));
    await tester.pump();
    expect(find.byIcon(Icons.person), findsOneWidget);
    expect(find.byIcon(Icons.person_outline), findsNothing);
  });
}
