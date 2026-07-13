import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../providers/providers.dart';
import 'widgets/opportunity_card.dart';

/// Search + filter over the live opportunity feed. All filtering happens
/// client-side on the snapshot stream, so results update as you type and
/// when startups post — with zero extra Firestore reads.
class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(discoveryFilterProvider);
    final results = ref.watch(filteredOpportunitiesProvider);
    final notifier = ref.read(discoveryFilterProvider.notifier);

    // Keep the text field in sync when another screen sets the filter.
    if (_search.text != filter.query) {
      _search.text = filter.query;
    }

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Explore',
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                const SizedBox(height: 14),
                TextField(
                  controller: _search,
                  onChanged: notifier.setQuery,
                  decoration: InputDecoration(
                    hintText: 'Search roles, startups or skills…',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: filter.query.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () {
                              _search.clear();
                              notifier.setQuery('');
                            },
                          ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _FilterChoice(
                  label: 'All',
                  selected: filter.category == null,
                  onTap: () => notifier.setCategory(null),
                ),
                for (final c in OpportunityCategories.all)
                  _FilterChoice(
                    label: c,
                    selected: filter.category == c,
                    onTap: () =>
                        notifier.setCategory(filter.category == c ? null : c),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                for (final t in WorkTypes.all)
                  _FilterChoice(
                    label: t,
                    selected: filter.workType == t,
                    onTap: () =>
                        notifier.setWorkType(filter.workType == t ? null : t),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: AsyncView(
              value: results,
              builder: (opps) => opps.isEmpty
                  ? const EmptyState(
                      icon: Icons.search_off_rounded,
                      title: 'No matches',
                      message:
                          'Try a different search term or clear the filters.')
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      itemCount: opps.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (_, i) => OpportunityCard(opps[i]),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChoice extends StatelessWidget {
  const _FilterChoice(
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
                color: selected ? AppColors.primary : AppColors.outline),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
