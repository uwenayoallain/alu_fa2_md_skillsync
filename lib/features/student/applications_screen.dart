import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils.dart';
import '../../core/widgets.dart';
import '../../models/application.dart';
import '../../providers/providers.dart';
import 'opportunity_detail_screen.dart';

class ApplicationsScreen extends ConsumerStatefulWidget {
  const ApplicationsScreen({super.key});

  @override
  ConsumerState<ApplicationsScreen> createState() => _ApplicationsScreenState();
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
            child: Text(
              'My Applications',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
          ),
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                ChoicePill(
                  label: 'All',
                  selected: _statusFilter == null,
                  onTap: () => setState(() => _statusFilter = null),
                ),
                for (final s in ApplicationStatus.values)
                  ChoicePill(
                    label: s.label,
                    selected: _statusFilter == s,
                    onTap: () => setState(() => _statusFilter = _statusFilter == s ? null : s),
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

class _ApplicationCard extends ConsumerWidget {
  const _ApplicationCard(this.app);

  final Application app;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canWithdraw =
        app.status == ApplicationStatus.submitted || app.status == ApplicationStatus.underReview;
    return SummaryCard(
      avatar: app.startupName,
      title: app.opportunityTitle,
      subtitle: app.startupName,
      meta: 'Applied ${timeAgo(app.createdAt ?? DateTime.now())}',
      onTap: () => Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => OpportunityDetailScreen(id: app.opportunityId))),
      onLongPress: canWithdraw ? () => _confirmWithdraw(context, ref) : null,
      trailing: TagChip(
        app.status.label,
        color: app.status.color,
        background: app.status.softColor,
      ),
    );
  }

  Future<void> _confirmWithdraw(BuildContext context, WidgetRef ref) async {
    if (!await confirmDanger(
      context,
      title: 'Withdraw application?',
      content:
          'Your application to "${app.opportunityTitle}" will be removed. '
          'You can apply again later.',
      cancel: 'Keep it',
      confirm: 'Withdraw',
    )) {
      return;
    }
    await ref.read(applicationRepositoryProvider).withdraw(app.id);
    if (context.mounted) showAppSnackBar(context, 'Application withdrawn.');
  }
}
