import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme.dart';
import '../../../core/utils.dart';
import '../../../core/widgets.dart';
import '../../../models/opportunity.dart';
import '../../../providers/providers.dart';
import '../opportunity_detail_screen.dart';

class OpportunityCard extends ConsumerWidget {
  const OpportunityCard(this.opportunity, {super.key});

  final Opportunity opportunity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).value;
    final saved = user?.savedOpportunityIds.contains(opportunity.id) ?? false;

    return SummaryCard(
      avatar: opportunity.startupName,
      title: opportunity.title,
      subtitle: opportunity.startupName,
      meta:
          '${opportunity.workType} • ${opportunity.location} • ${timeAgo(opportunity.createdAt ?? DateTime.now())}',
      onTap: () => Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => OpportunityDetailScreen(id: opportunity.id))),
      trailing: IconButton(
        icon: Icon(
          saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
          color: saved ? AppColors.primary : AppColors.textSecondary,
        ),
        onPressed: user == null
            ? null
            : () => ref
                  .read(userRepositoryProvider)
                  .toggleBookmark(user.uid, opportunity.id, saved: saved),
      ),
    );
  }
}
