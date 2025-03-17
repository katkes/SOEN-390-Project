import 'package:flutter_test/flutter_test.dart';
import 'package:soen_390/models/places.dart';

void main() {
  group('Place', () {
    final testPlace = Place(
      name: 'Test Place',
      placeId: 'test123',
      businessStatus: 'OPERATIONAL',
      latitude: 45.5017,
      longitude: -73.5673,
      address: '123 Test St',
      types: ['restaurant', 'food'],
      rating: 4.5,
      userRatingsTotal: 100,
      priceLevel: 2,
      openNow: true,
      photoReference: 'photo123',
      iconUrl: 'http://test.com/icon.png',
      plusCode: '87G8+XF Montreal',
    );

    test('fromJson creates Place instance correctly', () {
      final json = {
        'name': 'Test Place',
        'place_id': 'test123',
        'business_status': 'OPERATIONAL',
        'geometry': {
          'location': {'lat': 45.5017, 'lng': -73.5673}
        },
        'vicinity': '123 Test St',
        'types': ['restaurant', 'food'],
        'rating': 4.5,
        'user_ratings_total': 100,
        'price_level': 2,
        'opening_hours': {'open_now': true},
        'photos': [
          {'photo_reference': 'photo123'}
        ],
        'icon': 'http://test.com/icon.png',
        'plus_code': {'compound_code': '87G8+XF Montreal'}
      };

      final place = Place.fromJson(json);
      expect(place.name, 'Test Place');
      expect(place.placeId, 'test123');
      expect(place.latitude, 45.5017);
      expect(place.longitude, -73.5673);
    });

    test('toJson converts Place to correct JSON format', () {
      final json = testPlace.toJson();
      expect(json['name'], 'Test Place');
      expect(json['place_id'], 'test123');
      expect(json['latitude'], 45.5017);
      expect(json['longitude'], -73.5673);
    });

    test('formattedPriceLevel returns correct string', () {
      expect(testPlace.formattedPriceLevel(), '\$\$');

      final nullPricePlace = Place(
          name: 'Test',
          placeId: 'test',
          businessStatus: 'OPERATIONAL',
          latitude: 0,
          longitude: 0,
          address: 'test',
          types: [],
          rating: 0,
          userRatingsTotal: 0,
          iconUrl: 'test');
      expect(nullPricePlace.formattedPriceLevel(), 'N/A');
    });

    test('openStatus returns correct string', () {
      expect(testPlace.openStatus(), 'Open Now');

      final closedPlace = Place(
          name: 'Test',
          placeId: 'test',
          businessStatus: 'OPERATIONAL',
          latitude: 0,
          longitude: 0,
          address: 'test',
          types: [],
          rating: 0,
          userRatingsTotal: 0,
          openNow: false,
          iconUrl: 'test');
      expect(closedPlace.openStatus(), 'Closed');
    });

    test('thumbnailPhotoUrl returns correct URL', () {
      expect(testPlace.thumbnailPhotoUrl('test-api-key'),
          'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photo_reference=photo123&key=test-api-key');

      final noPhotoPlace = Place(
          name: 'Test',
          placeId: 'test',
          businessStatus: 'OPERATIONAL',
          latitude: 0,
          longitude: 0,
          address: 'test',
          types: [],
          rating: 0,
          userRatingsTotal: 0,
          iconUrl: 'test');
      expect(noPhotoPlace.thumbnailPhotoUrl('test-api-key'), null);
    });

    test('formattedTypes returns formatted string', () {
      expect(testPlace.formattedTypes(), 'Restaurant, Food');

      final emptyTypesPlace = Place(
          name: 'Test',
          placeId: 'test',
          businessStatus: 'OPERATIONAL',
          latitude: 0,
          longitude: 0,
          address: 'test',
          types: [],
          rating: 0,
          userRatingsTotal: 0,
          iconUrl: 'test');
      expect(emptyTypesPlace.formattedTypes(), 'Unknown Type');
    });

    test('ratingSummary returns correct format', () {
      expect(testPlace.ratingSummary(), '4.5 ★ (100 reviews)');
    });

    test('String capitalize extension works correctly', () {
      expect('test'.capitalize(), 'Test');
      expect(''.capitalize(), '');
    });
  });
}
