import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/lunora_theme.dart';
import 'phase_one_state.dart';
import 'phase_one_widgets.dart';

class SymptomLogger extends StatefulWidget {
  const SymptomLogger({super.key});

  @override
  State<SymptomLogger> createState() => _SymptomLoggerState();
}

class _SymptomLoggerState extends State<SymptomLogger> {
  final Set<String> _selected = {};
  final _notes = TextEditingController();
  int _severity = 3;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    final existing = context.read<PhaseOneState>().logs[localDateKey()];
    if (existing != null) {
      _selected.addAll(existing.symptoms);
      _severity = existing.severity;
      _notes.text = existing.notes;
    }
    _initialized = true;
  }

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.fromLTRB(18, 12, 18, MediaQuery.viewInsetsOf(context).bottom + 18),
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * .84,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Expanded(child: Text('Today’s symptom log', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700, color: LunoraColors.ink))),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
            ]),
            const Text('Choose anything you want to record.', style: TextStyle(color: LunoraColors.inkSoft)),
            const SizedBox(height: 10),
            Expanded(child: ListView(children: [
              ...symptomGroups.entries.map((group) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(symptomGroupLabels[group.key]!, style: const TextStyle(fontWeight: FontWeight.w600, color: LunoraColors.ink)),
                      const SizedBox(height: 8),
                      Wrap(spacing: 8, runSpacing: 8, children: group.value.map((item) {
                        final id = item['id']!;
                        return LunoraPill(label: item['label']!, selected: _selected.contains(id), onTap: () => setState(() => _selected.contains(id) ? _selected.remove(id) : _selected.add(id)));
                      }).toList()),
                    ]),
                  )),
              const Text('Severity', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: List.generate(5, (index) {
                final value = index + 1;
                return ChoiceChip(label: Text('$value'), selected: _severity == value, onSelected: (_) => setState(() => _severity = value), selectedColor: LunoraColors.lavenderDeep, labelStyle: TextStyle(color: _severity == value ? Colors.white : LunoraColors.ink));
              })),
              const SizedBox(height: 12),
              TextField(controller: _notes, minLines: 3, maxLines: 5, decoration: const InputDecoration(labelText: 'Notes (optional)', alignLabelWithHint: true, border: OutlineInputBorder())),
            ])),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: LunoraButton(label: 'Cancel', ghost: true, onPressed: () => Navigator.pop(context))),
              const SizedBox(width: 10),
              Expanded(child: LunoraButton(label: 'Save log', onPressed: () async {
                await context.read<PhaseOneState>().saveSymptomLog(symptoms: _selected.toList(), severity: _severity, notes: _notes.text.trim());
                if (context.mounted) Navigator.pop(context);
              })),
            ]),
          ]),
        ),
      );
}
