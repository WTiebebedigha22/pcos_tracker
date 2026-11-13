import 'package:flutter/material.dart';
import '../../../shared/widgets/chart_summary.dart';
import '../../../shared/components/app_card.dart';

/// UX checklist:
/// [ ] Every chart has a text summary (accessibility)
/// [ ] Time-range selector (7d / 30d / 90d / all)
/// [ ] Empty state when <7 days of data
class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Insights')),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Mood trend', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        const SizedBox(height: 160, child: Center(child: Text('[fl_chart here]'))),
        const ChartSummary(summary: 'Your mood averaged 3.2/5 this month, up from 2.8 last month.'),
      ])),
    ]),
  );
}
