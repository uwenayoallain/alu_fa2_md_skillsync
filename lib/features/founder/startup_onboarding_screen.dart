import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../core/widgets.dart';
import '../../models/startup.dart';
import '../../providers/providers.dart';

class StartupFormScreen extends ConsumerStatefulWidget {
  const StartupFormScreen({super.key, this.startup});

  final Startup? startup;

  @override
  ConsumerState<StartupFormScreen> createState() => _StartupFormScreenState();
}

class _StartupFormScreenState extends ConsumerState<StartupFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.startup?.name);
  late final _description = TextEditingController(text: widget.startup?.description);
  late final _mission = TextEditingController(text: widget.startup?.mission);
  late String _category = widget.startup?.category ?? OpportunityCategories.all.first;
  bool _busy = false;

  bool get _editing => widget.startup != null;

  @override
  void dispose() {
    for (final controller in [_name, _description, _mission]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final ownerId = widget.startup?.ownerId ?? ref.read(authStateProvider).value?.uid;
    if (ownerId == null) return;
    setState(() => _busy = true);
    final startup = Startup(
      id: widget.startup?.id ?? '',
      ownerId: ownerId,
      name: _name.text.trim(),
      category: _category,
      description: _description.text.trim(),
      mission: _mission.text.trim(),
      verified: widget.startup?.verified ?? false,
    );
    try {
      final repo = ref.read(startupRepositoryProvider);
      _editing ? await repo.update(startup) : await repo.create(startup);
      if (mounted && _editing) {
        Navigator.pop(context);
        showAppSnackBar(context, 'Startup profile updated.');
      }
    } catch (_) {
      if (mounted) {
        setState(() => _busy = false);
        showAppSnackBar(
          context,
          _editing ? 'Could not save changes.' : 'Could not create startup profile.',
          error: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editing ? 'Edit startup' : 'Register your startup'),
        actions: _editing
            ? null
            : [
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
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (!_editing) ...[
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
              ],
              TextFormField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Startup name',
                  prefixIcon: _editing ? null : const Icon(Icons.storefront_outlined),
                ),
                validator: (v) => Validators.required(v, 'Startup name'),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: InputDecoration(
                  labelText: _editing ? 'Category' : 'Primary category',
                  prefixIcon: _editing ? null : const Icon(Icons.category_outlined),
                ),
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
                decoration: InputDecoration(
                  labelText: _editing ? 'Description' : 'What does your startup do?',
                  alignLabelWithHint: true,
                ),
                validator: (v) => Validators.minLength(v, 30, 'Description'),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _mission,
                maxLines: 2,
                maxLength: 150,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Mission (optional)',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 12),
              if (!_editing) ...[
                const InfoBanner(
                  icon: Icons.verified_user_outlined,
                  message:
                      'New startups are reviewed by the ALU venture team '
                      'before they can post opportunities. You can set up '
                      'everything else in the meantime.',
                  color: AppColors.info,
                  background: AppColors.infoSoft,
                ),
                const SizedBox(height: 20),
              ],
              PrimaryButton(
                label: _editing ? 'Save changes' : 'Create startup profile',
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
