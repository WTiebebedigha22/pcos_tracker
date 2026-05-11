import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CycleOverviewCard(),
                    const SizedBox(height: 16),
                    _HealthStatsGrid(),
                    const SizedBox(height: 20),
                    _RecentSymptomsSection(),
                    const SizedBox(height: 80), // space for FAB
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _LogSymptomButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _BottomNavBar(),
    );
  }
}

// ─────────────────────────────────────────────
// Top Bar
// ─────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'PCOS Tracker',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                  letterSpacing: -0.3,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Take control of your health',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF888888),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFFB06FD8),
            child: const Text(
              'M',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Cycle Overview Card
// ─────────────────────────────────────────────
class _CycleOverviewCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8B3FD9), Color(0xFFE94DA0)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Cycle Overview',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.calendar_today_outlined,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Day 14',
            style: TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Next period in ~14 days',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'May 25',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Health Stats Grid (2x2)
// ─────────────────────────────────────────────
class _HealthStatsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.favorite_border,
                iconBgColor: const Color(0xFFFDE8F0),
                iconColor: const Color(0xFFE94DA0),
                label: 'Mood',
                value: 'Good',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.show_chart,
                iconBgColor: const Color(0xFFE8EEF9),
                iconColor: const Color(0xFF5B7FD9),
                label: 'Energy',
                value: '7/10',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.nightlight_round,
                iconBgColor: const Color(0xFFEDE8F9),
                iconColor: const Color(0xFF8B3FD9),
                label: 'Sleep',
                value: '7.5h',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.trending_up,
                iconBgColor: const Color(0xFFE6F9EE),
                iconColor: const Color(0xFF2DB96B),
                label: 'Weight',
                value: '65 kg',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 16),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF888888),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E),
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Recent Symptoms Section
// ─────────────────────────────────────────────
class _RecentSymptomsSection extends StatelessWidget {
  final List<_SymptomData> symptoms = const [
    _SymptomData(
      name: 'Mild cramps',
      time: 'Today, 2:30 PM',
      severity: 'Moderate',
      dotColor: Color(0xFFF5A623),
    ),
    _SymptomData(
      name: 'Bloating',
      time: 'Yesterday, 11:00 AM',
      severity: 'Mild',
      dotColor: Color(0xFF5B7FD9),
    ),
    _SymptomData(
      name: 'Acne breakout',
      time: '2 days ago',
      severity: 'Mild',
      dotColor: Color(0xFFE94DA0),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Recent Symptoms',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              Text(
                'View all',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF8B3FD9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...symptoms.map((s) => _SymptomRow(data: s)).toList(),
        ],
      ),
    );
  }
}

class _SymptomData {
  final String name;
  final String time;
  final String severity;
  final Color dotColor;

  const _SymptomData({
    required this.name,
    required this.time,
    required this.severity,
    required this.dotColor,
  });
}

class _SymptomRow extends StatelessWidget {
  final _SymptomData data;

  const _SymptomRow({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: data.dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  data.time,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFAAAAAA),
                  ),
                ),
              ],
            ),
          ),
          Text(
            data.severity,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFFAAAAAA),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Log Symptom Button
// ─────────────────────────────────────────────
class _LogSymptomButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.add, color: Colors.white, size: 20),
        label: const Text(
          'Log Symptom',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8B3FD9),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Bottom Navigation Bar
// ─────────────────────────────────────────────
class _BottomNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.white,
      elevation: 8,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(icon: Icons.home_outlined, label: 'Home', isActive: true),
            _NavItem(icon: Icons.loop_outlined, label: 'Cycle'),
            _NavItem(icon: Icons.assignment_outlined, label: 'Symptoms'),
            _NavItem(icon: Icons.medication_outlined, label: 'Meds'),
            _NavItem(icon: Icons.show_chart, label: 'Progress'),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;

  const _NavItem({
    required this.icon,
    required this.label,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? const Color(0xFF8B3FD9) : const Color(0xFFAAAAAA);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}