import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../core/widgets.dart';
import '../../models/application.dart';
import '../../providers/providers.dart';
import 'opportunity_detail_screen.dart';

/// Live tracker of the student's applications, filterable by status.
/// When a founder updates a status, the change appears here in real time.
class ApplicationsScreen extends ConsumerStatefulWidget {
  const ApplicationsScreen({super.key});

  @override
  ConsumerState<ApplicationsScreen> createState() =>
      _ApplicationsScreenState();
}

class _ApplicationsScreenState extends ConsumerState<ApplicationsScreen> {
  ApplicationStatus? _statusFilter;

  @override
  Widget build(BuildContext context) {
    final apps = ref.watch(myApplicationsProvider);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 14),
            child: Text('My Applications',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          ),
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _StatusFilterChip(
                  label: 'All',
                  selected: _statusFilter == null,
                  onTap: () => setState(() => _statusFilter = null),
                ),
                for (final s in ApplicationStatus.values)
                  _StatusFilterChip(
                    label: s.label,
                    selected: _statusFilter == s,
                    onTap: () => setState(
                        () => _statusFilter = _statusFilter == s ? null : s),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: AsyncView(
              value: apps,
              builder: (all) {
                final filtered = _statusFilter == null
                    ? all
                    : all.where((a) => a.status == _statusFilter).toList();
                if (filtered.isEmpty) {
                  return EmptyState(
                    icon: Icons.assignment_outlined,
                    title: _statusFilter == null
                        ? 'No applications yet'
                        : 'Nothing ${_statusFilter!.label.toLowerCase()}',
                    message: _statusFilter == null
                        ? 'Browse opportunities and send your first application!'
                        : 'Applications with this status will show up here.',
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _ApplicationCard(filtered[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusFilterChip extends StatelessWidget {
  const _StatusFilterChip(
      {required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
                color: selected ? AppColors.primary : AppColors.outline),
          ),
          child: Text(label,
              style: TextStyle(
                color: selected ? Colors.white : AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              )),
        ),
      ),
    );
  }
}

class _ApplicationCard extends ConsumerWidget {
  const _ApplicationCard(this.app);

  final Application app;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canWithdraw = app.status == ApplicationStatus.submitted ||
        app.status == ApplicationStatus.underReview;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => OpportunityDetailScreen(id: app.opportunityId))),
        onLongPress: canWithdraw ? () => _confirmWithdraw(context, ref) : null,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              InitialsAvatar(app.startupName),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(app.opportunityTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15)),
                    const SizedBox(height: 3),
                    Text(app.startupName,
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.textSecondary)),
                    const SizedBox(height: 3),
                    Text(
                      'Applied ${timeAgo(app.createdAt ?? DateTime.now())}',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              TagChip(app.status.label,
                  color: app.status.color, background: app.status.softColor),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmWithdraw(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Withdraw application?'),
        content: Text(
            'Your application to "${app.opportunityTitle}" will be removed. '
            'You can apply again later.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Keep it'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await ref.read(applicationRepositoryProvider).withdraw(app.id);
              if (context.mounted) {
                showAppSnackBar(context, 'Application withdrawn.');
              }
            },
            child: const Text('Withdraw'),
          ),
        ],
      ),
    );
  }
}
