import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../core/widgets.dart';
import '../../models/application.dart';
import '../../models/opportunity.dart';
import '../../providers/providers.dart';

class OpportunityDetailScreen extends ConsumerWidget {
  const OpportunityDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final oppAsync = ref.watch(opportunityProvider(id));

    return Scaffold(
      appBar: AppBar(title: const Text('Opportunity Details')),
      body: AsyncView(
        value: oppAsync,
        builder: (opp) {
          if (opp == null) {
            return const EmptyState(
              icon: Icons.link_off_rounded,
              title: 'Opportunity removed',
              message: 'This opportunity is no longer available.',
            );
          }
          return _DetailBody(opp: opp);
        },
      ),
    );
  }
}

class _DetailBody extends ConsumerWidget {
  const _DetailBody({required this.opp});

  final Opportunity opp;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startup = ref.watch(startupProvider(opp.startupId)).value;
    final myApps = ref.watch(myApplicationsProvider).value ?? [];
    final existing = myApps.where((a) => a.opportunityId == opp.id).firstOrNull;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            children: [
              Row(
                children: [
                  InitialsAvatar(opp.startupName, size: 56),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          opp.title,
                          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                opp.startupName,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: AppColors.textSecondary),
                              ),
                            ),
                            if (startup?.verified ?? false) ...[
                              const SizedBox(width: 5),
                              const Icon(
                                Icons.verified_rounded,
                                size: 16,
                                color: AppColors.primary,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(spacing: 8, runSpacing: 8, children: [for (final s in opp.skills) TagChip(s)]),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Column(
                    children: [
                      _MetaRow(
                        icon: Icons.schedule_rounded,
                        text: opp.hoursPerWeek.isEmpty
                            ? opp.workType
                            : '${opp.workType} (${opp.hoursPerWeek})',
                      ),
                      const Divider(height: 1, color: AppColors.outline),
                      _MetaRow(icon: Icons.place_outlined, text: opp.location),
                      const Divider(height: 1, color: AppColors.outline),
                      _MetaRow(
                        icon: Icons.calendar_today_outlined,
                        text: 'Posted ${timeAgo(opp.createdAt ?? DateTime.now())}',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'About the role',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(opp.description, style: const TextStyle(height: 1.5, fontSize: 14.5)),
              if (startup != null) ...[
                const SizedBox(height: 20),
                const Text(
                  'About the startup',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(startup.description, style: const TextStyle(height: 1.5, fontSize: 14.5)),
              ],
              const SizedBox(height: 12),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: existing != null
                ? Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: existing.status.softColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_rounded, size: 20, color: existing.status.color),
                        const SizedBox(width: 8),
                        Text(
                          'Applied • ${existing.status.label}',
                          style: TextStyle(
                            color: existing.status.color,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  )
                : !opp.open
                ? const Text(
                    'This opportunity is closed.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary),
                  )
                : PrimaryButton(label: 'Apply now', onPressed: () => _openApplySheet(context, ref)),
          ),
        ),
      ],
    );
  }

  void _openApplySheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _ApplySheet(opp: opp),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 19, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}

class _ApplySheet extends ConsumerStatefulWidget {
  const _ApplySheet({required this.opp});

  final Opportunity opp;

  @override
  ConsumerState<_ApplySheet> createState() => _ApplySheetState();
}

class _ApplySheetState extends ConsumerState<_ApplySheet> {
  final _formKey = GlobalKey<FormState>();
  final _message = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final user = ref.read(currentUserProvider).value;
    if (user == null) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(applicationRepositoryProvider)
          .submit(
            Application(
              id: '',
              opportunityId: widget.opp.id,
              opportunityTitle: widget.opp.title,
              startupId: widget.opp.startupId,
              startupName: widget.opp.startupName,
              studentId: user.uid,
              studentName: user.name,
              message: _message.text.trim(),
            ),
          );
      if (mounted) {
        Navigator.of(context).pop();
        showAppSnackBar(context, 'Application sent to ${widget.opp.startupName}.');
      }
    } catch (_) {
      if (mounted) {
        setState(() => _busy = false);
        showAppSnackBar(context, 'Could not submit application. Try again.', error: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Apply to ${widget.opp.title}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            const Text(
              'Tell the founder why you\'re a great fit. Mention relevant '
              'skills, coursework or projects.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13.5),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _message,
              maxLines: 5,
              maxLength: 500,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(hintText: 'Hi! I\'d love to contribute because…'),
              validator: (v) => Validators.minLength(v, 30, 'Your pitch'),
            ),
            const SizedBox(height: 8),
            PrimaryButton(label: 'Submit application', busy: _busy, onPressed: _submit),
          ],
        ),
      ),
    );
  }
}
