import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:soen_390/providers/navigation_provider.dart';

/// Test the NavigationProvider
/// The NavigationProvider is used to manage the navigation state of the app.
/// It is used to keep track of the current selected index of the navigation bar.
/// The NavigationProvider consists of a NavigationState and a NavigationNotifier.
/// This test file tests the NavigationProvider by checking that the initial selectedIndex is 0
/// and that the selectedIndex is updated correctly when calling setSelectedIndex.
///
void main() {
  test('Initial NavigationState has selectedIndex 0', () {
    // Create a container for testing the provider
    final container = ProviderContainer();

    // Get the initial state of the navigation
    final navState = container.read(navigationProvider);

    // Check that the initial selectedIndex is 0
    expect(navState.selectedIndex, 0);

    // Dispose of the container after the test
    container.dispose();
  });
  test('setSelectedIndex updates selectedIndex', () {
    // Create a container for testing the provider
    final container = ProviderContainer();

    // Initially, the selectedIndex should be 0
    final navStateBefore = container.read(navigationProvider);
    expect(navStateBefore.selectedIndex, 0);

    // Update the selectedIndex to 1
    container.read(navigationProvider.notifier).setSelectedIndex(1);

    // Check that the selectedIndex is updated to 1
    final navStateAfter = container.read(navigationProvider);
    expect(navStateAfter.selectedIndex, 1);

    // Dispose of the container after the test
    container.dispose();
  });
}
