import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../core/widgets.dart';
import '../../models/app_user.dart';
import '../../models/application.dart';
import '../../providers/providers.dart';
import 'widgets/opportunity_card.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final apps = ref.watch(myApplicationsProvider).value ?? [];

    return SafeArea(
      child: AsyncView(
        value: userAsync,
        builder: (user) {
          if (user == null) return const SizedBox.shrink();
          final shortlisted = apps.where((a) => a.status == ApplicationStatus.shortlisted).length;
          final accepted = apps.where((a) => a.status == ApplicationStatus.accepted).length;

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              const Center(
                child: Text('Profile', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              ),
              const SizedBox(height: 20),
              Center(child: InitialsAvatar(user.name, size: 84)),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  user.name,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
              ),
              Center(
                child: Text(user.email, style: const TextStyle(color: AppColors.textSecondary)),
              ),
              if (user.bio.isNotEmpty) ...[
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    user.bio,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13.5, height: 1.4),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    children: [
                      _Stat(count: apps.length, label: 'Applications'),
                      _Stat(count: shortlisted, label: 'Shortlisted'),
                      _Stat(count: accepted, label: 'Accepted'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (user.skills.isNotEmpty) ...[
                const SectionHeader('My skills'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [for (final s in user.skills) TagChip(s)],
                ),
                const SizedBox(height: 20),
              ],
              Card(
                child: Column(
                  children: [
                    MenuTile(
                      icon: Icons.edit_outlined,
                      label: 'Edit profile & skills',
                      onTap: () => Navigator.of(
                        context,
                      ).push(MaterialPageRoute(builder: (_) => EditProfileScreen(user: user))),
                    ),
                    const Divider(height: 1, color: AppColors.outline),
                    MenuTile(
                      icon: Icons.bookmark_outline_rounded,
                      label: 'Saved opportunities (${user.savedOpportunityIds.length})',
                      onTap: () => Navigator.of(
                        context,
                      ).push(MaterialPageRoute(builder: (_) => const SavedOpportunitiesScreen())),
                    ),
                    const Divider(height: 1, color: AppColors.outline),
                    MenuTile(
                      icon: Icons.logout_rounded,
                      label: 'Log out',
                      color: AppColors.danger,
                      onTap: () => _confirmLogout(context, ref),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    if (await confirmDanger(
      context,
      title: 'Log out?',
      content: 'You can sign back in anytime.',
      cancel: 'Cancel',
      confirm: 'Log out',
    )) {
      ref.read(authRepositoryProvider).signOut();
    }
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.count, required this.label});

  final int count;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text('$count', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key, required this.user});

  final AppUser user;

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.user.name);
  late final _bio = TextEditingController(text: widget.user.bio);
  late List<String> _skills = List.from(widget.user.skills);
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _bio.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(userRepositoryProvider)
          .updateProfile(
            widget.user.uid,
            name: _name.text.trim(),
            bio: _bio.text.trim(),
            skills: _skills,
          );
      if (mounted) {
        Navigator.of(context).pop();
        showAppSnackBar(context, 'Profile updated.');
      }
    } catch (_) {
      if (mounted) {
        setState(() => _busy = false);
        showAppSnackBar(context, 'Could not save profile.', error: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit profile')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              TextFormField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Full name',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
                validator: (v) => Validators.required(v, 'Full name'),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _bio,
                maxLines: 3,
                maxLength: 200,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Short bio',
                  hintText: 'e.g. BSE student passionate about product design',
                ),
              ),
              const SizedBox(height: 8),
              const Text('Skills', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              const SizedBox(height: 10),
              SkillPicker(
                selected: _skills,
                suggestions: SuggestedSkills.all,
                onChanged: (s) => setState(() => _skills = s),
              ),
              const SizedBox(height: 20),
              PrimaryButton(label: 'Save changes', busy: _busy, onPressed: _save),
            ],
          ),
        ),
      ),
    );
  }
}

class SavedOpportunitiesScreen extends ConsumerWidget {
  const SavedOpportunitiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedIds = ref.watch(currentUserProvider).value?.savedOpportunityIds ?? [];
    final opps = ref.watch(openOpportunitiesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Saved opportunities')),
      body: AsyncView(
        value: opps,
        builder: (all) {
          final saved = all.where((o) => savedIds.contains(o.id)).toList();
          if (saved.isEmpty) {
            return const EmptyState(
              icon: Icons.bookmark_outline_rounded,
              title: 'Nothing saved yet',
              message: 'Tap the bookmark icon on any opportunity to keep it here.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: saved.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (_, i) => OpportunityCard(saved[i]),
          );
        },
      ),
    );
  }
}
