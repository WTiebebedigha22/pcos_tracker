import 'package:flutter/material.dart';

/// Simple hook for user feedback (opens a sheet, logs a breadcrumb).
class FeedbackButton extends StatelessWidget {
  const FeedbackButton({super.key});
  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: 'Send feedback',
    icon: const Icon(Icons.feedback_outlined),
    onPressed: () => showModalBottomSheet(
      context: context,
      builder: (_) => const Padding(
        padding: EdgeInsets.all(24),
        child: Text('Feedback form placeholder'),
      ),
    ),
  );
}
