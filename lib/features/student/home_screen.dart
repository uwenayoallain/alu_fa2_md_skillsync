import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../core/widgets.dart';
import '../../models/opportunity.dart';
import '../../providers/providers.dart';
import 'opportunity_detail_screen.dart';
import 'student_shell.dart';
import 'widgets/opportunity_card.dart';

/// Student landing screen: greeting, skill-matched recommendations,
/// category shortcuts and the latest openings — all live Firestore streams.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).value;
    final recommended = ref.watch(recommendedOpportunitiesProvider);
    final recent = ref.watch(openOpportunitiesProvider);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, ${user?.name.split(' ').first ?? 'there'}',
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 3),
                    const Text('Find meaningful ways to contribute.',
                        style: TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
              ),
              InitialsAvatar(user?.name ?? '?', size: 44),
            ],
          ),
          const SizedBox(height: 20),
          _RecommendedSection(recommended: recommended),
          const SizedBox(height: 22),
          const SectionHeader('Browse by category'),
          const SizedBox(height: 12),
          const _CategoryRow(),
          const SizedBox(height: 22),
          const SectionHeader('Recent opportunities'),
          const SizedBox(height: 12),
          AsyncView(
            value: recent,
            builder: (opps) => opps.isEmpty
                ? const EmptyState(
                    icon: Icons.work_outline_rounded,
                    title: 'No opportunities yet',
                    message:
                        'Startups are getting set up — check back soon!')
                : Column(
                    children: [
                      for (final o in opps.take(6)) ...[
                        OpportunityCard(o),
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

class _RecommendedSection extends ConsumerWidget {
  const _RecommendedSection({required this.recommended});

  final AsyncValue<List<Opportunity>> recommended;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final skills = ref.watch(currentUserProvider).value?.skills ?? [];
    final items = recommended.value ?? [];
    if (items.isEmpty) {
      // No matches (or no skills yet) — hide the rail rather than show noise.
      return skills.isEmpty
          ? Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.person_outline_rounded,
                        color: AppColors.primary),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                          'Add your skills to unlock personalised recommendations.',
                          style: TextStyle(fontSize: 13.5)),
                    ),
                  ],
                ),
              ),
            )
          : const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader('Recommended for you'),
        const SizedBox(height: 12),
        SizedBox(
          height: 168,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (_, i) =>
                _RecommendedCard(items[i], studentSkills: skills),
          ),
        ),
      ],
    );
  }
}

/// Gradient hero card used in the horizontal recommendation rail.
class _RecommendedCard extends StatelessWidget {
  const _RecommendedCard(this.opp, {required this.studentSkills});

  final Opportunity opp;
  final List<String> studentSkills;

  @override
  Widget build(BuildContext context) {
    final matches = opp.matchScore(studentSkills);
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => OpportunityDetailScreen(id: opp.id))),
      child: Container(
        width: 270,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$matches skill match${matches == 1 ? '' : 'es'}',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700),
            ),
            const Spacer(),
            Text(opp.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(opp.startupName,
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9), fontSize: 13)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final s in opp.skills.take(3))
                  TagChip(s,
                      color: Colors.white,
                      background: Colors.white.withValues(alpha: 0.22)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.schedule_rounded,
                    size: 14, color: Colors.white.withValues(alpha: 0.9)),
                const SizedBox(width: 4),
                Text(
                  opp.hoursPerWeek.isEmpty ? opp.workType : opp.hoursPerWeek,
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9), fontSize: 12),
                ),
                const Spacer(),
                Text('Posted ${timeAgo(opp.createdAt ?? DateTime.now())}',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Category shortcuts that jump to Explore with the filter pre-applied.
class _CategoryRow extends ConsumerWidget {
  const _CategoryRow();

  static const _icons = {
    'Design': Icons.brush_rounded,
    'Engineering': Icons.code_rounded,
    'Marketing': Icons.campaign_rounded,
    'Data': Icons.bar_chart_rounded,
    'Research': Icons.science_rounded,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = OpportunityCategories.all
        .where((c) => _icons.containsKey(c))
        .toList();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (final c in categories)
          GestureDetector(
            onTap: () {
              ref.read(discoveryFilterProvider.notifier).setCategory(c);
              ref.read(studentTabProvider.notifier).go(1);
            },
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.outline),
                  ),
                  child: Icon(_icons[c], color: AppColors.primary),
                ),
                const SizedBox(height: 6),
                Text(c,
                    style: const TextStyle(
                        fontSize: 11.5, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
      ],
    );
  }
}
