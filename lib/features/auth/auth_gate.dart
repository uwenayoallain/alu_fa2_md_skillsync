import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../models/app_user.dart';
import '../../providers/providers.dart';
import '../founder/founder_shell.dart';
import '../student/student_shell.dart';
import 'login_screen.dart';
import 'student_onboarding_screen.dart';

/// Local flag so students can skip skill onboarding for the session.
final onboardingSkippedProvider =
    NotifierProvider<_SkipNotifier, bool>(_SkipNotifier.new);

class _SkipNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void skip() => state = true;
}

/// Root router of the app. Watches the FirebaseAuth session and the user's
/// Firestore profile, and swaps the whole widget tree accordingly:
///
///   signed out            -> LoginScreen
///   student, no skills    -> StudentOnboardingScreen (skippable)
///   student               -> StudentShell
///   founder               -> FounderShell (which handles startup onboarding)
///
/// Because this is driven by streams, signing in/out or completing
/// onboarding transitions the UI automatically — no manual navigation.
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      loading: () => const _Splash(),
      error: (_, _) => const LoginScreen(),
      data: (session) {
        if (session == null) return const LoginScreen();

        final user = ref.watch(currentUserProvider);
        return user.when(
          // Brief moment between auth signup and the profile doc landing.
          loading: () => const _Splash(),
          error: (_, _) => const _Splash(),
          data: (profile) {
            if (profile == null) return const _Splash();
            if (profile.role == UserRole.founder) return const FounderShell();

            final skipped = ref.watch(onboardingSkippedProvider);
            if (profile.skills.isEmpty && !skipped) {
              return const StudentOnboardingScreen();
            }
            return const StudentShell();
          },
        );
      },
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.hub_rounded, size: 56, color: AppColors.primary),
            SizedBox(height: 14),
            Text('SkillSync',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            SizedBox(height: 24),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
