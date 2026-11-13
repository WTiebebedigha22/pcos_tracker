import 'package:flutter/material.dart';

/// PCOS correlates with elevated anxiety/depression. Always offer resources.
class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Support & resources')),
    body: ListView(padding: const EdgeInsets.all(16), children: const [
      Text('If you are in crisis, contact your local emergency number.'),
      SizedBox(height: 12),
      Text('International directory: findahelpline.com'),
      SizedBox(height: 24),
      Text('PCOS resources:'),
      ListTile(title: Text('PCOS Challenge'), subtitle: Text('pcoschallenge.org')),
      ListTile(title: Text('Verity (UK)'), subtitle: Text('verity-pcos.org.uk')),
    ]),
  );
}
