import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/lunora_theme.dart';
import 'phase_one_state.dart';
import 'phase_one_widgets.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
        children: [
          const Text('Settings', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: LunoraColors.ink)),
          const SizedBox(height: 16),
          const LunoraCard(child: Row(children: [Expanded(child: Text('App version')), Text('1.0.0', style: TextStyle(color: LunoraColors.inkSoft))])),
          const SizedBox(height: 10),
          LunoraButton(label: 'Re-run onboarding', ghost: true, onPressed: () async {
            await context.read<PhaseOneState>().rerunOnboarding();
          }),
          const SizedBox(height: 10),
          LunoraButton(label: 'Clear all data', onPressed: () => _confirmClear(context)),
          const SizedBox(height: 18),
          const Text('Medical disclaimer', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const LunoraCard(child: Text(lunoraMedicalDisclaimer, style: TextStyle(height: 1.5))),
        ],
      );

  Future<void> _confirmClear(BuildContext context) async {
    final first = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear all data?'),
        content: const Text('This will remove your onboarding choices, logs, and medication list from this device.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Continue')),
        ],
      ),
    );
    if (first != true || !context.mounted) return;
    final second = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirm data removal'),
        content: const Text('Are you sure you want to clear all Lunora data? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Keep my data')),
          TextButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Clear all data')),
        ],
      ),
    );
    if (second == true && context.mounted) await context.read<PhaseOneState>().clearAll();
  }
}
