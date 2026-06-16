// lib/features/profile/presentation/pages/profile_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../provider/profile_provider.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    
    if (!authProvider.isLoggedIn) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F7FC),
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.person_off, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'Please log in to view your profile',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => context.read<UserProvider>().refreshData(),
          child: Column(
            children: [
              _ProfileAppBar(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Consumer<UserProvider>(
                    builder: (context, provider, _) {
                      if (provider.isLoading) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          ),
                        );
                      }
                      
                      return Column(
                        children: [
                          const SizedBox(height: 8),
                          _AvatarHeader(),
                          const SizedBox(height: 24),
                          _PersonalInfoSection(),
                          const SizedBox(height: 16),
                          _CycleSettingsSection(),
                          const SizedBox(height: 16),
                          _NotificationsSection(),
                          const SizedBox(height: 16),
                          _UnitsSection(),
                          const SizedBox(height: 16),
                          _AccountSection(),
                          const SizedBox(height: 32),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// App Bar
class _ProfileAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 16, 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Color(0xFF1A1A2E)),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              'Profile',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A2E),
                letterSpacing: -0.3,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfilePage()),
              ).then((_) {
                // Refresh data when returning from edit page
                context.read<UserProvider>().refreshData();
              });
            },
            child: const Text(
              'Edit',
              style: TextStyle(
                color: Color(0xFF8B3FD9),
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Avatar Header
class _AvatarHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, provider, _) {
        return Column(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8B3FD9), Color(0xFFE94DA0)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8B3FD9).withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: ClipOval(
                    child: (provider.avatarUrl != null && provider.avatarUrl!.isNotEmpty)
                        ? Image.network(
                            provider.avatarUrl!,
                            fit: BoxFit.cover,
                            width: 88,
                            height: 88,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Text(
                                  provider.avatarInitial,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 36,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              );
                            },
                          )
                        : Center(
                            child: Text(
                              provider.avatarInitial,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFF8B3FD9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              provider.displayName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A2E),
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              provider.email,
              style: const TextStyle(fontSize: 13, color: Color(0xFF888888)),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFEDE8F9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'PCOS Diagnosed · ${provider.profile.pcosDiagnosedYear}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF8B3FD9),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// Section Card
class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF888888),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

// Info Tile
class _InfoTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final String value;
  final bool isLast;

  const _InfoTile({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(label, style: const TextStyle(fontSize: 14, color: Color(0xFF555555), fontWeight: FontWeight.w500)),
              ),
              Text(value, style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A2E), fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        if (!isLast) const Divider(height: 1, indent: 56, endIndent: 16, color: Color(0xFFF0EDF8)),
      ],
    );
  }
}

// Toggle Tile
class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isLast;

  const _ToggleTile({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A2E), fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFFAAAAAA))),
                  ],
                ),
              ),
              Switch(
                value: value,
                onChanged: onChanged,
                activeColor: const Color(0xFF8B3FD9),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ),
        ),
        if (!isLast) const Divider(height: 1, indent: 56, endIndent: 16, color: Color(0xFFF0EDF8)),
      ],
    );
  }
}

// Stepper Tile
class _StepperTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final int value;
  final String unit;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final bool isLast;

  const _StepperTile({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.value,
    required this.unit,
    required this.onDecrement,
    required this.onIncrement,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(label, style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A2E), fontWeight: FontWeight.w600)),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: onDecrement,
                    child: Container(
                      width: 28, height: 28,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDE8F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.remove, size: 16, color: Color(0xFF8B3FD9)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text('$value $unit', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: onIncrement,
                    child: Container(
                      width: 28, height: 28,
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B3FD9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.add, size: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (!isLast) const Divider(height: 1, indent: 56, endIndent: 16, color: Color(0xFFF0EDF8)),
      ],
    );
  }
}

// Segment Tile
class _SegmentTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;
  final bool isLast;

  const _SegmentTile({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.options,
    required this.selected,
    required this.onSelected,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(label, style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A2E), fontWeight: FontWeight.w600)),
              ),
              Container(
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0EDF8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: options.map((opt) {
                    final isActive = opt == selected;
                    return GestureDetector(
                      onTap: () => onSelected(opt),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: isActive ? const Color(0xFF8B3FD9) : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          opt,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isActive ? Colors.white : const Color(0xFF888888),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        if (!isLast) const Divider(height: 1, indent: 56, endIndent: 16, color: Color(0xFFF0EDF8)),
      ],
    );
  }
}

// Action Tile
class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final Color? labelColor;
  final VoidCallback onTap;
  final bool isLast;

  const _ActionTile({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.onTap,
    this.labelColor,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: isLast ? const BorderRadius.vertical(bottom: Radius.circular(16)) : BorderRadius.zero,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
                  child: Icon(icon, color: iconColor, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(fontSize: 14, color: labelColor ?? const Color(0xFF1A1A2E), fontWeight: FontWeight.w600),
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: labelColor ?? const Color(0xFFCCCCCC), size: 20),
              ],
            ),
          ),
        ),
        if (!isLast) const Divider(height: 1, indent: 56, endIndent: 16, color: Color(0xFFF0EDF8)),
      ],
    );
  }
}

// Personal Info Section
class _PersonalInfoSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, provider, _) => _SectionCard(
        title: 'PERSONAL INFO',
        children: [
          _InfoTile(
            icon: Icons.person_outline,
            iconColor: const Color(0xFF8B3FD9),
            iconBg: const Color(0xFFEDE8F9),
            label: 'Full Name',
            value: provider.profile.name.isEmpty ? 'Not set' : provider.profile.name,
          ),
          _InfoTile(
            icon: Icons.email_outlined,
            iconColor: const Color(0xFF5B7FD9),
            iconBg: const Color(0xFFE8EEF9),
            label: 'Email',
            value: provider.profile.email,
          ),
          _InfoTile(
            icon: Icons.cake_outlined,
            iconColor: const Color(0xFFE94DA0),
            iconBg: const Color(0xFFFDE8F0),
            label: 'Date of Birth',
            value: provider.profile.dateOfBirth.isEmpty ? 'Not set' : provider.profile.dateOfBirth,
          ),
          _InfoTile(
            icon: Icons.local_hospital_outlined,
            iconColor: const Color(0xFF2DB96B),
            iconBg: const Color(0xFFE6F9EE),
            label: 'Doctor',
            value: provider.profile.doctorName.isEmpty ? 'Not set' : provider.profile.doctorName,
            isLast: true,
          ),
        ],
      ),
    );
  }
}

// Cycle Settings Section
class _CycleSettingsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, provider, _) => _SectionCard(
        title: 'CYCLE SETTINGS',
        children: [
          _StepperTile(
            icon: Icons.loop_rounded,
            iconColor: const Color(0xFF8B3FD9),
            iconBg: const Color(0xFFEDE8F9),
            label: 'Cycle Length',
            value: provider.settings.cycleLength,
            unit: 'days',
            onDecrement: () => provider.updateCycleLength(provider.settings.cycleLength - 1),
            onIncrement: () => provider.updateCycleLength(provider.settings.cycleLength + 1),
          ),
          _StepperTile(
            icon: Icons.water_drop_outlined,
            iconColor: const Color(0xFFE94DA0),
            iconBg: const Color(0xFFFDE8F0),
            label: 'Period Length',
            value: provider.settings.periodLength,
            unit: 'days',
            onDecrement: () => provider.updatePeriodLength(provider.settings.periodLength - 1),
            onIncrement: () => provider.updatePeriodLength(provider.settings.periodLength + 1),
            isLast: true,
          ),
        ],
      ),
    );
  }
}

// Notifications Section
class _NotificationsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, provider, _) => _SectionCard(
        title: 'NOTIFICATIONS',
        children: [
          _ToggleTile(
            icon: Icons.notifications_outlined,
            iconColor: const Color(0xFFF5A623),
            iconBg: const Color(0xFFFFF3E0),
            label: 'All Notifications',
            subtitle: 'Master switch for all alerts',
            value: provider.settings.notificationsEnabled,
            onChanged: provider.toggleNotifications,
          ),
          _ToggleTile(
            icon: Icons.water_drop_outlined,
            iconColor: const Color(0xFFE94DA0),
            iconBg: const Color(0xFFFDE8F0),
            label: 'Period Reminder',
            subtitle: '2 days before expected period',
            value: provider.settings.periodReminder,
            onChanged: provider.togglePeriodReminder,
          ),
          _ToggleTile(
            icon: Icons.egg_outlined,
            iconColor: const Color(0xFF2DB96B),
            iconBg: const Color(0xFFE6F9EE),
            label: 'Ovulation Reminder',
            subtitle: 'During fertile window',
            value: provider.settings.ovulationReminder,
            onChanged: provider.toggleOvulationReminder,
          ),
          _ToggleTile(
            icon: Icons.medication_outlined,
            iconColor: const Color(0xFF5B7FD9),
            iconBg: const Color(0xFFE8EEF9),
            label: 'Medication Reminder',
            subtitle: 'Daily medication alerts',
            value: provider.settings.medicationReminder,
            onChanged: provider.toggleMedicationReminder,
            isLast: true,
          ),
        ],
      ),
    );
  }
}

// Units Section
class _UnitsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, provider, _) => _SectionCard(
        title: 'UNITS & PREFERENCES',
        children: [
          _SegmentTile(
            icon: Icons.monitor_weight_outlined,
            iconColor: const Color(0xFF8B3FD9),
            iconBg: const Color(0xFFEDE8F9),
            label: 'Weight',
            options: const ['kg', 'lbs'],
            selected: provider.settings.weightUnit,
            onSelected: provider.updateWeightUnit,
          ),
          _SegmentTile(
            icon: Icons.thermostat_outlined,
            iconColor: const Color(0xFFE94DA0),
            iconBg: const Color(0xFFFDE8F0),
            label: 'Temperature',
            options: const ['°C', '°F'],
            selected: provider.settings.temperatureUnit,
            onSelected: provider.updateTemperatureUnit,
            isLast: true,
          ),
        ],
      ),
    );
  }
}

// Account Section
class _AccountSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, provider, _) => _SectionCard(
        title: 'ACCOUNT',
        children: [
          _ActionTile(
            icon: Icons.lock_outline,
            iconColor: const Color(0xFF5B7FD9),
            iconBg: const Color(0xFFE8EEF9),
            label: 'Change Password',
            onTap: () => _showChangePasswordDialog(context),
          ),
          _ActionTile(
            icon: Icons.file_download_outlined,
            iconColor: const Color(0xFF2DB96B),
            iconBg: const Color(0xFFE6F9EE),
            label: 'Export My Data',
            onTap: () => _showExportDataDialog(context),
          ),
          _ActionTile(
            icon: Icons.shield_outlined,
            iconColor: const Color(0xFF8B3FD9),
            iconBg: const Color(0xFFEDE8F9),
            label: 'Privacy Policy',
            onTap: () => _showPrivacyPolicy(context),
          ),
          _ActionTile(
            icon: Icons.logout_rounded,
            iconColor: const Color(0xFFE94DA0),
            iconBg: const Color(0xFFFDE8F0),
            label: 'Log Out',
            labelColor: const Color(0xFFE94DA0),
            onTap: () => _confirmLogout(context, provider),
          ),
          _ActionTile(
            icon: Icons.delete_outline_rounded,
            iconColor: Colors.red,
            iconBg: const Color(0xFFFFEEEE),
            label: 'Delete Account',
            labelColor: Colors.red,
            onTap: () => _confirmDeleteAccount(context, provider),
            isLast: true,
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Change Password', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(obscureText: true, decoration: const InputDecoration(labelText: 'Current Password', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(obscureText: true, decoration: const InputDecoration(labelText: 'New Password', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(obscureText: true, decoration: const InputDecoration(labelText: 'Confirm New Password', border: OutlineInputBorder())),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Update')),
        ],
      ),
    );
  }

  void _showExportDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Export Data', style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('Your data will be exported as a CSV file.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Export')),
        ],
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Privacy Policy', style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('Your privacy is important to us...'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context, UserProvider provider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => provider.logout(context),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE94DA0)),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context, UserProvider provider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Account', style: TextStyle(color: Colors.red)),
        content: const Text('This action is permanent and cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}