import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'theme.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.busy = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool busy;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: busy ? null : onPressed,
      child: busy
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
            )
          : icon == null
          ? Text(label)
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [Icon(icon, size: 20), const SizedBox(width: 8), Text(label)],
            ),
    );
  }
}

class TagChip extends StatelessWidget {
  const TagChip(this.label, {super.key, this.color, this.background});

  final String label;
  final Color? color;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background ?? AppColors.primarySoft,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color ?? AppColors.primaryDark,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class InfoBanner extends StatelessWidget {
  const InfoBanner({
    super.key,
    required this.icon,
    required this.message,
    required this.color,
    required this.background,
  });

  final IconData icon;
  final String message;
  final Color color, background;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(14)),
    child: Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Text(message, style: TextStyle(fontSize: 13, color: color)),
        ),
      ],
    ),
  );
}

class ChoicePill extends StatelessWidget {
  const ChoicePill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.animated = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool animated;

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      color: selected ? AppColors.primary : AppColors.surface,
      borderRadius: BorderRadius.circular(11),
      border: Border.all(color: selected ? AppColors.primary : AppColors.outline),
    );
    final child = Text(
      label,
      style: TextStyle(
        color: selected ? Colors.white : AppColors.textPrimary,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: animated
            ? AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                alignment: Alignment.center,
                decoration: decoration,
                child: child,
              )
            : Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                alignment: Alignment.center,
                decoration: decoration,
                child: child,
              ),
      ),
    );
  }
}

class MenuTile extends StatelessWidget {
  const MenuTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
    this.trailing = true,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final bool trailing;

  @override
  Widget build(BuildContext context) {
    final foreground = color ?? AppColors.textPrimary;
    return ListTile(
      leading: Icon(icon, color: foreground),
      title: Text(
        label,
        style: TextStyle(color: foreground, fontWeight: FontWeight.w600, fontSize: 14.5),
      ),
      trailing: trailing
          ? const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary)
          : null,
      onTap: onTap,
    );
  }
}

Future<bool> confirmDanger(
  BuildContext context, {
  required String title,
  required String content,
  required String cancel,
  required String confirm,
}) async =>
    await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(cancel)),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(confirm),
          ),
        ],
      ),
    ) ??
    false;

class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar(this.text, {super.key, this.size = 46});

  final String text;
  final double size;

  static const _palette = [
    Color(0xFF6C4DF4),
    Color(0xFF14957B),
    Color(0xFFD03E5E),
    Color(0xFF2D6FD6),
    Color(0xFFB97D10),
    Color(0xFF8E44AD),
  ];

  @override
  Widget build(BuildContext context) {
    final initial = text.trim().isEmpty ? '?' : text.trim()[0].toUpperCase();
    final color = _palette[text.hashCode.abs() % _palette.length];
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(size * 0.32),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyle(color: color, fontSize: size * 0.42, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.avatar,
    required this.title,
    required this.subtitle,
    required this.meta,
    required this.trailing,
    required this.onTap,
    this.onLongPress,
    this.truncateTitle = true,
    this.truncateSubtitle = false,
  });

  final String avatar, title, subtitle, meta;
  final Widget trailing;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool truncateTitle;
  final bool truncateSubtitle;

  @override
  Widget build(BuildContext context) => Card(
    child: InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            InitialsAvatar(avatar),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: truncateTitle ? 1 : null,
                    overflow: truncateTitle ? TextOverflow.ellipsis : null,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: truncateSubtitle ? 1 : null,
                    overflow: truncateSubtitle ? TextOverflow.ellipsis : null,
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 3),
                  Text(meta, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    ),
  );
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, required this.message});

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(color: AppColors.primarySoft, shape: BoxShape.circle),
              child: Icon(icon, size: 34, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class AsyncView<T> extends StatelessWidget {
  const AsyncView({super.key, required this.value, required this.builder});

  final AsyncValue<T> value;
  final Widget Function(T data) builder;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: builder,
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_rounded, size: 40, color: AppColors.textSecondary),
              const SizedBox(height: 12),
              const Text('Could not load data', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(
                '$e',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.actionLabel, this.onAction});

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        ),
        if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionLabel!,
              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
            ),
          ),
      ],
    );
  }
}

class SkillPicker extends StatefulWidget {
  const SkillPicker({
    super.key,
    required this.selected,
    required this.suggestions,
    required this.onChanged,
  });

  final List<String> selected;
  final List<String> suggestions;
  final ValueChanged<List<String>> onChanged;

  @override
  State<SkillPicker> createState() => _SkillPickerState();
}

class _SkillPickerState extends State<SkillPicker> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle(String skill) {
    final next = List<String>.from(widget.selected);
    next.contains(skill) ? next.remove(skill) : next.add(skill);
    widget.onChanged(next);
  }

  void _addCustom() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    if (!widget.selected.any((s) => s.toLowerCase() == text.toLowerCase())) {
      widget.onChanged([...widget.selected, text]);
    }
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final custom = widget.selected.where((s) => !widget.suggestions.contains(s)).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final skill in [...widget.suggestions, ...custom])
              FilterChip(
                label: Text(skill),
                selected: widget.selected.contains(skill),
                onSelected: (_) => _toggle(skill),
                selectedColor: AppColors.primary,
                checkmarkColor: Colors.white,
                labelStyle: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: widget.selected.contains(skill) ? Colors.white : AppColors.primaryDark,
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(hintText: 'Add another skill…'),
                textCapitalization: TextCapitalization.words,
                onSubmitted: (_) => _addCustom(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: _addCustom,
              icon: const Icon(Icons.add_rounded),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(52, 52),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
