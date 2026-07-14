import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../core/widgets.dart';
import '../../models/application.dart';
import '../../models/startup.dart';
import '../../providers/providers.dart';

/// Live list of everyone who applied to this startup's opportunities.
/// Opening an applicant shows their pitch, profile and skills, and lets the
/// founder move the application through the review pipeline — the student's
/// tracker updates in real time.
class ApplicantsScreen extends ConsumerWidget {
  const ApplicantsScreen({super.key, required this.startup});

  final Startup startup;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apps = ref.watch(startupApplicationsProvider(startup.id));

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 14),
            child: Text('Applicants',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          ),
          Expanded(
            child: AsyncView(
              value: apps,
              builder: (list) => list.isEmpty
                  ? const EmptyState(
                      icon: Icons.people_outline_rounded,
                      title: 'No applicants yet',
                      message:
                          'Applications to your opportunities will appear here '
                          'the moment students apply.',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                      itemCount: list.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (_, i) => _ApplicantCard(list[i]),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ApplicantCard extends StatelessWidget {
  const _ApplicantCard(this.app);

  final Application app;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: AppColors.surface,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          builder: (_) => _ApplicantDetailSheet(app: app),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              InitialsAvatar(app.studentName),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(app.studentName,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15)),
                    const SizedBox(height: 3),
                    Text('For: ${app.opportunityTitle}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.textSecondary)),
                    const SizedBox(height: 3),
                    Text('Applied ${timeAgo(app.createdAt ?? DateTime.now())}',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary)),
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
}

/// Applicant detail: pitch, live profile (bio + skills) and status actions.
class _ApplicantDetailSheet extends ConsumerWidget {
  const _ApplicantDetailSheet({required this.app});

  final Application app;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(applicantProvider(app.studentId)).value;
    // Watch the live application so the selected status chip updates
    // immediately after a change.
    final live = ref
            .watch(startupApplicationsProvider(app.startupId))
            .value
            ?.where((a) => a.id == app.id)
            .firstOrNull ??
        app;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.72,
      maxChildSize: 0.95,
      builder: (_, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              InitialsAvatar(app.studentName, size: 54),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(app.studentName,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w800)),
                    Text(profile?.email ?? '',
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              TagChip(live.status.label,
                  color: live.status.color, background: live.status.softColor),
            ],
          ),
          const SizedBox(height: 16),
          Text('Applying for: ${app.opportunityTitle}',
              style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          const Text('Pitch',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(app.message, style: const TextStyle(height: 1.5)),
          ),
          if (profile != null && profile.bio.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Text('Bio',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(profile.bio, style: const TextStyle(height: 1.5)),
          ],
          if (profile != null && profile.skills.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Text('Skills',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [for (final s in profile.skills) TagChip(s)],
            ),
          ],
          const SizedBox(height: 20),
          const Text('Update status',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final s in ApplicationStatus.values)
                ChoiceChip(
                  label: Text(s.label),
                  selected: live.status == s,
                  selectedColor: s.color,
                  labelStyle: TextStyle(
                    color: live.status == s ? Colors.white : s.color,
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                  ),
                  backgroundColor: s.softColor,
                  side: BorderSide.none,
                  onSelected: (_) async {
                    await ref
                        .read(applicationRepositoryProvider)
                        .updateStatus(app.id, s);
                    if (context.mounted) {
                      showAppSnackBar(context,
                          '${app.studentName.split(' ').first} moved to "${s.label}".');
                    }
                  },
                ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
