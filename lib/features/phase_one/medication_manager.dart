import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/lunora_theme.dart';
import 'phase_one_state.dart';
import 'phase_one_widgets.dart';

class MedicationManager extends StatefulWidget {
  const MedicationManager({super.key});

  @override
  State<MedicationManager> createState() => _MedicationManagerState();
}

class _MedicationManagerState extends State<MedicationManager> {
  final _name = TextEditingController();
  final _dose = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _dose.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<PhaseOneState>();
    final taken = state.logs[localDateKey()]?.meds ?? const <String>[];
    return Padding(
      padding: EdgeInsets.fromLTRB(18, 12, 18, MediaQuery.viewInsetsOf(context).bottom + 16),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * .84,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Expanded(child: Text('Medications and supplements', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700, color: LunoraColors.ink))),
            IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
          ]),
          const Text('Your list stays on this device.', style: TextStyle(color: LunoraColors.inkSoft)),
          const SizedBox(height: 10),
          Expanded(child: ListView(children: [
            if (state.meds.isEmpty)
              const LunoraCard(child: Text('No medications yet. Add one below whenever you are ready.'))
            else
              ...state.meds.map((med) {
                final isTaken = taken.contains(med.id);
                return GestureDetector(
                  onLongPress: () => _confirmDelete(context, med.id, med.name),
                  child: LunoraCard(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(med.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('${med.dose.isEmpty ? 'Dose not specified' : med.dose} · Long-press to remove', style: const TextStyle(color: LunoraColors.inkSoft)),
                      trailing: Switch(value: isTaken, activeTrackColor: LunoraColors.lavenderDeep, onChanged: (value) => context.read<PhaseOneState>().toggleMedicationTaken(med.id, value)),
                    ),
                  ),
                );
              }),
            const SizedBox(height: 14),
            const Text('Suggestions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: medicationPresets.map((preset) => ActionChip(
                  label: Text(preset),
                  backgroundColor: LunoraColors.lavender,
                  onPressed: () => _addPreset(context, preset),
                )).toList()),
            const SizedBox(height: 18),
            const Text('Add something else', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(controller: _name, decoration: const InputDecoration(labelText: 'Name (required)', border: OutlineInputBorder())),
            const SizedBox(height: 8),
            TextField(controller: _dose, decoration: const InputDecoration(labelText: 'Dose (optional)', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            LunoraButton(label: 'Add medication', onPressed: () => _addCustom(context), enabled: _name.text.trim().isNotEmpty),
          ])),
        ]),
      ),
    );
  }

  Future<void> _addCustom(BuildContext context) async {
    final name = _name.text.trim();
    if (name.isEmpty) return;
    await context.read<PhaseOneState>().addMedication(name, _dose.text);
    _name.clear();
    _dose.clear();
    if (mounted) {
      setState(() {});
      FocusScope.of(context).unfocus();
    }
  }

  Future<void> _addPreset(BuildContext context, String preset) async {
    final parts = preset.split(' ');
    final name = parts.first == 'Birth' ? 'Birth control' : parts.first;
    final dose = parts.length > 1 ? parts.skip(1).join(' ') : '';
    await context.read<PhaseOneState>().addMedication(name, dose);
  }

  Future<void> _confirmDelete(BuildContext context, String id, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove medication?'),
        content: Text('Remove $name from your current list? Past logs will be kept.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Remove')),
        ],
      ),
    );
    if (confirmed == true && context.mounted) await context.read<PhaseOneState>().deleteMedication(id);
  }
}
