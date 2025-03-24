import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soen_390/models/review.dart';
import 'package:soen_390/widgets/review_card.dart';
import 'package:network_image_mock/network_image_mock.dart';

void main() {
  // Sample Review object
  final review = Review(
    authorName: 'Jane Smith',
    authorUrl: 'https://example.com/jane',
    profilePhotoUrl: 'https://example.com/photo.jpg',
    rating: 4,
    relativeTimeDescription: '3 days ago',
    text: 'Awesome product, would recommend!',
    time: DateTime.now(),
  );

  testWidgets('ReviewCard renders review data correctly',
      (WidgetTester tester) async {
    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReviewCard(review: review),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Jane Smith'), findsOneWidget);
      expect(find.text('3 days ago'), findsOneWidget);
      expect(find.text('Awesome product, would recommend!'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsNWidgets(4));
      expect(find.byType(CircleAvatar), findsOneWidget);
    });
  });

  testWidgets('ReviewCard displays correct number of stars',
      (WidgetTester tester) async {
    final reviewWith3Stars = Review(
      authorName: 'Tom',
      authorUrl: '',
      profilePhotoUrl: 'https://example.com/photo.jpg',
      rating: 3,
      relativeTimeDescription: '1 day ago',
      text: 'Pretty good.',
      time: DateTime.now(),
    );

    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReviewCard(review: reviewWith3Stars),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Tom'), findsOneWidget);
      expect(find.text('1 day ago'), findsOneWidget);
      expect(find.text('Pretty good.'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsNWidgets(3));
      expect(find.byType(CircleAvatar), findsOneWidget);
    });
  });
}
