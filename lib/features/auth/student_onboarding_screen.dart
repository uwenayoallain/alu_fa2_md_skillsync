import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../core/widgets.dart';
import '../../providers/providers.dart';
import 'auth_gate.dart';

/// One-time step after student signup: pick skills so the home screen can
/// recommend matching opportunities from day one. Skippable — skills can
/// always be added later from the profile tab.
class StudentOnboardingScreen extends ConsumerStatefulWidget {
  const StudentOnboardingScreen({super.key});

  @override
  ConsumerState<StudentOnboardingScreen> createState() =>
      _StudentOnboardingScreenState();
}

class _StudentOnboardingScreenState
    extends ConsumerState<StudentOnboardingScreen> {
  List<String> _skills = [];
  bool _busy = false;

  Future<void> _save() async {
    final user = ref.read(currentUserProvider).value;
    if (user == null) return;
    if (_skills.isEmpty) {
      showAppSnackBar(context, 'Pick at least one skill (or skip for now).');
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(userRepositoryProvider).updateProfile(
            user.uid,
            name: user.name,
            bio: user.bio,
            skills: _skills,
          );
      // AuthGate sees the updated profile stream and moves to the shell.
    } catch (_) {
      if (mounted) {
        showAppSnackBar(context, 'Could not save skills. Try again.',
            error: true);
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final name =
        ref.watch(currentUserProvider).value?.name.split(' ').first;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () =>
                      ref.read(onboardingSkippedProvider.notifier).skip(),
                  child: const Text('Skip for now'),
                ),
              ),
              Text(
                name == null ? 'What are you good at?' : 'Hi $name.\nWhat are you good at?',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              const Text(
                'Your skills power the "Recommended for you" feed — the more '
                'accurate they are, the better your matches.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: SkillPicker(
                    selected: _skills,
                    suggestions: SuggestedSkills.all,
                    onChanged: (s) => setState(() => _skills = s),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                label: _skills.isEmpty
                    ? 'Select your skills'
                    : 'Continue with ${_skills.length} skill${_skills.length == 1 ? '' : 's'}',
                busy: _busy,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
