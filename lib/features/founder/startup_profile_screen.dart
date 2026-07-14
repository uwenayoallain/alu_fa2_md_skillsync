import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../models/startup.dart';
import '../../providers/providers.dart';
import 'startup_onboarding_screen.dart';

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
            child: Text('Startup', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(height: 20),
          Center(child: InitialsAvatar(startup.name, size: 84)),
          const SizedBox(height: 12),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
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
          ),
          Center(
            child: Text(startup.category, style: const TextStyle(color: AppColors.textSecondary)),
          ),
          const SizedBox(height: 8),
          Center(
            child: TagChip(
              startup.verified ? 'Verified ALU startup' : 'Pending verification',
              color: startup.verified ? AppColors.success : AppColors.warning,
              background: startup.verified ? AppColors.successSoft : AppColors.warningSoft,
            ),
          ),
          const SizedBox(height: 20),
          const Text('About', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(startup.description, style: const TextStyle(height: 1.5, fontSize: 14.5)),
          if (startup.mission.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Text('Mission', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(startup.mission, style: const TextStyle(height: 1.5, fontSize: 14.5)),
          ],
          const SizedBox(height: 24),
          Card(
            child: Column(
              children: [
                MenuTile(
                  icon: Icons.edit_outlined,
                  label: 'Edit startup profile',
                  onTap: () => Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (_) => StartupFormScreen(startup: startup))),
                ),
                const Divider(height: 1, color: AppColors.outline),
                MenuTile(
                  icon: Icons.logout_rounded,
                  label: 'Log out',
                  color: AppColors.danger,
                  trailing: false,
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
