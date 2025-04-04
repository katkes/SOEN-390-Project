import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soen_390/styles/theme.dart';
import "package:soen_390/styles/theme_provider.dart";


class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeData = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Dark Mode with Riverpod')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => themeNotifier.toggleTheme(),
          child: Text(
            themeData == darkAppTheme ? 'Switch to Light Mode' : 'Switch to Dark Mode',
          ),
        ),
      ),
    );
  }
}
