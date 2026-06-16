// lib/features/insights/presentation/pages/insights_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/app_colors.dart';
import '../provider/insight_provider.dart';
import '../../../cycle_tracking/presentation/provider/cycle_provider.dart';
import '../../../symptoms/presentation/provider/symptoms_provider.dart';

class InsightsPage extends StatefulWidget {
  const InsightsPage({super.key});

  @override
  State<InsightsPage> createState() => _InsightsPageState();
}

class _InsightsPageState extends State<InsightsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedTimeRange = 'month'; // week, month, year

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      context.read<InsightProvider>().fetchInsights(),
      context.read<CycleProvider>().fetchCycles(),
      context.read<SymptomProvider>().fetchAllSymptoms(),
    ]);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Insights & Analytics',
          style: TextStyle(color: Color(0xFF1A1A2E), fontWeight: FontWeight.w700),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Cycle', icon: Icon(Icons.calendar_month)),
            Tab(text: 'Symptoms', icon: Icon(Icons.sick)),
            Tab(text: 'Health', icon: Icon(Icons.favorite)),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: TabBarView(
          controller: _tabController,
          children: const [
            _CycleInsightsTab(),
            _SymptomsInsightsTab(),
            _HealthInsightsTab(),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Cycle Insights Tab
// ─────────────────────────────────────────────
class _CycleInsightsTab extends StatelessWidget {
  const _CycleInsightsTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<InsightProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InsightCard(
                title: 'Cycle Summary',
                icon: Icons.circle_notifications,
                iconColor: AppColors.primary,
                child: Column(
                  children: [
                    _StatRow(
                      label: 'Average Cycle Length',
                      value: '${provider.averageCycleLength} days',
                      icon: Icons.timeline,
                    ),
                    const Divider(),
                    _StatRow(
                      label: 'Average Period Length',
                      value: '${provider.averagePeriodLength} days',
                      icon: Icons.water_drop,
                    ),
                    const Divider(),
                    _StatRow(
                      label: 'Last Period',
                      value: provider.lastPeriodDate ?? 'Not logged',
                      icon: Icons.calendar_today,
                    ),
                    const Divider(),
                    _StatRow(
                      label: 'Next Predicted Period',
                      value: provider.nextPredictedPeriod ?? 'Log more cycles',
                      icon: Icons.date_range,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _InsightCard(
                title: 'Cycle Pattern',
                icon: Icons.show_chart,
                iconColor: Colors.blue,
                child: SizedBox(
                  height: 200,
                  child: _CycleLengthChart(),
                ),
              ),
              const SizedBox(height: 16),
              _InsightCard(
                title: 'PCOS Insights',
                icon: Icons.health_and_safety,
                iconColor: const Color(0xFFE94DA0),
                child: Column(
                  children: [
                    _getPCOSInsightMessage(provider),
                    const SizedBox(height: 12),
                    _RecommendationTile(
                      title: 'Track Irregularities',
                      description: 'Log any irregular cycles to help predict patterns',
                      icon: Icons.warning_amber,
                    ),
                    const SizedBox(height: 8),
                    _RecommendationTile(
                      title: 'Monitor Symptoms',
                      description: 'Regular symptom tracking helps identify triggers',
                      icon: Icons.sick,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _getPCOSInsightMessage(InsightProvider provider) {
    if (provider.averageCycleLength > 35) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFDE8F0),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            Icon(Icons.info, color: Color(0xFFE94DA0)),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Your cycles are longer than average. This is common with PCOS. Continue tracking to identify patterns.',
                style: TextStyle(fontSize: 13, height: 1.4),
              ),
            ),
          ],
        ),
      );
    } else if (provider.cycleRegularityScore < 0.7) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3E0),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            Icon(Icons.trending_up, color: Colors.orange),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Your cycle shows some irregularity. Tracking consistently will help improve predictions.',
                style: TextStyle(fontSize: 13, height: 1.4),
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFE6F9EE),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Your cycle patterns are becoming more regular. Keep up the good work!',
                style: TextStyle(fontSize: 13, height: 1.4),
              ),
            ),
          ],
        ),
      );
    }
  }
}

// ─────────────────────────────────────────────
// Symptoms Insights Tab
// ─────────────────────────────────────────────
class _SymptomsInsightsTab extends StatelessWidget {
  const _SymptomsInsightsTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<InsightProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InsightCard(
                title: 'Symptom Overview',
                icon: Icons.analytics,
                iconColor: Colors.green,
                child: SizedBox(
                  height: 200,
                  child: _SymptomFrequencyChart(),
                ),
              ),
              const SizedBox(height: 16),
              _InsightCard(
                title: 'Most Common Symptoms',
                icon: Icons.favorite,
                iconColor: const Color(0xFFE94DA0),
                child: Column(
                  children: provider.topSymptoms.map((symptom) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: _StatRow(
                        label: symptom['name'] as String,
                        value: '${symptom['count']} times',
                        icon: Icons.circle,
                        iconColor: symptom['color'] as Color?,
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              _InsightCard(
                title: 'Symptom Patterns',
                icon: Icons.pattern,
                iconColor: Colors.purple,
                child: Column(
                  children: [
                    _RecommendationTile(
                      title: 'Fatigue Pattern',
                      description: provider.getFatiguePattern(),
                      icon: Icons.bed,
                    ),
                    const SizedBox(height: 8),
                    _RecommendationTile(
                      title: 'Mood Pattern',
                      description: provider.getMoodPattern(),
                      icon: Icons.mood,
                    ),
                    const SizedBox(height: 8),
                    _RecommendationTile(
                      title: 'Sleep Impact',
                      description: provider.getSleepImpact(),
                      icon: Icons.nightlight,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// Health Insights Tab
// ─────────────────────────────────────────────
class _HealthInsightsTab extends StatelessWidget {
  const _HealthInsightsTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<InsightProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InsightCard(
                title: 'Health Score',
                icon: Icons.health_and_safety,
                iconColor: Colors.green,
                child: Column(
                  children: [
                    _HealthScoreGauge(score: provider.healthScore),
                    const SizedBox(height: 16),
                    _StatRow(
                      label: 'Water Intake Avg',
                      value: '${provider.averageWaterIntake}ml/day',
                      icon: Icons.water_drop,
                    ),
                    const Divider(),
                    _StatRow(
                      label: 'Sleep Avg',
                      value: '${provider.averageSleepHours}h/night',
                      icon: Icons.bed,
                    ),
                    const Divider(),
                    _StatRow(
                      label: 'Mood Avg',
                      value: provider.averageMoodRating,
                      icon: Icons.mood,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _InsightCard(
                title: 'Recommendations',
                icon: Icons.lightbulb,
                iconColor: Colors.amber,
                child: Column(
                  children: [
                    _RecommendationTile(
                      title: 'Hydration Goal',
                      description: provider.getHydrationRecommendation(),
                      icon: Icons.water_drop,
                    ),
                    const SizedBox(height: 8),
                    _RecommendationTile(
                      title: 'Sleep Improvement',
                      description: provider.getSleepRecommendation(),
                      icon: Icons.nightlight,
                    ),
                    const SizedBox(height: 8),
                    _RecommendationTile(
                      title: 'Stress Management',
                      description: provider.getStressRecommendation(),
                      icon: Icons.self_improvement,
                    ),
                    const SizedBox(height: 8),
                    _RecommendationTile(
                      title: 'Exercise',
                      description: provider.getExerciseRecommendation(),
                      icon: Icons.fitness_center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _InsightCard(
                title: 'Doctor Discussion Points',
                icon: Icons.local_hospital,
                iconColor: Colors.red,
                child: Column(
                  children: provider.getDoctorDiscussionPoints().map((point) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
                          const SizedBox(width: 8),
                          Expanded(child: Text(point, style: const TextStyle(fontSize: 13))),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// Supporting Widgets
// ─────────────────────────────────────────────
class _InsightCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Widget child;

  const _InsightCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF0EDF8)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? iconColor;

  const _StatRow({
    required this.label,
    required this.value,
    required this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: iconColor ?? AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, style: const TextStyle(fontSize: 14, color: Color(0xFF555555))),
        ),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
      ],
    );
  }
}

class _RecommendationTile extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const _RecommendationTile({
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F7FC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 4),
                Text(description, style: const TextStyle(fontSize: 12, color: Color(0xFF888888))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CycleLengthChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<InsightProvider>(
      builder: (context, provider, _) {
        final spots = provider.getCycleLengthSpots();
        
        return LineChart(
          LineChartData(
            gridData: const FlGridData(show: true),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    return Text(provider.getMonthLabel(value.toInt()), style: const TextStyle(fontSize: 10));
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    return Text('${value.toInt()}d', style: const TextStyle(fontSize: 10));
                  },
                ),
              ),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: AppColors.primary,
                barWidth: 3,
                dotData: const FlDotData(show: true),
                belowBarData: BarAreaData(
                  show: true,
                  color: AppColors.primary.withOpacity(0.1),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SymptomFrequencyChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<InsightProvider>(
      builder: (context, provider, _) {
        final bars = provider.getSymptomFrequencyBars();
        
        return BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: provider.getMaxSymptomCount().toDouble(),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final symptom = provider.getSymptomAtIndex(value.toInt());
                    return Text(symptom['shortName'] as String, style: const TextStyle(fontSize: 10));
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    return Text(value.toInt().toString(), style: const TextStyle(fontSize: 10));
                  },
                ),
              ),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            barGroups: bars,
            gridData: const FlGridData(show: true),
          ),
        );
      },
    );
  }
}

class _HealthScoreGauge extends StatelessWidget {
  final int score;
  
  const _HealthScoreGauge({required this.score});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 120,
              height: 120,
              child: CircularProgressIndicator(
                value: score / 100,
                strokeWidth: 12,
                backgroundColor: const Color(0xFFF0EDF8),
                valueColor: AlwaysStoppedAnimation<Color>(_getScoreColor()),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$score',
                  style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
                ),
                const Text('out of 100', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(_getScoreLabel(), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _getScoreColor())),
      ],
    );
  }
  
  Color _getScoreColor() {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }
  
  String _getScoreLabel() {
    if (score >= 80) return 'Excellent';
    if (score >= 60) return 'Good';
    if (score >= 40) return 'Fair';
    return 'Needs Attention';
  }
}