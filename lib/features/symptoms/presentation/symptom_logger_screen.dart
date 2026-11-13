import 'package:flutter/material.dart';
import '../../../shared/components/app_chip.dart';
import '../../../shared/components/app_button.dart';
import '../../../shared/components/app_sheet.dart';

/// UX checklist:
/// [ ] Progressive disclosure — don't show 10 fields at once
/// [ ] Severity via sliders/chips, not text input
/// [ ] Save on dismiss (autosave) OR explicit Save with confirm
class SymptomLoggerScreen extends StatefulWidget {
  const SymptomLoggerScreen({super.key});
  @override
  State<SymptomLoggerScreen> createState() => _SymptomLoggerState();
}

class _SymptomLoggerState extends State<SymptomLoggerScreen> {
  final _selected = <String>{};
  static const _symptoms = [
    ('Acne', Icons.face_outlined),
    ('Fatigue', Icons.battery_1_bar),
    ('Hair loss', Icons.content_cut),
    ('Bloating', Icons.circle_outlined),
    ('Anxiety', Icons.psychology_outlined),
    ('Mood swings', Icons.mood_bad_outlined),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Log symptoms')),
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('What are you feeling today?', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),
        Wrap(spacing: 8, runSpacing: 8, children: _symptoms.map((s) => AppChip(
          label: s.$1,
          icon: s.$2,
          selected: _selected.contains(s.$1),
          onSelected: (v) => setState(() => v ? _selected.add(s.$1) : _selected.remove(s.$1)),
        )).toList()),
        const Spacer(),
        AppButton(
          label: 'Save ( ${_selected.length} )',
          onPressed: _selected.isEmpty ? null : () => AppSheet.show(context,
            title: 'Severity',
            child: const Padding(padding: EdgeInsets.all(16),
              child: Text('Per-symptom severity slider placeholder'))),
          expand: true,
        ),
      ]),
    ),
  );
}
