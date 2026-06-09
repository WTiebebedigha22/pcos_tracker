import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/profile_provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),
      body: SafeArea(
        child: Column(
          children: [
            _ProfileAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    _AvatarHeader(),
                    const SizedBox(height: 24),
                    _PersonalInfoSection(),
                    const SizedBox(height: 16),
                    _HealthSettingsSection(),
                    const SizedBox(height: 16),
                    _NotificationsSection(),
                    const SizedBox(height: 16),
                    _UnitsSection(),
                    const SizedBox(height: 16),
                    _AccountSection(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// App Bar
// ─────────────────────────────────────────────
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
            onPressed: () => _showEditNameDialog(context),
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

  void _showEditNameDialog(BuildContext context) {
    final provider = context.read<UserProvider>();
    final nameCtrl = TextEditingController(text: provider.profile.name);
    final emailCtrl = TextEditingController(text: provider.profile.email);
    final doctorCtrl = TextEditingController(text: provider.profile.doctorName);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Edit Profile',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
            const SizedBox(height: 20),
            _EditField(controller: nameCtrl, label: 'Full Name', icon: Icons.person_outline),
            const SizedBox(height: 12),
            _EditField(controller: emailCtrl, label: 'Email', icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 12),
            _EditField(controller: doctorCtrl, label: "Doctor's Name", icon: Icons.local_hospital_outlined),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  provider.updateName(nameCtrl.text.trim());
                  provider.updateEmail(emailCtrl.text.trim());
                  provider.updateDoctorName(doctorCtrl.text.trim());
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B3FD9),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: const Text('Save Changes',
                    style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;

  const _EditField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 15, color: Color(0xFF1A1A2E)),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF8B3FD9), size: 20),
        labelStyle: const TextStyle(color: Color(0xFF888888), fontSize: 14),
        filled: true,
        fillColor: const Color(0xFFF8F7FC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE8E4F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE8E4F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF8B3FD9), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Avatar Header
// ─────────────────────────────────────────────
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
                        color: const Color(0xFF8B3FD9).withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    provider.avatarInitial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
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
              child: const Text(
                'PCOS Diagnosed · 2021',
                style: TextStyle(
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

// ─────────────────────────────────────────────
// Section Card wrapper
// ─────────────────────────────────────────────
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
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 2)),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Row tiles
// ─────────────────────────────────────────────
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
                child: Text(label,
                    style: const TextStyle(fontSize: 14, color: Color(0xFF555555), fontWeight: FontWeight.w500)),
              ),
              Text(value,
                  style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A2E), fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        if (!isLast)
          const Divider(height: 1, indent: 56, endIndent: 16, color: Color(0xFFF0EDF8)),
      ],
    );
  }
}

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
                    Text(label,
                        style: const TextStyle(
                            fontSize: 14, color: Color(0xFF1A1A2E), fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: const TextStyle(fontSize: 12, color: Color(0xFFAAAAAA))),
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
        if (!isLast)
          const Divider(height: 1, indent: 56, endIndent: 16, color: Color(0xFFF0EDF8)),
      ],
    );
  }
}

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
                child: Text(label,
                    style: const TextStyle(
                        fontSize: 14, color: Color(0xFF1A1A2E), fontWeight: FontWeight.w600)),
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
                  Text('$value $unit',
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
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
        if (!isLast)
          const Divider(height: 1, indent: 56, endIndent: 16, color: Color(0xFFF0EDF8)),
      ],
    );
  }
}

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
                child: Text(label,
                    style: const TextStyle(
                        fontSize: 14, color: Color(0xFF1A1A2E), fontWeight: FontWeight.w600)),
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
        if (!isLast)
          const Divider(height: 1, indent: 56, endIndent: 16, color: Color(0xFFF0EDF8)),
      ],
    );
  }
}

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
          borderRadius: isLast
              ? const BorderRadius.vertical(bottom: Radius.circular(16))
              : BorderRadius.zero,
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
                    style: TextStyle(
                      fontSize: 14,
                      color: labelColor ?? const Color(0xFF1A1A2E),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    color: labelColor ?? const Color(0xFFCCCCCC), size: 20),
              ],
            ),
          ),
        ),
        if (!isLast)
          const Divider(height: 1, indent: 56, endIndent: 16, color: Color(0xFFF0EDF8)),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Sections
// ─────────────────────────────────────────────
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
            value: provider.profile.name,
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
            value: provider.profile.dateOfBirth,
          ),
          _InfoTile(
            icon: Icons.local_hospital_outlined,
            iconColor: const Color(0xFF2DB96B),
            iconBg: const Color(0xFFE6F9EE),
            label: 'Doctor',
            value: provider.profile.doctorName,
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _HealthSettingsSection extends StatelessWidget {
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
            onDecrement: () {
              if (provider.settings.cycleLength > 21) {
                provider.updateCycleLength(provider.settings.cycleLength - 1);
              }
            },
            onIncrement: () {
              if (provider.settings.cycleLength < 45) {
                provider.updateCycleLength(provider.settings.cycleLength + 1);
              }
            },
          ),
          _StepperTile(
            icon: Icons.water_drop_outlined,
            iconColor: const Color(0xFFE94DA0),
            iconBg: const Color(0xFFFDE8F0),
            label: 'Period Length',
            value: provider.settings.periodLength,
            unit: 'days',
            onDecrement: () {
              if (provider.settings.periodLength > 2) {
                provider.updatePeriodLength(provider.settings.periodLength - 1);
              }
            },
            onIncrement: () {
              if (provider.settings.periodLength < 10) {
                provider.updatePeriodLength(provider.settings.periodLength + 1);
              }
            },
            isLast: true,
          ),
        ],
      ),
    );
  }
}

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

class _AccountSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'ACCOUNT',
      children: [
        _ActionTile(
          icon: Icons.lock_outline,
          iconColor: const Color(0xFF5B7FD9),
          iconBg: const Color(0xFFE8EEF9),
          label: 'Change Password',
          onTap: () {},
        ),
        _ActionTile(
          icon: Icons.file_download_outlined,
          iconColor: const Color(0xFF2DB96B),
          iconBg: const Color(0xFFE6F9EE),
          label: 'Export My Data',
          onTap: () {},
        ),
        _ActionTile(
          icon: Icons.shield_outlined,
          iconColor: const Color(0xFF8B3FD9),
          iconBg: const Color(0xFFEDE8F9),
          label: 'Privacy Policy',
          onTap: () {},
        ),
        _ActionTile(
          icon: Icons.logout_rounded,
          iconColor: const Color(0xFFE94DA0),
          iconBg: const Color(0xFFFDE8F0),
          label: 'Log Out',
          labelColor: const Color(0xFFE94DA0),
          onTap: () => _confirmLogout(context),
        ),
        _ActionTile(
          icon: Icons.delete_outline_rounded,
          iconColor: Colors.red,
          iconBg: const Color(0xFFFFEEEE),
          label: 'Delete Account',
          labelColor: Colors.red,
          onTap: () {},
          isLast: true,
        ),
      ],
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Log Out',
            style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
        content: const Text('Are you sure you want to log out?',
            style: TextStyle(color: Color(0xFF666666))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF888888))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE94DA0),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Log Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}