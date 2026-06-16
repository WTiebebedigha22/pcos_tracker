// lib/features/settings/presentation/pages/settings_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../profile/presentation/provider/profile_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        children: [
          _SettingsSection(title: 'Preferences', children: [
            _SettingsTile(
              icon: Icons.dark_mode,
              title: 'Dark Mode',
              trailing: Switch(
                value: false,
                onChanged: (_) {},
                activeColor: AppColors.primary,
              ),
            ),
            _SettingsTile(
              icon: Icons.notifications,
              title: 'Push Notifications',
              trailing: Switch(
                value: true,
                onChanged: (_) {},
                activeColor: AppColors.primary,
              ),
            ),
          ]),
          _SettingsSection(title: 'Data Management', children: [
            _SettingsTile(
              icon: Icons.download,
              title: 'Export Data',
              onTap: () {},
            ),
            _SettingsTile(
              icon: Icons.upload,
              title: 'Import Data',
              onTap: () {},
            ),
            _SettingsTile(
              icon: Icons.delete,
              title: 'Clear All Data',
              onTap: () {},
              color: Colors.red,
            ),
          ]),
          _SettingsSection(title: 'About', children: [
            _SettingsTile(
              icon: Icons.info,
              title: 'App Version',
              trailing: const Text('1.0.0'),
            ),
            _SettingsTile(
              icon: Icons.privacy_tip,
              title: 'Privacy Policy',
              onTap: () {},
            ),
            _SettingsTile(
              icon: Icons.description,
              title: 'Terms of Service',
              onTap: () {},
            ),
          ]),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF888888),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? color;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.primary),
      title: Text(title, style: TextStyle(color: color)),
      trailing: trailing,
      onTap: onTap,
    );
  }
}