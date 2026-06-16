// lib/features/help/presentation/pages/terms_of_service_page.dart
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Terms of Service'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Terms of Service',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Last updated: January 1, 2024',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            _TermsSection(
              title: '1. Acceptance of Terms',
              content: 'By downloading, accessing, or using CycleSync, you agree to be bound by these Terms of Service.',
            ),
            const SizedBox(height: 16),
            _TermsSection(
              title: '2. Health Disclaimer',
              content: 'CycleSync is not a medical device and does not provide medical advice. Always consult with a healthcare provider for medical decisions.',
            ),
            const SizedBox(height: 16),
            _TermsSection(
              title: '3. User Responsibilities',
              content: 'You are responsible for:\n\n'
                  '• Maintaining the confidentiality of your account\n'
                  '• All activities that occur under your account\n'
                  '• The accuracy of data you enter',
            ),
            const SizedBox(height: 16),
            _TermsSection(
              title: '4. Data Privacy',
              content: 'Your use of CycleSync is also governed by our Privacy Policy. We take data protection seriously.',
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _TermsSection extends StatelessWidget {
  final String title;
  final String content;

  const _TermsSection({required this.title, required this.content});

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