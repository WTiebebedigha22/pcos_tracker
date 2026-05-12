import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../symptoms/presentation/provider/symptoms_provider.dart';
import '../providers/dashboard_provider.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    // Fetch fresh data when the dashboard loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().fetchDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7FC), // Updated to your app's theme
      body: SafeArea(
        child: Column(
          children: [
            const _TopBar(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => context.read<DashboardProvider>().fetchDashboardData(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _CycleOverviewCard(),
                      const SizedBox(height: 16),
                      _HealthStatsGrid(),
                      const SizedBox(height: 24),
                      const _RecentSymptomsSection(),
                      const SizedBox(height: 40), 
                    ],
                  ),
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
// Top Bar - Integrated with ProfileProvider
// ─────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  const _TopBar();

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
                'CycleSync', // Using your App title from main.dart
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A2E),
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                'Your hormonal health at a glance',
                style: TextStyle(fontSize: 13, color: Color(0xFF888888)),
              ),
            ],
          ),
          const CircleAvatar(
            radius: 22,
            backgroundColor: Color(0xFF8B3FD9),
            child: Icon(Icons.person_outline, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Cycle Overview Card - Data Driven
// ─────────────────────────────────────────────
class _CycleOverviewCard extends StatelessWidget {
  const _CycleOverviewCard();

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, provider, _) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF8B3FD9), Color(0xFFE94DA0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8B3FD9).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Current Phase: Ovulatory',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Text(
                'Day ${provider.currentCycleDay}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Next period predicted in 12 days',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// Recent Symptoms - Using SymptomProvider
// ─────────────────────────────────────────────
class _RecentSymptomsSection extends StatelessWidget {
  const _RecentSymptomsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Latest Logs',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            TextButton(
              onPressed: () {}, // Navigate to full logs
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Consumer<SymptomProvider>(
          builder: (context, provider, _) {
            if (provider.recentSymptoms.isEmpty) {
              return const Center(child: Text("No symptoms logged yet."));
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: provider.recentSymptoms.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final symptom = provider.recentSymptoms[index];
                return _SymptomTile(
                  name: symptom.name,
                  severity: symptom.severity,
                  date: 'Today',
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class _SymptomTile extends StatelessWidget {
  final String name;
  final String severity;
  final String date;

  const _SymptomTile({required this.name, required this.severity, required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.water_drop_outlined, color: Color(0xFFE94DA0)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(date, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F7FC),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              severity,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _HealthStatsGrid extends StatelessWidget {
  const _HealthStatsGrid();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Consumer<DashboardProvider>(
                builder: (context, provider, _) => _StatCard(
                  icon: Icons.water_drop_outlined,
                  iconBgColor: const Color(0xFFE0F2FE),
                  iconColor: Colors.blue,
                  label: 'Water',
                  value: '${provider.waterIntake} glasses',
                  onTap: () => provider.updateWaterIntake(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: _StatCard(
                icon: Icons.nightlight_round_outlined,
                iconBgColor: Color(0xFFEDE8F9),
                iconColor: Color(0xFF8B3FD9),
                label: 'Sleep',
                value: '7.5h',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Expanded(
              child: _StatCard(
                icon: Icons.favorite_border,
                iconBgColor: Color(0xFFFDE8F0),
                iconColor: Color(0xFFE94DA0),
                label: 'Mood',
                value: 'Stable',
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: _StatCard(
                icon: Icons.fitness_center_outlined,
                iconBgColor: Color(0xFFE6F9EE),
                iconColor: Color(0xFF2DB96B),
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
  final VoidCallback? onTap;

  const _StatCard({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF5F5F5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(height: 12),
            Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}