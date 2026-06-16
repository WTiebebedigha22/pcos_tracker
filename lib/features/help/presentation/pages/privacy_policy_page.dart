// lib/features/help/presentation/pages/privacy_policy_page.dart
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Privacy Policy',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Last updated: January 1, 2024',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            _PrivacySection(
              title: 'Information We Collect',
              content: 'We collect information you provide directly to us, such as when you create an account, log symptoms, track your cycle, and use our services. This includes:\n\n'
                  '• Personal information (name, email, date of birth)\n'
                  '• Health data (cycle information, symptoms, medications)\n'
                  '• Usage data (how you interact with the app)',
            ),
            const SizedBox(height: 16),
            _PrivacySection(
              title: 'How We Use Your Information',
              content: 'We use your information to:\n\n'
                  '• Provide and maintain our services\n'
                  '• Generate insights and predictions\n'
                  '• Send reminders and notifications\n'
                  '• Improve and personalize your experience',
            ),
            const SizedBox(height: 16),
            _PrivacySection(
              title: 'Data Security',
              content: 'We implement appropriate technical and organizational measures to protect your personal information. Your health data is encrypted and stored securely.',
            ),
            const SizedBox(height: 16),
            _PrivacySection(
              title: 'Your Rights',
              content: 'You have the right to:\n\n'
                  '• Access your personal data\n'
                  '• Correct inaccurate data\n'
                  '• Delete your data\n'
                  '• Export your data\n'
                  '• Withdraw consent',
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _PrivacySection extends StatelessWidget {
  final String title;
  final String content;

  const _PrivacySection({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF555555),
            height: 1.5,
          ),
        ),
      ],
    );
  }
}