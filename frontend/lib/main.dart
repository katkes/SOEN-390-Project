import 'package:flutter/material.dart';
import 'package:soen_390/screens/waypoint/waypoint_selection_screens.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soen_390/widgets/nav_bar.dart';
import 'package:soen_390/widgets/search_bar.dart';
import 'package:soen_390/styles/theme.dart';
import 'package:soen_390/widgets/campus_switch_button.dart';
import 'package:soen_390/widgets/indoor_navigation_button.dart';
import 'package:soen_390/widgets/outdoor_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:soen_390/providers/service_providers.dart'; // Import providers
import 'package:soen_390/services/http_service.dart'; // Import HttpService
import 'package:soen_390/services/interfaces/route_service_interface.dart'; // Import IRouteService
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:soen_390/services/building_info_api.dart';
import "package:soen_390/utils/location_service.dart";

/// The entry point of the application.
///
/// This function initializes the Riverpod provider scope and starts the app.
void main() async {
   WidgetsFlutterBinding.ensureInitialized();
  try{
    await dotenv.load(fileName: "..env");

  } catch (e) {
    print("An error occurred when loading the ..env file: $e");
  }

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

/// The root widget of the application.
///
/// This widget is responsible for initializing the app theme and injecting
/// dependencies into `MyHomePage` using Riverpod.
class MyApp extends ConsumerWidget {
  /// Creates an instance of `MyApp`.
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Fetch dependencies using Riverpod providers.
    final routeService = ref.watch(routeServiceProvider);
    final httpService = ref.watch(httpServiceProvider);

    return MaterialApp(
      title: 'Flutter Demo',
      theme: appTheme,
      home: MyHomePage(
        title: 'Campus Map',
        routeService: routeService,
        httpService: httpService,
      ),
    );
  }
}

/// The main home page of the application.
///
/// This page contains the navigation logic, a campus map, a search bar,
/// and UI elements for interacting with the app.
class MyHomePage extends ConsumerStatefulWidget {
  /// The title displayed on the app bar.
  final String title;

  /// The service responsible for handling routing logic.
  final IRouteService routeService;

  /// The service responsible for managing HTTP requests.
  final HttpService httpService;

  /// Creates an instance of `MyHomePage`.
  const MyHomePage({
    super.key,
    required this.title,
    required this.routeService,
    required this.httpService,
  });

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
  /// Controls the search bar input.
  TextEditingController searchController = TextEditingController();

  /// The currently selected index for the bottom navigation bar.
  int _selectedIndex = 0;

  /// The user's current location on the map.
  LatLng _currentLocation = const LatLng(45.497856, -73.579588);
  // http.Client? _httpClient;
  late BuildingPopUps _buildingPopUps;
  late GoogleMapsApiClient _mapsApiClient;

  @override
  void initState() {
    super.initState();
    _mapsApiClient = GoogleMapsApiClient(
        apiKey: dotenv.env['GOOGLE_MAPS_API_KEY']!,
        client: widget.httpService.client);
    _buildingPopUps = BuildingPopUps(mapsApiClient: _mapsApiClient);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  /// Updates the user's current location on the map.
  ///
  /// Called when the user selects a different campus location.
  void _updateCampusLocation(LatLng newLocation) {
    setState(() {
      _currentLocation = newLocation;
    });
  }

  void _openWaypointSelection() {
    final buildingToCoordinatesService =
        ref.watch(buildingToCoordinatesProvider);
    final locationService = ref.watch(locationServiceProvider);
    final routeService = ref.watch(routeServiceProvider);

    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => WaypointSelectionScreen(
                routeService: routeService,
                geocodingService: buildingToCoordinatesService,
                locationService: locationService,
              )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white, size: 30),
          onPressed: () {},
        ),
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(widget.title, style: const TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white, size: 30),
            onPressed: () {},
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          const Center(child: Text('Home Page')),
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return Stack(
                children: [
                  Positioned(
                    bottom: 5,
                    left: 10,
                    right: 10,
                    child: Center(
                      child: SizedBox(
                        width: 460,
                        height: 570,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: MapWidget(
                            location: _currentLocation,
                            routeService: widget.routeService,
                            httpClient: widget.httpService.client,
                            mapsApiClient: _mapsApiClient,
                            buildingPopUps: _buildingPopUps,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: CampusSwitch(
                        onSelectionChanged: (selectedCampus) {},
                        onLocationChanged: _updateCampusLocation,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -80,
                    left: 0,
                    child: SearchBarWidget(controller: searchController),
                  ),
                  const Positioned(
                    bottom: 10,
                    right: 21,
                    child: IndoorTrigger(),
                  ),
                  Positioned(
                    bottom: 80,
                    right: 21,
                    child: ElevatedButton(
                      onPressed: _openWaypointSelection,
                      child: const Text("Find My Way"),
                    ),
                  ),
                ],
              );
            },
          ),
          const Center(child: Text('Profile Page')),
        ],
      ),
      bottomNavigationBar: NavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
