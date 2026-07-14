import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../core/widgets.dart';
import '../../models/startup.dart';
import '../../providers/providers.dart';

/// Startup tab: public profile preview, editing, and account actions.
class StartupProfileScreen extends ConsumerWidget {
  const StartupProfileScreen({super.key, required this.startup});

  final Startup startup;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          const Center(
            child: Text('Startup',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(height: 20),
          Center(child: InitialsAvatar(startup.name, size: 84)),
          const SizedBox(height: 12),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(startup.name,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w800)),
                ),
                if (startup.verified) ...[
                  const SizedBox(width: 6),
                  const Icon(Icons.verified_rounded,
                      size: 20, color: AppColors.primary),
                ],
              ],
            ),
          ),
          Center(
            child: Text(startup.category,
                style: const TextStyle(color: AppColors.textSecondary)),
          ),
          const SizedBox(height: 8),
          Center(
            child: TagChip(
              startup.verified ? 'Verified ALU startup' : 'Pending verification',
              color: startup.verified ? AppColors.success : AppColors.warning,
              background: startup.verified
                  ? AppColors.successSoft
                  : AppColors.warningSoft,
            ),
          ),
          const SizedBox(height: 20),
          const Text('About',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(startup.description,
              style: const TextStyle(height: 1.5, fontSize: 14.5)),
          if (startup.mission.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Text('Mission',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(startup.mission,
                style: const TextStyle(height: 1.5, fontSize: 14.5)),
          ],
          const SizedBox(height: 24),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.edit_outlined),
                  title: const Text('Edit startup profile',
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14.5)),
                  trailing: const Icon(Icons.chevron_right_rounded,
                      color: AppColors.textSecondary),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => EditStartupScreen(startup: startup))),
                ),
                const Divider(height: 1, color: AppColors.outline),
                ListTile(
                  leading:
                      const Icon(Icons.logout_rounded, color: AppColors.danger),
                  title: const Text('Log out',
                      style: TextStyle(
                          color: AppColors.danger,
                          fontWeight: FontWeight.w600,
                          fontSize: 14.5)),
                  onTap: () => ref.read(authRepositoryProvider).signOut(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EditStartupScreen extends ConsumerStatefulWidget {
  const EditStartupScreen({super.key, required this.startup});

  final Startup startup;

  @override
  ConsumerState<EditStartupScreen> createState() => _EditStartupScreenState();
}

class _EditStartupScreenState extends ConsumerState<EditStartupScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.startup.name);
  late final _description =
      TextEditingController(text: widget.startup.description);
  late final _mission = TextEditingController(text: widget.startup.mission);
  late String _category = widget.startup.category;
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _mission.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      await ref.read(startupRepositoryProvider).update(Startup(
            id: widget.startup.id,
            ownerId: widget.startup.ownerId,
            name: _name.text.trim(),
            category: _category,
            description: _description.text.trim(),
            mission: _mission.text.trim(),
            verified: widget.startup.verified,
          ));
      if (mounted) {
        Navigator.of(context).pop();
        showAppSnackBar(context, 'Startup profile updated.');
      }
    } catch (_) {
      if (mounted) {
        setState(() => _busy = false);
        showAppSnackBar(context, 'Could not save changes.', error: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit startup')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              TextFormField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Startup name'),
                validator: (v) => Validators.required(v, 'Startup name'),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(labelText: 'Category'),
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
                    labelText: 'Description', alignLabelWithHint: true),
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
              PrimaryButton(label: 'Save changes', busy: _busy, onPressed: _save),
            ],
          ),
        ),
      ),
    );
  }
}
