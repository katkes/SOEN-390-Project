// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:soen_390/providers/navigation_provider.dart';
import 'package:soen_390/styles/theme.dart';
import 'package:soen_390/providers/theme_provider.dart' as tp;
import 'package:soen_390/screens/indoor/mappedin_map_screen.dart';
import 'package:soen_390/screens/indoor/mappedin_map_controller.dart';
import 'package:soen_390/screens/waypoint/waypoint_selection_screens.dart';
import 'package:soen_390/providers/service_providers.dart';
import 'package:soen_390/models/route_result.dart';


class CUHomeScreen extends ConsumerStatefulWidget {
  const CUHomeScreen({super.key});

  @override
  ConsumerState<CUHomeScreen> createState() => _CUHomeScreenState();
}

class _CUHomeScreenState extends ConsumerState<CUHomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late MappedinMapController _mappedinController;
  List<LatLng> polylinePoints = [];

  // ignore: unused_field
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      ),
    );
    _mappedinController = MappedinMapController();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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

    setState(() {
      polylinePoints = selectedRouteData.routePoints;
    });
    
    // Switch to map screen after selecting waypoints
    ref.read(navigationProvider.notifier).setSelectedIndex(1);
  }

  void _openMappedinMap({String? buildingName, String? roomName}) async {
    final messenger = ScaffoldMessenger.of(context);
    bool success = true;
    
    if (buildingName != null) {
      success = await _mappedinController.selectBuildingByName(buildingName);
      if (!success) {
        messenger.showSnackBar(
          SnackBar(content: Text('Failed to switch to $buildingName Building')),
        );
        return;
      }
    }
    
    if (roomName != null) {
      success = await _mappedinController.navigateToRoom(roomName);
      if (!success) {
        messenger.showSnackBar(
          SnackBar(content: Text('Failed to navigate to $roomName')),
        );
        return;
      }
    }
    
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
    // Use the theme provider from the main app
    final themeMode = ref.watch(tp.themeProvider);
    final isDarkMode = themeMode.brightness == Brightness.dark;

    // ignore: unused_local_variable
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [
                    const Color(0xFF1E1E2E),
                    const Color(0xFF2D2D42),
                  ]
                : [
                    const Color.fromARGB(255, 238, 239, 243),
                    const Color(0xFFE6EEFF),
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Text(
                        'CU Explorer',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode
                              ? Colors.white
                              : const Color(0xFF324172),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        isDarkMode ? Icons.light_mode : Icons.dark_mode,
                        color: isDarkMode ? Colors.amber : Colors.blueGrey,
                      ),
                      onPressed: () {
                        ref.read(tp.themeProvider.notifier).toggleTheme();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      children: [
                        _buildFeatureCard(
                          context,
                          'Campus Map',
                          Icons.map_outlined,
                          'Explore campus locations and navigate easily',
                          () => ref
                              .read(navigationProvider.notifier)
                              .setSelectedIndex(1),
                          isDarkMode,
                        ),
                        _buildFeatureCard(
                          context,
                          'Find My Way',
                          Icons.directions_walk,
                          'Get directions between buildings',
                          _openWaypointSelection,
                          isDarkMode,
                        ),
                        _buildFeatureCard(
                          context,
                          'Indoor Maps',
                          Icons.home_outlined,
                          'Explore building interiors',
                          () => _openMappedinMap(buildingName: "Hall"),
                          isDarkMode,
                        ),
                        _buildFeatureCard(
                          context,
                          'Calendar',
                          Icons.calendar_today,
                          'View your class schedule',
                          () {
                            ref
                                .read(navigationProvider.notifier)
                                .setSelectedIndex(2);
                          },
                          isDarkMode,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: _buildCurrentLocationCard(isDarkMode),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    IconData iconData,
    String description,
    VoidCallback onTap,
    bool isDarkMode,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF2A2D3E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDarkMode

                  ? Colors.black.withOpacity(0.3)
          
                  : Colors.grey.withOpacity(0.1),
              spreadRadius: 0,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              iconData,
              size: 40,
              color: isDarkMode
                  ? const Color(0xFF6271EB)
                  : const Color(0xFF324172),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : appTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: isDarkMode ? Colors.white60 : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentLocationCard(bool isDarkMode) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: isDarkMode
           
            ? const Color(0xFF2A2D3E).withOpacity(0.8)

            : Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
               
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? const Color(0xFF6271EB).withOpacity(0.2)
                  : const Color(0xFFEDF1FD),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.near_me,
              color: isDarkMode
                  ? const Color(0xFF6271EB)
                  : const Color(0xFF324172),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Location',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : appTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'SGW Campus Area',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode ? Colors.white70 : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(navigationProvider.notifier).setSelectedIndex(1);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isDarkMode ? const Color(0xFF6271EB) : appTheme.primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text(
              'View Map',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}