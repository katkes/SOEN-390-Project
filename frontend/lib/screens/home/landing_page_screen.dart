import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soen_390/providers/navigation_provider.dart';
import 'package:soen_390/styles/theme.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.light);

  void toggleTheme() {
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }
}

class CUHomeScreen extends ConsumerStatefulWidget {
  const CUHomeScreen({super.key});

  @override
  ConsumerState<CUHomeScreen> createState() => _CUHomeScreenState();
}

class _CUHomeScreenState extends ConsumerState<CUHomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
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

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;
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
                        ref.read(themeProvider.notifier).toggleTheme();
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
                          () {
                            ref
                                .read(navigationProvider.notifier)
                                .setSelectedIndex(1);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Tap "Find My Way" on the map screen')),
                            );
                          },
                          isDarkMode,
                        ),
                        _buildFeatureCard(
                          context,
                          'Indoor Maps',
                          Icons.home_outlined,
                          'Explore building interiors',
                          () {
                            ref
                                .read(navigationProvider.notifier)
                                .setSelectedIndex(1);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Use building controls on the map screen')),
                            );
                          },
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
              // ignore: deprecated_member_use
              color: isDarkMode
                  // ignore: deprecated_member_use
                  ? Colors.black.withOpacity(0.3)
                  // ignore: deprecated_member_use
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
            // ignore: deprecated_member_use
            ? const Color(0xFF2A2D3E).withOpacity(0.8)
            // ignore: deprecated_member_use
            : Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: isDarkMode
                // ignore: deprecated_member_use
                ? Colors.black.withOpacity(0.3)
                // ignore: deprecated_member_use
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
              // ignore: deprecated_member_use
              color: isDarkMode
                  // ignore: deprecated_member_use
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
          TextButton(
            onPressed: () {
              ref.read(navigationProvider.notifier).setSelectedIndex(1);
            },
            child: Text(
              'View Map',
              style: TextStyle(
                color: isDarkMode
                    ? const Color(0xFF6271EB)
                    : appTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
