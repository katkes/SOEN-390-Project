import 'package:flutter/material.dart';

/// Symbolic constants for navigation labels
const String kNavHomeLabel = 'Home';
const String kNavMapLabel = 'Map';
const String kNavProfileLabel = 'Profile';

/// Symbolic constants for navigation icons
const IconData kNavHomeIcon = Icons.home;
const IconData kNavMapIcon = Icons.map;
const IconData kNavProfileIcon = Icons.person;

const IconData kNavHomeOutline = Icons.home_outlined;
const IconData kNavMapOutline = Icons.map_outlined;
const IconData kNavProfileOutline = Icons.person_outline;

/// Centralized list of navigation destinations
final List<NavigationDestination> kNavDestinations = [
  const NavigationDestination(
    selectedIcon: Icon(kNavHomeIcon),
    icon: Icon(kNavHomeOutline),
    label: kNavHomeLabel,
  ),
  const NavigationDestination(
    selectedIcon: Icon(kNavMapIcon),
    icon: Icon(kNavMapOutline),
    label: kNavMapLabel,
  ),
  const NavigationDestination(
    selectedIcon: Icon(kNavProfileIcon),
    icon: Icon(kNavProfileOutline),
    label: kNavProfileLabel,
  ),
];

/// Bottom navigation bar with dynamic destinations
class NavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const NavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      onDestinationSelected: onItemTapped,
      selectedIndex: selectedIndex,
      destinations: kNavDestinations,
    );
  }
}
