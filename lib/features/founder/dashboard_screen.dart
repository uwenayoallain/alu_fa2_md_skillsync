import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../core/widgets.dart';
import '../../models/application.dart';
import '../../models/opportunity.dart';
import '../../models/startup.dart';
import '../../providers/providers.dart';
import 'post_opportunity_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key, required this.startup});

  final Startup startup;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final opps = ref.watch(startupOpportunitiesProvider(startup.id));
    final apps = ref.watch(startupApplicationsProvider(startup.id)).value ?? [];

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          Row(
            children: [
              InitialsAvatar(startup.name, size: 48),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            startup.name,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                          ),
                        ),
                        if (startup.verified) ...[
                          const SizedBox(width: 6),
                          const Icon(Icons.verified_rounded, size: 20, color: AppColors.primary),
                        ],
                      ],
                    ),
                    Text(
                      startup.category,
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (!startup.verified) const _PendingVerificationBanner(),
          if (!startup.verified) const SizedBox(height: 16),
          Row(
            children: [
              _StatCard(
                icon: Icons.work_outline_rounded,
                count: opps.value?.length ?? 0,
                label: 'Postings',
              ),
              const SizedBox(width: 12),
              _StatCard(
                icon: Icons.people_outline_rounded,
                count: apps.length,
                label: 'Applicants',
              ),
              const SizedBox(width: 12),
              _StatCard(
                icon: Icons.hourglass_top_rounded,
                count: apps.where((a) => a.status == ApplicationStatus.submitted).length,
                label: 'New',
              ),
            ],
          ),
          const SizedBox(height: 22),
          SectionHeader(
            'My opportunities',
            actionLabel: startup.verified ? '+ Post new' : null,
            onAction: startup.verified
                ? () => Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (_) => PostOpportunityScreen(startup: startup)))
                : null,
          ),
          const SizedBox(height: 12),
          AsyncView(
            value: opps,
            builder: (list) => list.isEmpty
                ? EmptyState(
                    icon: Icons.post_add_rounded,
                    title: 'No opportunities yet',
                    message: startup.verified
                        ? 'Post your first opportunity to reach ALU students.'
                        : 'Once your startup is verified you can start posting.',
                  )
                : Column(
                    children: [
                      for (final o in list) ...[
                        _ManageOpportunityCard(o, startup: startup),
                        const SizedBox(height: 10),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _PendingVerificationBanner extends StatelessWidget {
  const _PendingVerificationBanner();

  @override
  Widget build(BuildContext context) {
    return const InfoBanner(
      icon: Icons.pending_outlined,
      message:
          'Verification pending — the ALU venture team is reviewing your '
          'startup. Posting unlocks once you\'re approved.',
      color: AppColors.warning,
      background: AppColors.warningSoft,
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.icon, required this.count, required this.label});

  final IconData icon;
  final int count;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            children: [
              Icon(icon, color: AppColors.primary, size: 22),
              const SizedBox(height: 6),
              Text('$count', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              Text(label, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ManageOpportunityCard extends ConsumerWidget {
  const _ManageOpportunityCard(this.opp, {required this.startup});

  final Opportunity opp;
  final Startup startup;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(opportunityRepositoryProvider);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    opp.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${opp.category} • ${opp.workType} • ${timeAgo(opp.createdAt ?? DateTime.now())}',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 6),
                  TagChip(
                    opp.open ? 'Open' : 'Closed',
                    color: opp.open ? AppColors.success : AppColors.danger,
                    background: opp.open ? AppColors.successSoft : AppColors.dangerSoft,
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded, color: AppColors.textSecondary),
              onSelected: (action) async {
                switch (action) {
                  case 'edit':
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PostOpportunityScreen(startup: startup, existing: opp),
                      ),
                    );
                  case 'toggle':
                    await repo.update(opp.id, {'open': !opp.open});
                  case 'delete':
                    _confirmDelete(context, ref);
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(
                  value: 'toggle',
                  child: Text(opp.open ? 'Close applications' : 'Reopen'),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete', style: TextStyle(color: AppColors.danger)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    if (!await confirmDanger(
      context,
      title: 'Delete opportunity?',
      content:
          '"${opp.title}" will be permanently removed. '
          'Existing applications will remain in your applicant list.',
      cancel: 'Cancel',
      confirm: 'Delete',
    )) {
      return;
    }
    await ref.read(opportunityRepositoryProvider).delete(opp.id);
    if (context.mounted) showAppSnackBar(context, 'Opportunity deleted.');
  }
}
