import 'package:flutter_test/flutter_test.dart';
import 'package:soen_390/models/review.dart';

void main() {
  group('Review Model', () {
    final DateTime testTime =
        DateTime.fromMillisecondsSinceEpoch(1610000000 * 1000);

    final Map<String, dynamic> json = {
      'author_name': 'John Doe',
      'author_url': 'https://example.com/profile',
      'profile_photo_url': 'https://example.com/photo.jpg',
      'rating': 5,
      'relative_time_description': '2 days ago',
      'text': 'Great experience!',
      'time': 1610000000, // seconds since epoch
    };

    final Review review = Review(
      authorName: 'John Doe',
      authorUrl: 'https://example.com/profile',
      profilePhotoUrl: 'https://example.com/photo.jpg',
      rating: 5,
      relativeTimeDescription: '2 days ago',
      text: 'Great experience!',
      time: testTime,
    );

    test('Constructor creates Review object correctly', () {
      expect(review.authorName, 'John Doe');
      expect(review.authorUrl, 'https://example.com/profile');
      expect(review.profilePhotoUrl, 'https://example.com/photo.jpg');
      expect(review.rating, 5);
      expect(review.relativeTimeDescription, '2 days ago');
      expect(review.text, 'Great experience!');
      expect(review.time, testTime);
    });

    test('fromJson creates Review object from JSON map', () {
      final reviewFromJson = Review.fromJson(json);
      expect(reviewFromJson.authorName, 'John Doe');
      expect(reviewFromJson.authorUrl, 'https://example.com/profile');
      expect(reviewFromJson.profilePhotoUrl, 'https://example.com/photo.jpg');
      expect(reviewFromJson.rating, 5);
      expect(reviewFromJson.relativeTimeDescription, '2 days ago');
      expect(reviewFromJson.text, 'Great experience!');
      expect(reviewFromJson.time, testTime);
    });

    test('toJson returns correct JSON map', () {
      final jsonResult = review.toJson();
      expect(jsonResult['author_name'], 'John Doe');
      expect(jsonResult['author_url'], 'https://example.com/profile');
      expect(jsonResult['profile_photo_url'], 'https://example.com/photo.jpg');
      expect(jsonResult['rating'], 5);
      expect(jsonResult['relative_time_description'], '2 days ago');
      expect(jsonResult['text'], 'Great experience!');
      expect(jsonResult['time'], 1610000000);
    });

    test('parseReviews returns a list of Review objects from JSON list', () {
      final List<Map<String, dynamic>> jsonList = [json, json];
      final reviews = parseReviews(jsonList);
      expect(reviews.length, 2);
      expect(reviews[0].authorName, 'John Doe');
      expect(reviews[1].rating, 5);
    });

    test('fromJson handles missing fields with defaults', () {
      final partialJson = <String, dynamic>{};
      final reviewFromPartial = Review.fromJson(partialJson);
      expect(reviewFromPartial.authorName, '');
      expect(reviewFromPartial.rating, 0);
      expect(reviewFromPartial.time.millisecondsSinceEpoch, 0);
    });
  });
}
