import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/providers.dart';
import 'applicants_screen.dart';
import 'dashboard_screen.dart';
import 'startup_onboarding_screen.dart';
import 'startup_profile_screen.dart';

/// Founder experience shell. If the founder hasn't created their startup
/// profile yet, the whole shell is replaced by onboarding — driven by the
/// same startup stream, so completing the form flips straight into the app.
class FounderShell extends ConsumerStatefulWidget {
  const FounderShell({super.key});

  @override
  ConsumerState<FounderShell> createState() => _FounderShellState();
}

class _FounderShellState extends ConsumerState<FounderShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final startupAsync = ref.watch(myStartupProvider);

    return startupAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, _) => const StartupOnboardingScreen(),
      data: (startup) {
        if (startup == null) return const StartupOnboardingScreen();
        return Scaffold(
          body: IndexedStack(
            index: _index,
            children: [
              DashboardScreen(startup: startup),
              ApplicantsScreen(startup: startup),
              StartupProfileScreen(startup: startup),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _index,
            onTap: (i) => setState(() => _index = i),
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard_outlined),
                  activeIcon: Icon(Icons.dashboard_rounded),
                  label: 'Dashboard'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.people_outline_rounded),
                  activeIcon: Icon(Icons.people_rounded),
                  label: 'Applicants'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.storefront_outlined),
                  activeIcon: Icon(Icons.storefront_rounded),
                  label: 'Startup'),
            ],
          ),
        );
      },
    );
  }
}
