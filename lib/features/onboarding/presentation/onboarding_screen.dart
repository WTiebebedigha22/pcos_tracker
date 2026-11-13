import 'package:flutter/material.dart';
import '../../../shared/widgets/medical_disclaimer.dart';

/// TODO: 3-4 value-prop pages + health baseline questions + consent.
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Column(children: [
        const Expanded(child: Center(child: Text('Welcome to Lunora'))),
        const MedicalDisclaimer(compact: true),
        Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: () {}, // TODO: route
            child: const Text('Get started'),
          ),
        ),
      ]),
    ),
  );
}
