// lib/features/help/presentation/pages/help_page.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        children: [
          _HelpCard(
            icon: Icons.contact_support,
            title: 'Contact Us',
            description: 'Get in touch with our support team',
            onTap: () async {
              final emailUrl = Uri.parse('mailto:support@cyclesync.com');
              if (await canLaunchUrl(emailUrl)) {
                await launchUrl(emailUrl);
              }
            },
          ),
          _HelpCard(
            icon: Icons.question_answer,
            title: 'FAQs',
            description: 'Frequently asked questions',
            onTap: () {},
          ),
          _HelpCard(
            icon: Icons.tips_and_updates,
            title: 'Tips for PCOS',
            description: 'Lifestyle and wellness tips',
            onTap: () {},
          ),
          _HelpCard(
            icon: Icons.feedback,
            title: 'Send Feedback',
            description: 'Help us improve the app',
            onTap: () {},
          ),
          _HelpCard(
            icon: Icons.star,
            title: 'Rate the App',
            description: 'Share your experience',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _HelpCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _HelpCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(title),
        subtitle: Text(description, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}