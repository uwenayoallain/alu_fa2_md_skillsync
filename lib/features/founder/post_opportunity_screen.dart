import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../core/utils.dart';
import '../../core/widgets.dart';
import '../../models/opportunity.dart';
import '../../models/startup.dart';
import '../../providers/providers.dart';

class PostOpportunityScreen extends ConsumerStatefulWidget {
  const PostOpportunityScreen({super.key, required this.startup, this.existing});

  final Startup startup;
  final Opportunity? existing;

  @override
  ConsumerState<PostOpportunityScreen> createState() => _PostOpportunityScreenState();
}

class _PostOpportunityScreenState extends ConsumerState<PostOpportunityScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _title = TextEditingController(text: widget.existing?.title);
  late final _description = TextEditingController(text: widget.existing?.description);
  late final _hours = TextEditingController(text: widget.existing?.hoursPerWeek);
  late String _category = widget.existing?.category ?? OpportunityCategories.all.first;
  late String _workType = widget.existing?.workType ?? WorkTypes.all.first;
  late String _location = widget.existing?.location ?? Locations.all.first;
  late List<String> _skills = List.from(widget.existing?.skills ?? []);
  bool _busy = false;

  bool get _isEdit => widget.existing != null;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _hours.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_skills.isEmpty) {
      showAppSnackBar(context, 'Add at least one required skill.', error: true);
      return;
    }
    setState(() => _busy = true);
    final repo = ref.read(opportunityRepositoryProvider);
    try {
      if (_isEdit) {
        await repo.update(widget.existing!.id, {
          'title': _title.text.trim(),
          'description': _description.text.trim(),
          'category': _category,
          'workType': _workType,
          'location': _location,
          'skills': _skills,
          'hoursPerWeek': _hours.text.trim(),
        });
      } else {
        await repo.create(
          Opportunity(
            id: '',
            startupId: widget.startup.id,
            startupName: widget.startup.name,
            title: _title.text.trim(),
            description: _description.text.trim(),
            category: _category,
            workType: _workType,
            location: _location,
            skills: _skills,
            hoursPerWeek: _hours.text.trim(),
          ),
        );
      }
      if (mounted) {
        Navigator.of(context).pop();
        showAppSnackBar(context, _isEdit ? 'Opportunity updated.' : 'Opportunity posted.');
      }
    } catch (_) {
      if (mounted) {
        setState(() => _busy = false);
        showAppSnackBar(context, 'Could not save. Check your connection.', error: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit opportunity' : 'Post opportunity')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              TextFormField(
                controller: _title,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Role title',
                  hintText: 'e.g. Flutter Developer',
                ),
                validator: (v) => Validators.required(v, 'Role title'),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _description,
                maxLines: 5,
                maxLength: 800,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Role description',
                  hintText: 'What will the student work on? What will they learn?',
                  alignLabelWithHint: true,
                ),
                validator: (v) => Validators.minLength(v, 50, 'Description'),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: [
                  for (final c in OpportunityCategories.all)
                    DropdownMenuItem(value: c, child: Text(c)),
                ],
                onChanged: (v) => setState(() => _category = v!),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _workType,
                      decoration: const InputDecoration(labelText: 'Commitment'),
                      items: [
                        for (final t in WorkTypes.all) DropdownMenuItem(value: t, child: Text(t)),
                      ],
                      onChanged: (v) => setState(() => _workType = v!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _location,
                      decoration: const InputDecoration(labelText: 'Location'),
                      items: [
                        for (final l in Locations.all) DropdownMenuItem(value: l, child: Text(l)),
                      ],
                      onChanged: (v) => setState(() => _location = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _hours,
                decoration: const InputDecoration(
                  labelText: 'Time commitment (optional)',
                  hintText: 'e.g. 8–10 hrs/week',
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Required skills',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
              const SizedBox(height: 10),
              SkillPicker(
                selected: _skills,
                suggestions: SuggestedSkills.all,
                onChanged: (s) => setState(() => _skills = s),
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                label: _isEdit ? 'Save changes' : 'Publish opportunity',
                busy: _busy,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
