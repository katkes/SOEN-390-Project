import 'package:flutter_test/flutter_test.dart';
import 'package:soen_390/models/places.dart';

/// Unit tests for the [Place] model and its utility methods.
void main() {
  group('Place', () {
    /// A sample [Place] instance used for most test cases.
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

    /// Tests the [Place.fromJson] factory to ensure it properly parses JSON data.
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

    /// Tests the [Place.toJson] method to ensure the model serializes to the correct JSON format.
    test('toJson converts Place to correct JSON format', () {
      final json = testPlace.toJson();
      expect(json['name'], 'Test Place');
      expect(json['place_id'], 'test123');
      expect(json['latitude'], 45.5017);
      expect(json['longitude'], -73.5673);
    });

    /// Tests the [Place.formattedPriceLevel] method, which returns a string representation
    /// of the place's price level using dollar signs or "N/A" if price level is null.
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
        iconUrl: 'test',
      );
      expect(nullPricePlace.formattedPriceLevel(), 'N/A');
    });

    /// Tests the [Place.openStatus] method, which indicates whether the place is currently open.
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
        iconUrl: 'test',
      );
      expect(closedPlace.openStatus(), 'Closed');
    });

    /// Tests the [Place.thumbnailPhotoUrl] method, which returns a Google Places API photo URL
    /// using the provided API key, or null if no photo reference is available.
    test('thumbnailPhotoUrl returns correct URL', () {
      expect(
        testPlace.thumbnailPhotoUrl('test-api-key'),
        'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photo_reference=photo123&key=test-api-key',
      );

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
        iconUrl: 'test',
      );
      expect(noPhotoPlace.thumbnailPhotoUrl('test-api-key'), null);
    });

    /// Tests the [Place.formattedTypes] method, which capitalizes and joins the place's types
    /// into a readable string, or returns "Unknown Type" if types are empty.
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
        iconUrl: 'test',
      );
      expect(emptyTypesPlace.formattedTypes(), 'Unknown Type');
    });

    /// Tests the [Place.ratingSummary] method, which returns the place's rating
    /// and number of user reviews in a readable format.
    test('ratingSummary returns correct format', () {
      expect(testPlace.ratingSummary(), '4.5 ★ (100 reviews)');
    });

    /// Tests a string extension method [capitalize] that capitalizes the first letter
    /// of a string. Verifies correct behavior on non-empty and empty strings.
    test('String capitalize extension works correctly', () {
      expect('test'.capitalize(), 'Test');
      expect(''.capitalize(), '');
    });
  });
}
