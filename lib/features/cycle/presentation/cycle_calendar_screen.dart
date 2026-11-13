import 'package:flutter/material.dart';
import '../../../shared/widgets/not_birth_control_banner.dart';
import '../../../shared/widgets/medical_disclaimer.dart';

/// UX checklist:
/// [ ] "Not birth control" banner at top
/// [ ] Predicted dates rendered as range (± days), not single dot
/// [ ] Past logged cycles visually distinct from predictions
/// [ ] Tap a day → log or view
class CycleCalendarScreen extends StatelessWidget {
  const CycleCalendarScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Cycle')),
    body: Column(children: [
      const NotBirthControlBanner(),
      Expanded(child: Center(child: Text('Calendar — replace with table_calendar',
        style: Theme.of(context).textTheme.bodyMedium))),
      const MedicalDisclaimer(compact: true),
    ]),
  );
}
