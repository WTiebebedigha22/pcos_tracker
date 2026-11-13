import 'package:flutter/material.dart';
import '../../../shared/states/async_state_view.dart';
import '../../../shared/states/skeletons.dart';
import '../../../shared/components/app_card.dart';
import '../../../shared/widgets/not_birth_control_banner.dart';
import '../../../shared/widgets/medical_disclaimer.dart';

/// UX priority: cycle status > quick-log > recent symptoms > charts.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  AsyncStatus _status = AsyncStatus.loading;

  @override
  void initState() {
    super.initState();
    // TODO: replace with real provider listener
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) setState(() => _status = AsyncStatus.data);
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Lunora')),
    body: AsyncStateView(
      status: _status,
      onRetry: () => setState(() => _status = AsyncStatus.loading),
      builder: (_) => ListView(padding: const EdgeInsets.all(16), children: [
        const NotBirthControlBanner(),
        const SizedBox(height: 12),
        AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Cycle status', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('Day 14 · Predicted in ~6 days', style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 4),
          Text('Prediction ±3 days', style: Theme.of(context).textTheme.bodySmall),
        ])),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: AppCard(onTap: () {}, child: const _QuickAction(icon: Icons.water_drop_outlined, label: 'Log water'))),
          const SizedBox(width: 12),
          Expanded(child: AppCard(onTap: () {}, child: const _QuickAction(icon: Icons.mood_outlined, label: 'Log mood'))),
        ]),
        const SizedBox(height: 12),
        AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Recent symptoms', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          const Text('Nothing logged this week. Tap + to add.'),
        ])),
        const MedicalDisclaimer(),
      ]),
    ),
  );
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.icon, required this.label});
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) => Column(children: [
    Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
    const SizedBox(height: 8),
    Text(label, style: Theme.of(context).textTheme.labelLarge),
  ]);
}
