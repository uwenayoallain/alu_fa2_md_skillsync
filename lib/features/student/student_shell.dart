import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'applications_screen.dart';
import 'explore_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';

/// Current bottom-nav tab. Held in Riverpod (not widget state) so other
/// screens can deep-link into a tab — e.g. tapping a category on Home
/// applies a filter and jumps straight to Explore.
final studentTabProvider =
    NotifierProvider<StudentTabNotifier, int>(StudentTabNotifier.new);

class StudentTabNotifier extends Notifier<int> {
  @override
  int build() => 0;
  void go(int index) => state = index;
}

/// Bottom-navigation scaffold for the student experience.
/// Uses an IndexedStack so each tab keeps its scroll position and state.
class StudentShell extends ConsumerWidget {
  const StudentShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(studentTabProvider);
    return Scaffold(
      body: IndexedStack(
        index: index,
        children: const [
          HomeScreen(),
          ExploreScreen(),
          ApplicationsScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: ref.read(studentTabProvider.notifier).go,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.search_rounded), label: 'Explore'),
          BottomNavigationBarItem(
              icon: Icon(Icons.assignment_outlined),
              activeIcon: Icon(Icons.assignment_rounded),
              label: 'Applications'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profile'),
        ],
      ),
    );
  }
}
