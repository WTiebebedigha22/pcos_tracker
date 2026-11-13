import 'package:flutter/material.dart';

/// Text alternative to a chart — required for screen readers.
/// Render alongside or below the visual chart.
class ChartSummary extends StatelessWidget {
  const ChartSummary({super.key, required this.summary});
  final String summary;
  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Chart summary: $summary',
    child: Padding(
      padding: const EdgeInsets.all(8),
      child: Text(summary, style: Theme.of(context).textTheme.bodySmall),
    ),
  );
}
