/*
A toggle button (UI) for the user to click and be able to toggle between Darkmode and lightmode themes.
Uses the theme provider to make the preference persists.
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soen_390/styles/theme.dart';
import "package:soen_390/providers/theme_provider.dart";

class DarkModeToggleButton extends ConsumerWidget {
  const DarkModeToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeData = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);

    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => themeNotifier.toggleTheme(),
          child: Text(
            themeData == darkAppTheme
                ? 'Switch to Light Mode'
                : 'Switch to Dark Mode',
          ),
        ),
      ),
    );
  }
}
