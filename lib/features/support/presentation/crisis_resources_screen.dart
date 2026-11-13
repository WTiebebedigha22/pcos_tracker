import 'package:flutter/material.dart';

/// PCOS is associated with elevated anxiety/depression. Always offer resources.
class CrisisResourcesScreen extends StatelessWidget {
  const CrisisResourcesScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Support')),
    body: const Padding(
      padding: EdgeInsets.all(16),
      child: Text(
        'If you are in crisis, contact your local emergency number. '
        'International: findahelpline.com',
      ),
    ),
  );
}
