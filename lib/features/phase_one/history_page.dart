import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/lunora_theme.dart';
import 'phase_one_state.dart';
import 'phase_one_widgets.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final logs = context.watch<PhaseOneState>().logs.entries.toList()..sort((a, b) => b.key.compareTo(a.key));
    final counts = <String, int>{};
    for (final entry in logs) {
      for (final symptom in entry.value.symptoms) {
        counts.update(symptom, (count) => count + 1, ifAbsent: () => 1);
      }
    }
    final top = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
      children: [
        const Text('History', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: LunoraColors.ink)),
        const SizedBox(height: 14),
        LunoraCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Top symptoms', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
          const SizedBox(height: 9),
          if (top.isEmpty)
            const Text('Your symptom counts will appear here as you log.', style: TextStyle(color: LunoraColors.inkSoft))
          else
            ...top.take(3).map((entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(children: [Expanded(child: Text(symptomLabel(entry.key))), Text('${entry.value} ${entry.value == 1 ? 'log' : 'logs'}', style: const TextStyle(color: LunoraColors.inkSoft))]),
                )),
        ])),
        const SizedBox(height: 16),
        if (logs.isEmpty)
          const LunoraCard(child: Text('No history yet. Your saved daily logs will appear here.'))
        else
          ...logs.map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: LunoraCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(_formatDate(entry.key), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 5),
                  Text('${entry.value.symptoms.length} symptoms · Severity ${entry.value.severity} · ${entry.value.meds.length} medications', style: const TextStyle(color: LunoraColors.inkSoft)),
                  if (entry.value.notes.trim().isNotEmpty) ...[
                    const SizedBox(height: 7),
                    Text(entry.value.notes, maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ])),
              )),
      ],
    );
  }

  String _formatDate(String key) {
    final parts = key.split('-');
    if (parts.length != 3) return key;
    return '${parts[1]}/${parts[2]}/${parts[0]}';
  }
}
