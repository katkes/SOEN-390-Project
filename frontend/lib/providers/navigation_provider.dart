import 'package:flutter_riverpod/flutter_riverpod.dart';

///This provider is used to manage the navigation state of the app.
///It is used to keep track of the current selected index of the navigation bar.

// State model for the navigation
class NavigationState {
  final int selectedIndex;

  NavigationState({required this.selectedIndex});

  NavigationState copyWith({int? selectedIndex}) {
    return NavigationState(
      selectedIndex: selectedIndex ?? this.selectedIndex,
    );
  }
}

// Notifier that handles the navigation state changes
class NavigationNotifier extends StateNotifier<NavigationState> {
  NavigationNotifier() : super(NavigationState(selectedIndex: 0));

  void setSelectedIndex(int index) {
    state = state.copyWith(selectedIndex: index);
  }
}

// Provider that exposes the navigation state
final navigationProvider =
    StateNotifierProvider<NavigationNotifier, NavigationState>((ref) {
  return NavigationNotifier();
});
