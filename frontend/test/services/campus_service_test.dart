import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:soen_390/services/campus_service.dart';
import 'package:soen_390/repositories/geojson_repository.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([MockSpec<GeoJsonRepository>()])
import 'campus_service_test.mocks.dart';

void main() {
  late CampusService campusService;
  late MockGeoJsonRepository mockRepository;

  // ✅ Mock data from your real GeoJSON files
  final mockCampusBoundaries = {
    "type": "Feature",
    "properties": {"id": 1, "unique_id": 1},
    "geometry": {
      "type": "MultiPolygon",
      "coordinates": [
        [
          [
            [-73.58626591761417, 45.496459491762501],
            [-73.586271264791804, 45.496525440286554],
            [-73.586258788044006, 45.4965700001001],
            [-73.586148279706407, 45.496715265092263],
            [-73.585827449048864, 45.496581585651619],
            [-73.585853293740726, 45.496500486790964],
            [-73.58626591761417, 45.496459491762501]
          ]
        ]
      ]
    }
  };

  final mockBuildingBoundaries = {
    "type": "FeatureCollection",
    "features": [
      {
        "type": "Feature",
        "properties": {"id": 1, "unique_id": 1},
        "geometry": {
          "type": "MultiPolygon",
          "coordinates": [
            [
              [
                [-73.58626591761417, 45.496459491762501],
                [-73.586271264791804, 45.496525440286554],
                [-73.586258788044006, 45.4965700001001],
                [-73.586148279706407, 45.496715265092263],
                [-73.585827449048864, 45.496581585651619],
                [-73.585853293740726, 45.496500486790964],
                [-73.58626591761417, 45.496459491762501]
              ]
            ]
          ]
        }
      }
    ]
  };

  final mockBuildingList = {
    "type": "FeatureCollection",
    "features": [
      {
        "type": "Feature",
        "properties": {
          "Campus": "SGW",
          "Building": "SB",
          "BuildingName": "SB Building",
          "Building Long Name": "Samuel Bronfman Building",
          "Address": "1590 Doctor Penfield",
          "Latitude": 45.4966,
          "Longitude": -73.58609,
          "id": 1,
          "unique_id": 1
        },
        "geometry": {
          "type": "Point",
          "coordinates": [-73.58609, 45.4966]
        }
      }
    ]
  };

  setUp(() {
    mockRepository = MockGeoJsonRepository();
    campusService = CampusService(repository: mockRepository);
  });

  group('CampusService.loadGeoJsonData', () {
    test('loads and sets all geojson data correctly', () async {
      // Arrange
      when(mockRepository.loadBuildingList())
          .thenAnswer((_) async => mockBuildingList);
      when(mockRepository.loadBuildingBoundaries())
          .thenAnswer((_) async => mockBuildingBoundaries);
      when(mockRepository.loadCampusBoundaries())
          .thenAnswer((_) async => mockCampusBoundaries);

      // Act
      await campusService.loadGeoJsonData();

      // Assert
      expect(campusService.buildingList, equals(mockBuildingList));
      expect(campusService.buildingBoundaries, equals(mockBuildingBoundaries));
      expect(campusService.campusBoundaries, equals(mockCampusBoundaries));
    });

    test('handles error during loading', () async {
      // Arrange
      when(mockRepository.loadBuildingList())
          .thenThrow(Exception("Failed to load"));
      when(mockRepository.loadBuildingBoundaries())
          .thenAnswer((_) async => mockBuildingBoundaries);
      when(mockRepository.loadCampusBoundaries())
          .thenAnswer((_) async => mockCampusBoundaries);

      // Act
      await campusService.loadGeoJsonData();

      // Assert
      expect(campusService.buildingList, isNull);
      expect(campusService.buildingBoundaries, isNotNull);
      expect(campusService.campusBoundaries, isNotNull);
    });
  });
}
