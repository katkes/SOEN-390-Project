import 'package:flutter_test/flutter_test.dart';
import 'package:soen_390/models/outdoor_poi.dart';
import 'package:soen_390/models/review.dart';
import 'package:soen_390/models/outdoor_poi.dart';

void main() {
  group('PointOfInterest', () {
    test('Constructor assigns values correctly', () {
      final poi = PointOfInterest(
        id: 'poi_001',
        name: 'Sample Place',
        description: 'A nice place to visit.',
        imageUrl: 'https://example.com/image.jpg',
        address: '123 Street',
        contactPhone: '555-1234',
        website: 'https://example.com',
        openingHours: {'Monday': '9 AM - 5 PM'},
        amenities: ['WiFi', 'Parking'],
        rating: 4.5,
        category: 'Park',
        priceRange: '\$\$',
        reviews: [],
      );

      expect(poi.id, 'poi_001');
      expect(poi.name, 'Sample Place');
      expect(poi.description, 'A nice place to visit.');
      expect(poi.imageUrl, 'https://example.com/image.jpg');
      expect(poi.address, '123 Street');
      expect(poi.contactPhone, '555-1234');
      expect(poi.website, 'https://example.com');
      expect(poi.openingHours?['Monday'], '9 AM - 5 PM');
      expect(poi.amenities, contains('WiFi'));
      expect(poi.rating, 4.5);
      expect(poi.category, 'Park');
      expect(poi.priceRange, '\$\$');
      expect(poi.reviews, isEmpty);
    });

    test('fromPlaceDetails parses data correctly', () {
      final result = {
        'place_id': 'poi_002',
        'name': 'Cafe Good Food',
        'formatted_address': '456 Avenue',
        'formatted_phone_number': '555-5678',
        'website': 'https://cafe.com',
        'types': ['restaurant', 'food'],
        'opening_hours': {
          'weekday_text': [
            'Monday: 9 AM – 9 PM',
            'Tuesday: 9 AM – 9 PM',
          ],
        },
        'serves_beer': true,
        'serves_vegetarian_food': true,
        'price_level': 2,
        'rating': 4.2,
        'reviews': [
          {
            'author_name': 'John Doe',
            'author_url': 'https://profile.com',
            'profile_photo_url': 'https://profile.com/photo.jpg',
            'rating': 5,
            'relative_time_description': '2 days ago',
            'text': 'Great food!',
            'time': 1610000000,
          },
        ],
      };

      final poi = PointOfInterest.fromPlaceDetails(result,
          imageUrl: 'https://img.com/photo.jpg');

      expect(poi.id, 'poi_002');
      expect(poi.name, 'Cafe Good Food');
      expect(poi.address, '456 Avenue');
      expect(poi.contactPhone, '555-5678');
      expect(poi.website, 'https://cafe.com');
      expect(poi.category, 'Restaurant');
      expect(poi.imageUrl, 'https://img.com/photo.jpg');
      expect(poi.openingHours?['Monday'], '9 AM – 9 PM');
      expect(poi.amenities, containsAll(['Beer', 'Vegetarian']));
      expect(poi.priceRange, '\$\$');
      expect(poi.rating, 4.2);
      expect(poi.reviews, isNotEmpty);
      expect(poi.reviews!.first.authorName, 'John Doe');
    });

    test('fromJson parses image URL from photos', () {
      final json = {
        'result': {
          'place_id': 'poi_003',
          'name': 'Sample Store',
          'photos': [
            {'photo_reference': 'abc123'},
          ],
          'types': ['store'],
          'formatted_address': '789 Street',
          'price_level': 1,
          'rating': 3.8,
        },
      };

      final poi = PointOfInterest.fromJson(json);
      expect(poi.id, 'poi_003');
      expect(poi.name, 'Sample Store');
      expect(poi.category, 'Store');
      expect(poi.imageUrl, contains('photoreference=abc123'));
      expect(poi.priceRange, '\$');
    });

    test('prettifyCategory formats correctly', () {
      expect(prettifyCategory('movie_theater'), 'Movie Theater');
      expect(prettifyCategory('local_government_office'),
          'Local Government Office');
    });
  });
}
