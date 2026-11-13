import 'package:flutter/material.dart';

/// Required on any screen showing a prediction, insight, or dosage recommendation.
class MedicalDisclaimer extends StatelessWidget {
  const MedicalDisclaimer({super.key, this.compact = false});
  final bool compact;

  static const _text =
      'Lunora is not a medical device and does not provide medical advice. '
      'Predictions are estimates — not a form of birth control. '
      'Consult your healthcare provider.';

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Semantics(
      label: 'Medical disclaimer',
      child: Container(
        margin: EdgeInsets.all(compact ? 8 : 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: t.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(children: [
          Icon(Icons.info_outline, size: 20, color: t.colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(child: Text(_text, style: t.textTheme.bodySmall)),
        ]),
      ),
    );
  }
}
