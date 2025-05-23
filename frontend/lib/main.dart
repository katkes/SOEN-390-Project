// ignore_for_file: unused_field, unused_import

import 'package:flutter/material.dart';
import 'package:soen_390/models/route_result.dart';
import 'package:soen_390/screens/waypoint/waypoint_selection_screens.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soen_390/services/auth_service.dart';
import 'package:soen_390/utils/navigation_utils.dart';
import 'package:soen_390/widgets/building_popup.dart';
import 'package:soen_390/widgets/nav_bar.dart';
import 'package:soen_390/widgets/search_bar.dart';
import 'package:soen_390/providers/theme_provider.dart' as tp;
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
import 'package:soen_390/screens/home/landing_page_screen.dart';

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
    final themeData = ref.watch(tp.themeProvider);

    return MaterialApp(
      title: 'Flutter Demo',
      theme: themeData,
      home: MyHomePage(
        title: 'Campus Map',
        routeService: routeService,
        httpService: httpService,
        authService: authService,
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
  final AuthService authService;

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
  // ignore : unused_field
  late MappedinMapController _mappedinController;
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
    await NavigationUtils.openWaypointSelection(
      context: context,
      ref: ref,
      onRouteSelected: (routePoints) {
        setState(() {
          polylinePoints = routePoints;
        });
      },
      inMain: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(navigationProvider).selectedIndex;

    return Scaffold(
      appBar: _buildAppBar(context),
      body: IndexedStack(
        index: selectedIndex,
        children: [
          const CUHomeScreen(), // Using the landing page screen here
          _buildMapScreen(context),
          isLoggedIn
              ? _buildUserProfileScreen(context)
              : _buildLoginScreen(context),
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

  String _getAppBarTitle(int selectedIndex) {
    switch (selectedIndex) {
      case 0:
        return 'Home';
      case 1:
        return 'Campus Map';
      case 2:
        return 'Profile';
      default:
        return widget.title;
    }
  }

  AppBar _buildAppBar(BuildContext context) {
    final selectedIndex = ref.watch(navigationProvider).selectedIndex;
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.menu, color: Colors.white, size: 30),
        onPressed: () {},
      ),
      backgroundColor: Theme.of(context).primaryColor,
      title: Text(_getAppBarTitle(selectedIndex),
          style: const TextStyle(color: Colors.white)),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.white, size: 30),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildMapScreen(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Stack(
          children: [
            _buildMapWidget(),
            _buildCampusSwitch(),
            _buildSearchBar(),
            _buildWaypointButton(context),
          ],
        );
      },
    );
  }

  Widget _buildMapWidget() {
    return Positioned(
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
    );
  }

  Widget _buildCampusSwitch() {
    return Positioned(
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
    );
  }

  Widget _buildSearchBar() {
    return Positioned(
      bottom: -80,
      left: 0,
      child: SearchBarWidget(
        controller: searchController,
        onCampusSelected: handleCampusSelected,
        onLocationFound: handleLocationChanged,
        onBuildingSelected: _handleBuildingSelected,
      ),
    );
  }

  ButtonStyle _elevatedButtonStyle(BuildContext context, bool isDarkMode) {
    return ElevatedButton.styleFrom(
      backgroundColor:
          isDarkMode ? const Color(0xFF6271EB) : Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  Widget _buildWaypointButton(BuildContext context) {
    final isDarkMode =
        ref.watch(tp.themeProvider).brightness == Brightness.dark;

    return Positioned(
      bottom: 80,
      right: 21,
      child: ElevatedButton(
        onPressed: _openWaypointSelection,
        style: _elevatedButtonStyle(context, isDarkMode),
        child: const Text(
          "Find My Way",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildUserProfileScreen(BuildContext context) {
    return UserProfileScreen(
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
    );
  }

  Widget _buildLoginScreen(BuildContext context) {
    return LoginScreen(
      onGoogleSignIn: signIn,
      isLoading: isLoading,
      errorMessage: errorMessage,
    );
  }
}
