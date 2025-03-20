import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:latlong2/latlong.dart';
import 'package:soen_390/models/places.dart';
import 'package:soen_390/screens/outdoor_poi/outdoor_poi_detail_screen.dart';
import 'package:soen_390/services/google_poi_service.dart';
import 'package:soen_390/services/poi_factory.dart';
import 'package:soen_390/utils/location_service.dart';
import 'package:soen_390/widgets/poi_list_view.dart';
import 'package:soen_390/widgets/poi_search_bar.dart';
import 'package:soen_390/widgets/poi_type_selector.dart';

/// A screen widget that allows users to search for nearby points of interest (POIs)
/// either by using their current location or by searching an address manually.
///
/// Users can also filter POIs based on type (e.g., restaurants, parks, etc.).
/// The screen displays a list of places fetched from a Google POI service.
class PlaceSearchScreen extends StatefulWidget {
  /// Service responsible for obtaining the device's location.
  final LocationService locationService;

  /// Service responsible for fetching POIs from Google APIs.
  final GooglePOIService poiService;

  //
  final PointOfInterestFactory poiFactory;

  final void Function(String name, double lat, double lng)? onSetDestination;

  /// Constructs a [PlaceSearchScreen] with required [locationService] and [poiService].
  ///
  /// These are injected for better testability and separation of concerns.
  const PlaceSearchScreen({
    required this.locationService,
    required this.poiService,
    required this.poiFactory,
    this.onSetDestination,
    super.key,
  });

  @override
  _PlaceSearchScreenState createState() => _PlaceSearchScreenState();
}

/// State class for [PlaceSearchScreen], managing user interactions, data fetching,
/// and UI state updates.
class _PlaceSearchScreenState extends State<PlaceSearchScreen> {
  /// Instance of [LocationService], initialized from widget for DI.
  late final LocationService locationService;

  /// Instance of [GooglePOIService], initialized from widget for DI.
  late final GooglePOIService poiService;

  /// Latitude of the current or searched location.
  double? _latitude;

  /// Longitude of the current or searched location.
  double? _longitude;

  /// Currently selected POI type filter.
  String _selectedType = '';

  /// List of fetched places based on current location and type.
  List<Place> _places = [];

  /// Indicates if data fetching is in progress (used to show loading indicator).
  bool _isLoading = false;

  /// Controller for the search bar input.
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize services from the widget for dependency injection.
    locationService = widget.locationService;
    poiService = widget.poiService;
  }

  /// Displays a [SnackBar] with the provided [message].
  ///
  /// Useful for showing user-friendly error messages or status updates.
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  /// Updates the stored location to the given [lat] and [lng] coordinates.
  ///
  /// If a POI type is already selected, triggers fetching places for the new location.
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
  ///
  /// Shows a [SnackBar] on failure.
  void _useCurrentLocation() async {
    try {
      await locationService.startUp();
      LatLng pos = locationService.convertPositionToLatLng(
        await locationService.getCurrentLocationAccurately(),
      );
      _updateLocation(pos.latitude, pos.longitude);
    } catch (e) {
      print("Error getting current location: $e");
      _showSnackBar("Unable to fetch current location");
    }
  }

  /// Handles a location search event with [address], [lat], and [lng] parameters.
  ///
  /// Updates the stored location and triggers POI fetching if a type is selected.
  void _handleLocationSearch(String address, double lat, double lng) {
    _updateLocation(lat, lng);
  }

  /// Fetches places of the selected [type] near the current location.
  ///
  /// Shows a loading indicator while fetching and handles errors gracefully.
  void _onTypeSelected(String type) async {
    if (_latitude == null || _longitude == null) {
      print("Location not set. Cannot fetch POIs.");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      List<Place> fetchedPlaces = await poiService.getNearbyPlaces(
        latitude: _latitude!,
        longitude: _longitude!,
        type: type,
        radius: 1500,
      );

      setState(() {
        _selectedType = type;
        _places = fetchedPlaces;
      });
    } catch (e) {
      print("Error fetching POIs: $e");
      _showSnackBar("Failed to fetch places");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handlePlaceTap(Place place) async {
    print('--- _handlePlaceTap started ---');

    setState(() {
      _isLoading = true;
    });

    try {
      final imageUrl =
          place.thumbnailPhotoUrl(dotenv.env['GOOGLE_PLACES_API_KEY'] ?? '') ??
              '';

      final poi = await widget.poiFactory.createPointOfInterest(
        placeId: place.placeId,
        imageUrl: imageUrl,
      );

      if (!mounted) return;

      // 👉 Await result from POIDetailScreen
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PoiDetailScreen(poi: poi),
        ),
      );

      if (result != null && result is Map<String, dynamic>) {
        widget.onSetDestination?.call(
          result['name'] as String,
          result['lat'] as double,
          result['lng'] as double,
        );

        Navigator.pop(
            context); // Close PlaceSearchScreen and send result back up
      }
    } catch (e) {
      print('Error creating POI: $e');
      _showSnackBar("Failed to load place details.");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }

    print('--- _handlePlaceTap completed ---');
  }

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
      appBar: AppBar(title: const Text('Explore Nearby')),
      body: Column(
        children: [
          POISearchBar(
            controller: _searchController,
            onSearch: _handleLocationSearch,
            onUseCurrentLocation: _useCurrentLocation,
            googleApiKey: dotenv.env['GOOGLE_PLACES_API_KEY'] ?? '',
          ),
          POITypeSelector(onTypeSelected: _onTypeSelected),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : POIListView(
                    places: _places,
                    apiKey: dotenv.env['GOOGLE_PLACES_API_KEY'] ?? '',
                    onPlaceTap: _handlePlaceTap, // <-- ADD THIS
                  ),
          ),
        ],
      ),
    );
  }
}
