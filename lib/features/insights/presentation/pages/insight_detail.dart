// lib/features/insights/presentation/pages/insights_detail_page.dart
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../cycle_tracking/presentation/provider/cycle_provider.dart';
import '../../../symptoms/presentation/provider/symptoms_provider.dart';
import '../provider/insight_provider.dart';

class InsightsDetailPage extends StatefulWidget {
  final String insightType;
  
  const InsightsDetailPage({
    super.key,
    required this.insightType,
  });

  @override
  State<InsightsDetailPage> createState() => _InsightsDetailPageState();
}

class _InsightsDetailPageState extends State<InsightsDetailPage> {
  bool _isLoading = true;
  String _timeRange = '3 months';
  final List<String> _timeRanges = ['1 month', '3 months', '6 months', '1 year'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await Future.wait([
      context.read<InsightProvider>().fetchInsights(),
      context.read<CycleProvider>().fetchCycles(),
      context.read<SymptomProvider>().fetchAllSymptoms(),
    ]);
    setState(() => _isLoading = false);
  }

  String _getInsightTitle() {
    switch (widget.insightType) {
      case 'cycle':
        return 'Cycle Insights';
      case 'symptom':
        return 'Symptom Insights';
      case 'health':
        return 'Health Insights';
      default:
        return 'Insights';
    }
  }

  IconData _getInsightIcon() {
    switch (widget.insightType) {
      case 'cycle':
        return Icons.calendar_month;
      case 'symptom':
        return Icons.sick;
      case 'health':
        return Icons.favorite;
      default:
        return Icons.insights;
    }
  }

  Color _getInsightColor() {
    switch (widget.insightType) {
      case 'cycle':
        return AppColors.primary;
      case 'symptom':
        return const Color(0xFFE94DA0);
      case 'health':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          _getInsightTitle(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              setState(() => _timeRange = value);
            },
            itemBuilder: (context) => _timeRanges.map((range) {
              return PopupMenuItem(
                value: range,
                child: Row(
                  children: [
                    if (_timeRange == range)
                      const Icon(Icons.check, color: AppColors.primary, size: 18),
                    const SizedBox(width: 8),
                    Text(range),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildSummaryCard(),
                  const SizedBox(height: 16),
                  _buildDetailContent(),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getInsightColor().withValues(alpha: 0.9),
            _getInsightColor().withValues(alpha: 0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _getInsightColor().withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(_getInsightIcon(), color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getInsightTitle(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getSummaryText(),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Updated',
              style: TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  String _getSummaryText() {
    switch (widget.insightType) {
      case 'cycle':
        return 'Track your cycle patterns and predictions';
      case 'symptom':
        return 'Monitor symptom frequency and patterns';
      case 'health':
        return 'Track your overall health metrics';
      default:
        return 'Detailed insights for your health';
    }
  }

  Widget _buildDetailContent() {
    switch (widget.insightType) {
      case 'cycle':
        return _buildCycleInsights();
      case 'symptom':
        return _buildSymptomInsights();
      case 'health':
        return _buildHealthInsights();
      default:
        return _buildGeneralInsights();
    }
  }

  Widget _buildCycleInsights() {
    return Consumer<CycleProvider>(
      builder: (context, provider, _) {
        final cycles = provider.cycles;
        
        if (cycles.isEmpty) {
          return _buildEmptyState();
        }

        return Column(
          children: [
            _StatCard(
              title: 'Average Cycle Length',
              value: '${_calculateAverageCycleLength(cycles)} days',
              icon: Icons.timeline,
              color: AppColors.primary,
            ),
            const SizedBox(height: 12),
            _StatCard(
              title: 'Average Period Length',
              value: '${_calculateAveragePeriodLength(cycles)} days',
              icon: Icons.water_drop,
              color: const Color(0xFFE94DA0),
            ),
            const SizedBox(height: 12),
            _StatCard(
              title: 'Cycle Regularity',
              value: _calculateRegularity(cycles),
              icon: Icons.show_chart,
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            _buildCycleChart(cycles),
            const SizedBox(height: 16),
            _buildCycleInsightsList(cycles),
          ],
        );
      },
    );
  }

  Widget _buildSymptomInsights() {
    return Consumer<SymptomProvider>(
      builder: (context, provider, _) {
        final symptoms = provider.allSymptoms;
        
        if (symptoms.isEmpty) {
          return _buildEmptyState();
        }

        return Column(
          children: [
            _StatCard(
              title: 'Total Symptoms Logged',
              value: '${symptoms.length}',
              icon: Icons.sick,
              color: const Color(0xFFE94DA0),
            ),
            const SizedBox(height: 12),
            _StatCard(
              title: 'Most Common Symptom',
              value: _getMostCommonSymptom(symptoms),
              icon: Icons.favorite,
              color: Colors.orange,
            ),
            const SizedBox(height: 12),
            _StatCard(
              title: 'Average Severity',
              value: _getAverageSeverity(symptoms),
              icon: Icons.signal_cellular_alt,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            _buildSymptomFrequencyChart(symptoms),
            const SizedBox(height: 16),
            _buildSymptomInsightsList(symptoms),
          ],
        );
      },
    );
  }

  Widget _buildHealthInsights() {
    return Consumer<InsightProvider>(
      builder: (context, provider, _) {
        return Column(
          children: [
            _StatCard(
              title: 'Health Score',
              value: '${provider.healthScore}/100',
              icon: Icons.health_and_safety,
              color: Colors.green,
            ),
            const SizedBox(height: 12),
            _StatCard(
              title: 'Hydration Average',
              value: '${provider.averageWaterIntake}ml',
              icon: Icons.water_drop,
              color: Colors.blue,
            ),
            const SizedBox(height: 12),
            _StatCard(
              title: 'Sleep Average',
              value: '${provider.averageSleepHours.toStringAsFixed(1)}h',
              icon: Icons.bed,
              color: Colors.purple,
            ),
            const SizedBox(height: 16),
            _buildHealthRecommendations(),
          ],
        );
      },
    );
  }

  Widget _buildGeneralInsights() {
    return _buildEmptyState();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.insights_outlined,
            size: 64,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          const Text(
            'No data available yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Start tracking your health to see insights here',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // Helper methods for cycle insights
  int _calculateAverageCycleLength(List cycles) {
    if (cycles.length < 2) return 0;
    
    int totalDays = 0;
    int count = 0;
    for (int i = 1; i < cycles.length; i++) {
      final prevStart = cycles[i - 1].startDate;
      final currStart = cycles[i].startDate;
      final daysDiff = currStart.difference(prevStart).inDays;
      if (daysDiff > 20 && daysDiff < 60) {
        totalDays += daysDiff;
        count++;
      }
    }
    if (count == 0) return 0;
    return (totalDays / count).floor();
  }

  int _calculateAveragePeriodLength(List cycles) {
    int totalDays = 0;
    int count = 0;
    for (final cycle in cycles) {
      if (cycle.endDate != null) {
        final days = cycle.endDate!.difference(cycle.startDate).inDays + 1;
        totalDays += days;
        count++;
      }
    }
    if (count == 0) return 0;
    return (totalDays / count).floor();
  }

  String _calculateRegularity(List cycles) {
    if (cycles.length < 3) return 'Insufficient data';
    
    List<int> lengths = [];
    for (int i = 1; i < cycles.length; i++) {
      final diff = cycles[i - 1].startDate.difference(cycles[i].startDate).inDays;
      if (diff > 20 && diff < 60) {
        lengths.add(diff);
      }
    }
    
    if (lengths.isEmpty) return 'Insufficient data';
    
    final total = lengths.reduce((a, b) => a + b);
    final avg = total / lengths.length;
    double varianceSum = 0.0;
    for (final length in lengths) {
      varianceSum += (length - avg) * (length - avg);
    }
    final variance = varianceSum / lengths.length;
    final stdDev = math.sqrt(variance);
    
    if (stdDev <= 3.0) return 'Very Regular';
    if (stdDev <= 5.0) return 'Regular';
    if (stdDev <= 7.0) return 'Somewhat Irregular';
    return 'Irregular';
  }

  String _getMostCommonSymptom(List symptoms) {
    if (symptoms.isEmpty) return 'None';
    
    final Map<String, int> counts = {};
    for (final symptom in symptoms) {
      for (final s in symptom.symptoms) {
        counts[s] = (counts[s] ?? 0) + 1;
      }
    }
    
    if (counts.isEmpty) return 'None';
    
    String mostCommon = '';
    int highestCount = 0;
    for (final entry in counts.entries) {
      if (entry.value > highestCount) {
        highestCount = entry.value;
        mostCommon = entry.key;
      }
    }
    return mostCommon;
  }

  String _getAverageSeverity(List symptoms) {
    if (symptoms.isEmpty) return 'N/A';
    
    int total = 0;
    for (final symptom in symptoms) {
      total += symptom.symptoms.length;
    }
    if (total == 0) return 'None';
    final double avg = total / symptoms.length;
    if (avg <= 2.0) return 'Mild';
    if (avg <= 4.0) return 'Moderate';
    return 'Severe';
  }

  // Chart builders
  Widget _buildCycleChart(List cycles) {
    final cycleLengths = <FlSpot>[];
    for (int i = 1; i < cycles.length && i < 12; i++) {
      final diff = cycles[i - 1].startDate.difference(cycles[i].startDate).inDays;
      if (diff > 20 && diff < 60) {
        cycleLengths.add(FlSpot((i - 1).toDouble(), diff.toDouble()));
      }
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cycle Length History',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: cycleLengths.isEmpty
                ? const Center(
                    child: Text(
                      'Log 2+ cycles to see chart',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: true),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index >= 0 && index < cycles.length - 1) {
                                return Text(
                                  '${index + 1}',
                                  style: const TextStyle(fontSize: 10),
                                );
                              }
                              return const Text('');
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
                          spots: cycleLengths,
                          isCurved: true,
                          color: AppColors.primary,
                          barWidth: 3,
                          dotData: const FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            color: AppColors.primary.withValues(alpha: 0.1),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomFrequencyChart(List symptoms) {
    final Map<String, int> counts = {};
    for (final symptom in symptoms) {
      for (final s in symptom.symptoms) {
        counts[s] = (counts[s] ?? 0) + 1;
      }
    }
    
    final sortedSymptoms = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final topSymptoms = sortedSymptoms.take(5).toList();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top Symptoms',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: topSymptoms.isEmpty
                ? const Center(
                    child: Text(
                      'No symptoms logged yet',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: topSymptoms.isNotEmpty ? topSymptoms.first.value.toDouble() + 1 : 10,
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index >= 0 && index < topSymptoms.length) {
                                return Text(
                                  topSymptoms[index].key.substring(0, 3),
                                  style: const TextStyle(fontSize: 10),
                                );
                              }
                              return const Text('');
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
                      barGroups: topSymptoms.asMap().entries.map((entry) {
                        return BarChartGroupData(
                          x: entry.key,
                          barRods: [
                            BarChartRodData(
                              toY: entry.value.value.toDouble(),
                              color: const Color(0xFFE94DA0),
                              width: 30,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        );
                      }).toList(),
                      gridData: const FlGridData(show: true),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // Insights lists
  Widget _buildCycleInsightsList(List cycles) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cycle Insights',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _InsightItem(
            icon: Icons.info_outline,
            text: _getCycleInsight1(cycles),
            color: AppColors.primary,
          ),
          const Divider(),
          _InsightItem(
            icon: Icons.tips_and_updates,
            text: _getCycleInsight2(cycles),
            color: Colors.orange,
          ),
          const Divider(),
          _InsightItem(
            icon: Icons.health_and_safety,
            text: _getCycleInsight3(cycles),
            color: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomInsightsList(List symptoms) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Symptom Insights',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _InsightItem(
            icon: Icons.info_outline,
            text: _getSymptomInsight1(symptoms),
            color: const Color(0xFFE94DA0),
          ),
          const Divider(),
          _InsightItem(
            icon: Icons.trending_up,
            text: _getSymptomInsight2(symptoms),
            color: Colors.orange,
          ),
          const Divider(),
          _InsightItem(
            icon: Icons.tips_and_updates,
            text: _getSymptomInsight3(symptoms),
            color: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildHealthRecommendations() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Health Recommendations',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _InsightItem(
            icon: Icons.water_drop,
            text: _getHydrationRecommendation(),
            color: Colors.blue,
          ),
          const Divider(),
          _InsightItem(
            icon: Icons.bed,
            text: _getSleepRecommendation(),
            color: Colors.purple,
          ),
          const Divider(),
          _InsightItem(
            icon: Icons.fitness_center,
            text: _getExerciseRecommendation(),
            color: Colors.green,
          ),
          const Divider(),
          _InsightItem(
            icon: Icons.self_improvement,
            text: _getStressRecommendation(),
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  // Insight text generators
  String _getCycleInsight1(List cycles) {
    final avg = _calculateAverageCycleLength(cycles);
    if (avg == 0) return 'Log more cycles to see patterns';
    if (avg > 35) return 'Your cycles are longer than average ($avg days). This is common with PCOS.';
    return 'Your average cycle length is $avg days, which is within normal range.';
  }

  String _getCycleInsight2(List cycles) {
    final regularity = _calculateRegularity(cycles);
    if (regularity == 'Insufficient data') return 'Continue logging to track cycle regularity.';
    if (regularity == 'Irregular' || regularity == 'Somewhat Irregular') {
      return 'Your cycles show some irregularity. Consider tracking diet and stress factors.';
    }
    return 'Your cycles are $regularity. Keep up the good tracking!';
  }

  String _getCycleInsight3(List cycles) {
    if (cycles.length < 2) return 'Log 2+ cycles to get personalized predictions.';
    return 'Based on your pattern, your next period is predicted in approximately ${_calculateAverageCycleLength(cycles)} days.';
  }

  String _getSymptomInsight1(List symptoms) {
    if (symptoms.isEmpty) return 'Log symptoms to get personalized insights.';
    final common = _getMostCommonSymptom(symptoms);
    return 'Your most common symptom is "$common". Consider tracking when it occurs most often.';
  }

  String _getSymptomInsight2(List symptoms) {
    if (symptoms.length < 3) return 'Log more symptoms to identify patterns.';
    final severity = _getAverageSeverity(symptoms);
    return 'Your average symptom severity is $severity. ${severity == 'Severe' ? 'Consider discussing with your doctor.' : 'Keep monitoring for changes.'}';
  }

  String _getSymptomInsight3(List symptoms) {
    if (symptoms.isEmpty) return 'Track symptoms to see correlations.';
    return 'Regular symptom logging helps identify triggers and patterns. Keep it up!';
  }

  String _getHydrationRecommendation() {
    return 'Aim for 2-3 liters of water daily. Proper hydration helps with PCOS symptoms.';
  }

  String _getSleepRecommendation() {
    return 'Maintain a consistent sleep schedule of 7-9 hours for better hormone balance.';
  }

  String _getExerciseRecommendation() {
    return 'Aim for 150 minutes of moderate exercise weekly. Walking and swimming are great options.';
  }

  String _getStressRecommendation() {
    return 'Practice stress-reducing activities like meditation, yoga, or deep breathing daily.';
  }
}

// Supporting widgets
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
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
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _InsightItem({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF555555),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Extension for sqrt calculation
extension SqrtExtension on double {
  double sqrt() => math.sqrt(this);
}