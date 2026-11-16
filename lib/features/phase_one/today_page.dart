import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/lunora_theme.dart';
import 'phase_one_state.dart';
import 'phase_one_widgets.dart';
import 'symptom_logger.dart';
import 'medication_manager.dart';

class TodayPage extends StatelessWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<PhaseOneState>();
    final today = state.logs[localDateKey()];
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good morning' : hour < 17 ? 'Good afternoon' : 'Good evening';
    final priorities = (state.onboarding?['priorities'] as List? ?? const []).cast<String>();
    final taken = (today?.meds ?? const []).where((id) => state.meds.any((med) => med.id == id)).length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
      children: [
        Text('$greeting', style: const TextStyle(fontSize: 14, color: LunoraColors.inkSoft)),
        const SizedBox(height: 3),
        const Text('Today', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700, color: LunoraColors.ink)),
        const SizedBox(height: 16),
        LunoraCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(today == null ? 'How are you feeling?' : 'You logged today.', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          if (today != null) ...[
            const SizedBox(height: 5),
            Text('${today.symptoms.length} ${today.symptoms.length == 1 ? 'symptom' : 'symptoms'} logged', style: const TextStyle(color: LunoraColors.inkSoft)),
          ],
          const SizedBox(height: 14),
          LunoraButton(label: today == null ? 'Log symptoms' : 'Update log', onPressed: () => _openLogger(context)),
        ])),
        const SizedBox(height: 12),
        LunoraCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(state.meds.isEmpty ? 'No medications yet' : '$taken of ${state.meds.length} taken today', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(state.meds.isEmpty ? 'Add medications or supplements you want to track.' : 'Your daily medication check-in is here when you need it.', style: const TextStyle(color: LunoraColors.inkSoft)),
          const SizedBox(height: 14),
          LunoraButton(label: state.meds.isEmpty ? 'Add medication' : 'Mark as taken', onPressed: () => _openMeds(context)),
        ])),
        const SizedBox(height: 12),
        LunoraCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Your cycle notes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 7),
          Text(state.onboarding?['lastPeriod'] as String? ?? 'No last period date added', style: const TextStyle(color: LunoraColors.ink)),
          const SizedBox(height: 6),
          const Text('Cycles are tracked as ranges here — irregularity is not an error.', style: TextStyle(color: LunoraColors.inkSoft, height: 1.4)),
        ])),
        const SizedBox(height: 18),
        const Text('Your priorities', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        if (priorities.isEmpty)
          const Text('You can choose symptom areas that matter to you during onboarding.', style: TextStyle(color: LunoraColors.inkSoft))
        else
          Wrap(spacing: 8, runSpacing: 8, children: priorities.map((id) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
            decoration: BoxDecoration(color: LunoraColors.lavender, borderRadius: BorderRadius.circular(999)),
            child: Text(symptomGroupLabels[id] ?? id, style: const TextStyle(color: LunoraColors.ink)),
          )).toList()),
      ],
    );
  }

  void _openLogger(BuildContext context) => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: LunoraColors.bg,
        useSafeArea: true,
        builder: (_) => const SymptomLogger(),
      );

  void _openMeds(BuildContext context) => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: LunoraColors.bg,
        useSafeArea: true,
        builder: (_) => const MedicationManager(),
      );
}
