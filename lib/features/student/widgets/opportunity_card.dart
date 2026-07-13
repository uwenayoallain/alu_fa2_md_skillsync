import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme.dart';
import '../../../core/utils.dart';
import '../../../core/widgets.dart';
import '../../../models/opportunity.dart';
import '../../../providers/providers.dart';
import '../opportunity_detail_screen.dart';

/// List tile for an opportunity with a live bookmark toggle.
/// Reused on Home, Explore and Saved screens.
class OpportunityCard extends ConsumerWidget {
  const OpportunityCard(this.opportunity, {super.key});

  final Opportunity opportunity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).value;
    final saved =
        user?.savedOpportunityIds.contains(opportunity.id) ?? false;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => OpportunityDetailScreen(id: opportunity.id))),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              InitialsAvatar(opportunity.startupName),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(opportunity.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15)),
                    const SizedBox(height: 3),
                    Text(opportunity.startupName,
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.textSecondary)),
                    const SizedBox(height: 3),
                    Text(
                      '${opportunity.workType} • ${opportunity.location} • ${timeAgo(opportunity.createdAt ?? DateTime.now())}',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                  color: saved ? AppColors.primary : AppColors.textSecondary,
                ),
                onPressed: user == null
                    ? null
                    : () => ref.read(userRepositoryProvider).toggleBookmark(
                        user.uid, opportunity.id,
                        saved: saved),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
