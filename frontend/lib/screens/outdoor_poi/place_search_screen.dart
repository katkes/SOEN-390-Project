import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:latlong2/latlong.dart';
import 'package:soen_390/models/places.dart';
import 'package:soen_390/screens/outdoor_poi/outdoor_poi_detail_screen.dart';
import 'package:soen_390/services/google_poi_service.dart';
import 'package:soen_390/services/poi_factory.dart';
import 'package:soen_390/styles/theme.dart';
import 'package:soen_390/utils/location_service.dart';
import 'package:soen_390/widgets/poi_list_view.dart';
import 'package:soen_390/widgets/poi_search_bar.dart';
import 'package:soen_390/widgets/poi_type_selector.dart';

/// A screen widget that allows users to search for nearby Points of Interest (POIs)
/// either by using their current location or by searching for a specific address.
///
/// Functionality Flow:
/// 1. User can enter a location or use current location via [POISearchBar].
/// 2. The app fetches and updates location coordinates.
/// 3. User selects a POI type using [POITypeSelector].
/// 4. The app queries nearby places via [GooglePOIService].
/// 5. Results are displayed in a scrollable list using [POIListView].
/// 6. Tapping a POI opens a detailed screen, with an option to set destination.
class PlaceSearchScreen extends StatefulWidget {
  final LocationService locationService;
  final GooglePOIService poiService;
  final PointOfInterestFactory poiFactory;
  final void Function(String name, double lat, double lng)? onSetDestination;

  const PlaceSearchScreen({
    required this.locationService,
    required this.poiService,
    required this.poiFactory,
    this.onSetDestination,
    super.key,
  });

  @override
  // ignore: library_private_types_in_public_api
  _PlaceSearchScreenState createState() => _PlaceSearchScreenState();
}

/// State class for [PlaceSearchScreen], managing user interactions, data fetching,
/// and UI state updates.
class _PlaceSearchScreenState extends State<PlaceSearchScreen> {
  late final LocationService locationService;
  late final GooglePOIService poiService;

  double? _latitude;
  double? _longitude;
  String _selectedType = '';
  List<Place> _places = [];
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  bool _isPOISelectorVisible = false;

  /// Getter for accessing the Google API key.
  String get _googleApiKey => dotenv.env['GOOGLE_PLACES_API_KEY'] ?? '';

  @override
  void initState() {
    super.initState();
    locationService = widget.locationService;
    poiService = widget.poiService;
  }

  /// Toggles the visibility of the POI Type Selector widget.
  void _togglePOISelectorVisibility() {
    setState(() {
      _isPOISelectorVisible = !_isPOISelectorVisible;
    });
  }

  /// Displays a [SnackBar] with the provided [message].
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  /// Logs and displays errors consistently.
  void _handleError(String logMessage, String userMessage) {
    print(logMessage);
    _showSnackBar(userMessage);
  }

  /// Updates the stored location to the given [lat] and [lng] coordinates.
  void _updateLocation(double lat, double lng) {
    setState(() {
      _latitude = lat;
      _longitude = lng;
    });

    if (_selectedType.isNotEmpty) {
      _onTypeSelected(_selectedType);
    }
  }

  /// Attempts to get the user's current location and updates the stored location.
  Future<void> _useCurrentLocation(
      Function(double lat, double lng)? onCoordsObtained) async {
    try {
      await locationService.startUp();
      LatLng pos = locationService.convertPositionToLatLng(
        await locationService.getCurrentLocationAccurately(),
      );
      _updateLocation(pos.latitude, pos.longitude);

      if (onCoordsObtained != null) {
        onCoordsObtained(pos.latitude, pos.longitude);
      }
    } catch (e) {
      _handleError("Error getting current location: $e",
          "Unable to fetch current location");
    }
  }

  /// Handles a location search event with [address], [lat], and [lng] parameters.
  void _handleLocationSearch(String address, double lat, double lng) {
    _updateLocation(lat, lng);
  }

  /// Fetches places of the selected [type] near the current location.
  Future<void> _onTypeSelected(String type) async {
    if (_latitude == null || _longitude == null) {
      print("Location not set. Cannot fetch POIs.");
      return;
    }

    setState(() {
      _isLoading = true;
      _selectedType = type;
    });

    try {
      final fetchedPlaces = await poiService.getNearbyPlaces(
        latitude: _latitude!,
        longitude: _longitude!,
        type: type,
        radius: 1500,
      );

      setState(() {
        _places = fetchedPlaces;
      });

      if (fetchedPlaces.isEmpty) {
        print("No places found for type: $type");
      }
    } catch (e) {
      _handleError("Error fetching POIs: $e", "Failed to fetch places");
      setState(() {
        _places = [];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Handles tapping a place to view details and potentially set it as a destination.
  Future<void> _handlePlaceTap(Place place) async {
    print('--- _handlePlaceTap started ---');
    setState(() {
      _isLoading = true;
    });

    try {
      final imageUrl = place.thumbnailPhotoUrl(_googleApiKey) ?? '';
      final poi = await widget.poiFactory.createPointOfInterest(
        placeId: place.placeId,
        imageUrl: imageUrl,
      );

      if (!mounted) return;

      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PoiDetailScreen(poi: poi)),
      );

      if (result != null && result is Map<String, dynamic>) {
        widget.onSetDestination?.call(
          result['name'] as String,
          result['lat'] as double,
          result['lng'] as double,
        );
        if (mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      _handleError('Error creating POI: $e', "Failed to load place details.");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }

    print('--- _handlePlaceTap completed ---');
  }

  /// For testing purposes: Allows setting the places manually.
  void testSetPlaces(List<Place> places) {
    setState(() {
      _places = places;
    });
  }

  /// Builds the UI of the [PlaceSearchScreen], including:
  /// - A search bar for manual location input or using current location.
  /// - A POI type selector to filter places.
  /// - A list view displaying nearby places or a loading indicator.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore Nearby'),
        backgroundColor: appTheme.primaryColor,
      ),
      body: Column(
        children: [
          POISearchBar(
            controller: _searchController,
            onSearch: _handleLocationSearch,
            onUseCurrentLocation: (callback) async {
              await _useCurrentLocation(callback);
            },
            googleApiKey: _googleApiKey,
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ElevatedButton(
              onPressed: _togglePOISelectorVisibility,
              child: Text(_isPOISelectorVisible
                  ? 'Hide Place Categories'
                  : 'Show Place Categories'),
            ),
          ),
          Visibility(
            visible: _isPOISelectorVisible,
            child: POITypeSelector(onTypeSelected: _onTypeSelected),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : POIListView(
                    places: _places,
                    apiKey: _googleApiKey,
                    onPlaceTap: _handlePlaceTap,
                  ),
          ),
        ],
      ),
    );
  }
}
