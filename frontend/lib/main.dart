import 'package:flutter/material.dart';
import 'package:soen_390/models/route_result.dart';
import 'package:soen_390/screens/indoor/mappedin_map_screen.dart';
import 'package:soen_390/screens/waypoint/waypoint_selection_screens.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soen_390/services/auth_service.dart';
import 'package:soen_390/widgets/building_popup.dart';
import 'package:soen_390/widgets/indoor_navigation_button.dart';
import 'package:soen_390/widgets/nav_bar.dart';
import 'package:soen_390/widgets/search_bar.dart';
import 'package:soen_390/styles/theme.dart';
import 'package:soen_390/widgets/campus_switch_button.dart';
import 'package:soen_390/widgets/outdoor_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:soen_390/providers/service_providers.dart';
import 'package:soen_390/services/http_service.dart';
import 'package:soen_390/services/interfaces/route_service_interface.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:soen_390/services/google_maps_api_client.dart';
import 'package:soen_390/utils/location_service.dart';
import 'package:soen_390/screens/login/login_screen.dart';
import 'package:soen_390/screens/profile/profile_screen.dart';
import 'package:soen_390/screens/calendar/calendar_view.dart';
import 'package:soen_390/providers/navigation_provider.dart';
import 'package:soen_390/screens/indoor/mappedin_map_controller.dart';

/// The entry point of the application.
///
/// This function initializes the Riverpod provider scope and starts the app.
void main() async {
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print("problem with loading .env file");
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
    final authService = ref.watch(authServiceProvider);

    return MaterialApp(
      title: 'Flutter Demo',
      theme: appTheme,
      home: MyHomePage(
        title: 'Campus Map',
        routeService: routeService,
        httpService: httpService,
        authService: authService, // Inject AuthService
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

  // the service responsible for handling authentication
  final AuthService authService; // Add AuthService

  /// Creates an instance of `MyHomePage`.
  const MyHomePage(
      {super.key,
      required this.title,
      required this.routeService,
      required this.httpService,
      required this.authService});

  @override
  ConsumerState<MyHomePage> createState() => MyHomePageState();
}

class MyHomePageState extends ConsumerState<MyHomePage> {
  // Set initial campus to SGW (default campus)
  String selectedCampus = 'SGW';
  TextEditingController searchController = TextEditingController();
  late MappedinMapController _mappedinController;

  //int _selectedIndex = 0;
  LatLng currentLocation = const LatLng(45.497856, -73.579588);
  LatLng _userLiveLocation = const LatLng(5.497856, -73.579588);
  late LocationService _locationService;

  late BuildingPopUps _buildingPopUps;
  late GoogleMapsApiClient _mapsApiClient;

  List<LatLng> polylinePoints = [];
  final GlobalKey<MapWidgetState> _mapWidgetKey = GlobalKey<MapWidgetState>();

  bool isLoggedIn = false;
  bool isLoading = false;
  String? errorMessage;
  String? displayName;
  String? email;
  String? photoUrl;

  void _handleBuildingSelected(LatLng location) async {
    _mapWidgetKey.currentState?.selectMarker(location);
  }

  void handleCampusSelected(String campus) {
    setState(() {
      selectedCampus = campus;
    });
  }

  void handleLocationChanged(LatLng location) {
    setState(() {
      currentLocation = location;
    });
  }

  @override
  void initState() {
    super.initState();
    _mappedinController = MappedinMapController();
    _mapsApiClient = GoogleMapsApiClient(
      apiKey: dotenv.env['GOOGLE_MAPS_API_KEY']!,
      httpClient: widget.httpService,
    );
    _buildingPopUps = BuildingPopUps(mapsApiClient: _mapsApiClient);

    //This initializes the location service and listens for updates
    _locationService = LocationService.instance;
    _locationService.startUp().then((_) {
      _locationService.getLatLngStream().listen((LatLng location) {
        setState(() {
          _userLiveLocation = location;
        });
      });
    }).catchError((e) {});
  }

  @override
  void dispose() {
    super.dispose();
    _locationService.stopListening();
  }

  // void _onItemTapped(int index) {
  //   polylinePoints = [];
  //   setState(() {
  //     _selectedIndex = index;
  //   });
  // }

  Future<void> signIn() async {
    setState(() {
      isLoading = true;
    });

    final authClient = await widget.authService.signIn();
    if (authClient != null) {
      print("Sign-in successful");
      final user = widget.authService.googleSignIn.currentUser;
      setState(() {
        isLoggedIn = true;
        isLoading = false;
        displayName = user?.displayName ?? "User";
        email = user?.email ?? "No Email";
        photoUrl = user?.photoUrl;
      });
    } else {
      setState(() {
        isLoading = false;
        errorMessage = "Sign-in failed. Try again.";
      });
    }
  }

  void signOut() async {
    await widget.authService.signOut();
    setState(() {
      isLoggedIn = false;
      displayName = null;
      email = null;
      photoUrl = null;
    });
  }

  /// Updates the user's current location on the map.
  ///
  /// Called when the user selects a different campus location.
  void updateCampusLocation(LatLng newLocation) {
    setState(() {
      currentLocation = newLocation;
    });
  }

  void _openWaypointSelection() async {
    final buildingToCoordinatesService =
        ref.watch(buildingToCoordinatesProvider);
    final locationService = ref.watch(locationServiceProvider);
    final routeService = ref.watch(routeServiceProvider);
    final campusRouteChecker = ref.watch(campusRouteCheckerProvider);
    final waypointValidator = ref.watch(waypointValidatorProvider);
    final routeCacheManager = ref.watch(routeCacheManagerProvider);

    final RouteResult selectedRouteData = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WaypointSelectionScreen(
          routeService: routeService,
          geocodingService: buildingToCoordinatesService,
          locationService: locationService,
          campusRouteChecker: campusRouteChecker,
          waypointValidator: waypointValidator,
          routeCacheManager: routeCacheManager,
        ),
      ),
    );
    polylinePoints = selectedRouteData.routePoints;
    setState(() {
      polylinePoints = selectedRouteData.routePoints;
    });
  }

  /// Opens the Mappedin map screen.
  void _openMappedinMap() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MappedinMapScreen(
          controller: _mappedinController,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(navigationProvider).selectedIndex;
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
        index: selectedIndex,
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
                            key: _mapWidgetKey,
                            location: currentLocation,
                            userLocation: _userLiveLocation,
                            routeService: widget.routeService,
                            httpClient: widget.httpService,
                            mapsApiClient: _mapsApiClient,
                            buildingPopUps: _buildingPopUps,
                            routePoints: polylinePoints,
                            onRouteSelected: (RouteResult result) {
                              setState(() {
                                polylinePoints = result.routePoints;
                              });
                            },
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
                        selectedCampus: selectedCampus,
                        onSelectionChanged: handleCampusSelected,
                        onLocationChanged: handleLocationChanged,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -80,
                    left: 0,
                    child: SearchBarWidget(
                      controller: searchController,
                      onCampusSelected: handleCampusSelected,
                      onLocationFound: handleLocationChanged,
                      onBuildingSelected: _handleBuildingSelected,
                    ),
                  ),
                  Positioned(
                    bottom: 80,
                    right: 21,
                    child: ElevatedButton(
                      onPressed: _openWaypointSelection,
                      child: const Text("Find My Way"),
                    ),
                  ),
                  Positioned(
                    bottom: 150,
                    right: 21,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: _openMappedinMap,
                          child: const Text("Open Mappedin Map"),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () async {
                            final success = await _mappedinController.selectBuildingByName("Hall");
                            if (!success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Failed to switch to Hall Building')),
                              );
                            }
                            _openMappedinMap();
                          },
                          child: const Text("Show Hall"),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () async {
                            final success = await _mappedinController.selectBuildingByName("Library");
                            if (!success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Failed to switch to Library')),
                              );
                            }
                            _openMappedinMap();
                          },
                          child: const Text("Show LB"),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () async {
                            final success = await _mappedinController.navigateToRoom("MBS1.115");
                            if (!success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Failed to navigate to MBS1.115')),
                              );
                            }
                            _openMappedinMap();
                          },
                          child: const Text("Go to MBS1.115"),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () async {
                            final success = await _mappedinController.navigateToRoom("H907");
                            if (!success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Failed to navigate to H907')),
                              );
                            }
                            _openMappedinMap();
                          },
                          child: const Text("Go to H907"),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          isLoggedIn
              ? UserProfileScreen(
                  displayName: displayName,
                  email: email,
                  photoUrl: photoUrl,
                  onSignOut: signOut,
                  onViewCalendar: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CalendarScreen(authService: widget.authService),
                      ),
                    );
                  },
                )
              : LoginScreen(
                  onGoogleSignIn: signIn,
                  isLoading: isLoading,
                  errorMessage: errorMessage,
                ),
        ],
      ),
      bottomNavigationBar: NavBar(
        selectedIndex: selectedIndex,
        onItemTapped: (index) {
          ref.read(navigationProvider.notifier).setSelectedIndex(index);
        },
      ),
    );
  }
}
