// lib/features/dashboard/presentation/pages/dashboard.dart
import 'package:flutter/material.dart';
import 'package:pcos_tracker/core/constants/app_colors.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().fetchDashboardData();
      context.read<SymptomProvider>().fetchRecentSymptoms();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: Column(
          children: [
            const _TopBar(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await Future.wait([
                    context.read<DashboardProvider>().fetchDashboardData(),
                    context.read<SymptomProvider>().fetchRecentSymptoms(),
                  ]);
                },
                child: Consumer<DashboardProvider>(
                  builder: (context, dashboardProvider, _) {
                    if (dashboardProvider.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      );
                    }
                    
                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _CycleOverviewCard(
                            currentPhase: dashboardProvider.currentPhase,
                            currentCycleDay: dashboardProvider.currentCycleDay,
                            nextPeriodDays: dashboardProvider.nextPeriodDays,
                          ),
                          const SizedBox(height: 16),
                          _HealthStatsGrid(
                            waterIntake: dashboardProvider.waterIntake,
                            waterGoal: dashboardProvider.waterGoal,
                            sleepHours: dashboardProvider.sleepHours,
                            mood: dashboardProvider.mood,
                            weight: dashboardProvider.weight,
                            onWaterTap: () => dashboardProvider.updateWaterIntake(),
                          ),
                          const SizedBox(height: 24),
                          const _RecentSymptomsSection(),
                          const SizedBox(height: 40),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Top Bar
class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    final user = context.read<DashboardProvider>().currentUser;
    final userName = user?.userMetadata?['first_name'] ?? 
                     user?.userMetadata?['name'] ?? 
                     'User';
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'CycleSync',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A2E),
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                'Hello, $userName 👋',
                style: const TextStyle(fontSize: 13, color: Color(0xFF888888)),
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

// Cycle Overview Card
class _CycleOverviewCard extends StatelessWidget {
  final String currentPhase;
  final int currentCycleDay;
  final int nextPeriodDays;
  
  const _CycleOverviewCard({
    required this.currentPhase,
    required this.currentCycleDay,
    required this.nextPeriodDays,
  });

  @override
  Widget build(BuildContext context) {
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
            color: const Color(0xFF8B3FD9).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current Phase: $currentPhase',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Text(
            'Day $currentCycleDay',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 42,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            nextPeriodDays > 0 
                ? 'Next period predicted in $nextPeriodDays days'
                : 'Period may be starting soon',
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

// Health Stats Grid
class _HealthStatsGrid extends StatelessWidget {
  final int waterIntake;
  final int waterGoal;
  final double sleepHours;
  final String mood;
  final double weight;
  final VoidCallback onWaterTap;
  
  const _HealthStatsGrid({
    required this.waterIntake,
    required this.waterGoal,
    required this.sleepHours,
    required this.mood,
    required this.weight,
    required this.onWaterTap,
  });

  @override
  Widget build(BuildContext context) {
    final waterPercentage = waterGoal > 0 ? ((waterIntake / waterGoal) * 100).toInt() : 0;
    final waterDisplay = waterIntake >= 1000 
        ? '${(waterIntake / 1000).toStringAsFixed(1)}L' 
        : '${waterIntake}ml';
    
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.water_drop_outlined,
                iconBgColor: const Color(0xFFE0F2FE),
                iconColor: Colors.blue,
                label: 'Water',
                value: waterDisplay,
                subtitle: '$waterPercentage% of goal',
                onTap: onWaterTap,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.nightlight_round_outlined,
                iconBgColor: const Color(0xFFEDE8F9),
                iconColor: const Color(0xFF8B3FD9),
                label: 'Sleep',
                value: sleepHours > 0 ? '${sleepHours.toStringAsFixed(1)}h' : '--',
                subtitle: sleepHours > 0 ? 'Last night' : 'No data',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.favorite_border,
                iconBgColor: const Color(0xFFFDE8F0),
                iconColor: const Color(0xFFE94DA0),
                label: 'Mood',
                value: mood,
                subtitle: 'Today',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.fitness_center_outlined,
                iconBgColor: const Color(0xFFE6F9EE),
                iconColor: const Color(0xFF2DB96B),
                label: 'Weight',
                value: weight > 0 ? '${weight.toStringAsFixed(1)} kg' : '--',
                subtitle: weight > 0 ? 'Current' : 'Not logged',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Stat Card
class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String label;
  final String value;
  final String subtitle;
  final VoidCallback? onTap;

  const _StatCard({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.label,
    required this.value,
    this.subtitle = '',
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
            if (subtitle.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Recent Symptoms Section
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
              'Latest Symptoms',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            TextButton(
              onPressed: () {
                // Navigate to symptoms page
              },
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Consumer<SymptomProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            
            if (provider.recentSymptoms.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Column(
                    children: [
                      Icon(Icons.sick, size: 48, color: Colors.grey),
                      SizedBox(height: 12),
                      Text(
                        "No symptoms logged yet",
                        style: TextStyle(color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Tap + to log your first symptom",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              );
            }
            
            final displaySymptoms = provider.recentSymptoms.length > 3 
                ? provider.recentSymptoms.sublist(0, 3)
                : provider.recentSymptoms;
            
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displaySymptoms.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final symptom = displaySymptoms[index];
                return _SymptomTile(
                  name: symptom.name,
                  severity: symptom.severity,
                  date: _formatDate(symptom.date),
                );
              },
            );
          },
        ),
      ],
    );
  }
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) return 'Today';
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays} days ago';
    return '${date.day}/${date.month}';
  }
}

// Symptom Tile
class _SymptomTile extends StatelessWidget {
  final String name;
  final String severity;
  final String date;

  const _SymptomTile({
    required this.name,
    required this.severity,
    required this.date,
  });

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
          const Icon(Icons.healing, color: Color(0xFFE94DA0)),
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
              color: _getSeverityColor(severity).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              severity,
              style: TextStyle(
                fontSize: 11, 
                fontWeight: FontWeight.w600,
                color: _getSeverityColor(severity),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'mild': return Colors.green;
      case 'moderate': return Colors.orange;
      case 'severe': return Colors.red;
      default: return Colors.grey;
    }
  }
}