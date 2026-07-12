import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../core/widgets.dart';
import '../../models/startup.dart';
import '../../providers/providers.dart';

/// First-run flow for founders: register the startup profile.
/// The profile is created with `verified: false`; an ALU admin flips the
/// flag from the Firebase console after checking the venture is recognised.
class StartupOnboardingScreen extends ConsumerStatefulWidget {
  const StartupOnboardingScreen({super.key});

  @override
  ConsumerState<StartupOnboardingScreen> createState() =>
      _StartupOnboardingScreenState();
}

class _StartupOnboardingScreenState
    extends ConsumerState<StartupOnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _description = TextEditingController();
  final _mission = TextEditingController();
  String _category = OpportunityCategories.all.first;
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _mission.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = ref.read(authStateProvider).value;
    if (auth == null) return;
    setState(() => _busy = true);
    try {
      await ref.read(startupRepositoryProvider).create(Startup(
            id: '',
            ownerId: auth.uid,
            name: _name.text.trim(),
            category: _category,
            description: _description.text.trim(),
            mission: _mission.text.trim(),
          ));
      // FounderShell watches the startup stream and switches automatically.
    } catch (_) {
      if (mounted) {
        setState(() => _busy = false);
        showAppSnackBar(context, 'Could not create startup profile.',
            error: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register your startup'),
        actions: [
          IconButton(
            tooltip: 'Log out',
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => ref.read(authRepositoryProvider).signOut(),
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'Tell students about your venture',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              const Text(
                'This profile is shown on every opportunity you post.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                    labelText: 'Startup name',
                    prefixIcon: Icon(Icons.storefront_outlined)),
                validator: (v) => Validators.required(v, 'Startup name'),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(
                    labelText: 'Primary category',
                    prefixIcon: Icon(Icons.category_outlined)),
                items: [
                  for (final c in OpportunityCategories.all)
                    DropdownMenuItem(value: c, child: Text(c)),
                ],
                onChanged: (v) => setState(() => _category = v!),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _description,
                maxLines: 4,
                maxLength: 400,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                    labelText: 'What does your startup do?',
                    alignLabelWithHint: true),
                validator: (v) => Validators.minLength(v, 30, 'Description'),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _mission,
                maxLines: 2,
                maxLength: 150,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                    labelText: 'Mission (optional)', alignLabelWithHint: true),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.infoSoft,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.verified_user_outlined, color: AppColors.info),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'New startups are reviewed by the ALU venture team '
                        'before they can post opportunities. You can set up '
                        'everything else in the meantime.',
                        style: TextStyle(fontSize: 13, color: AppColors.info),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                  label: 'Create startup profile',
                  busy: _busy,
                  onPressed: _create),
            ],
          ),
        ),
      ),
    );
  }
}
