import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../models/app_user.dart';
import '../../providers/providers.dart';
import '../founder/founder_shell.dart';
import '../student/student_shell.dart';
import 'login_screen.dart';
import 'student_onboarding_screen.dart';

final onboardingSkippedProvider = NotifierProvider<_SkipNotifier, bool>(_SkipNotifier.new);

class _SkipNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void skip() => state = true;
}

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
            Text('SkillSync', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            SizedBox(height: 24),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
