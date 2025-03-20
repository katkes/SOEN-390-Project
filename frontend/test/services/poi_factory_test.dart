import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:soen_390/services/building_info_api.dart';
import 'package:soen_390/services/poi_factory.dart';

import 'poi_factory_test.mocks.dart'; // Update to correct path

@GenerateMocks([GoogleMapsApiClient])
void main() {
  group('PointOfInterestFactory', () {
    late MockGoogleMapsApiClient mockApiClient;
    late PointOfInterestFactory poiFactory;

    setUp(() {
      mockApiClient = MockGoogleMapsApiClient();
      poiFactory = PointOfInterestFactory(apiClient: mockApiClient);
    });

    test('createPointOfInterest returns correctly parsed POI', () async {
      const testPlaceId = 'test_place_123';
      const testImageUrl = 'https://example.com/image.jpg';

      final fakePlaceDetails = {
        'place_id': testPlaceId,
        'name': 'Test Place',
        'formatted_address': '123 Test St',
        'formatted_phone_number': '555-1234',
        'website': 'https://testplace.com',
        'types': ['restaurant'],
        'rating': 4.5,
        'price_level': 2,
        'opening_hours': {
          'weekday_text': ['Monday: 9AM–5PM']
        },
        'reviews': [],
        'editorial_summary': {'overview': 'Great test location'},
      };

      // Mock the API call
      when(mockApiClient.fetchPlaceDetailsById(testPlaceId))
          .thenAnswer((_) async => fakePlaceDetails);

      final poi = await poiFactory.createPointOfInterest(
        placeId: testPlaceId,
        imageUrl: testImageUrl,
      );

      // Verify the parsed values
      expect(poi.id, testPlaceId);
      expect(poi.name, 'Test Place');
      expect(poi.address, '123 Test St');
      expect(poi.contactPhone, '555-1234');
      expect(poi.website, 'https://testplace.com');
      expect(poi.rating, 4.5);
      expect(poi.priceRange, '\$\$'); // price_level: 2 -> $$
      expect(poi.imageUrl, testImageUrl);
      expect(poi.description, 'Great test location');
      expect(poi.category, 'Restaurant');
      expect(poi.openingHours?['Monday'], '9AM–5PM');

      // Ensure API was called once
      verify(mockApiClient.fetchPlaceDetailsById(testPlaceId)).called(1);
    });

    test('throws exception when API call fails', () async {
      const testPlaceId = 'invalid_id';

      when(mockApiClient.fetchPlaceDetailsById(testPlaceId))
          .thenThrow(Exception('API failure'));

      expect(
        () => poiFactory.createPointOfInterest(
          placeId: testPlaceId,
          imageUrl: 'https://example.com/fail.jpg',
        ),
        throwsException,
      );

      verify(mockApiClient.fetchPlaceDetailsById(testPlaceId)).called(1);
    });
  });
}
