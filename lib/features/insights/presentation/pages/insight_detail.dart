// lib/features/insights/presentation/pages/insights_detail_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/insights_calculator.dart';
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
  bool _hasError = false;
  String _errorMessage = '';
  String _timeRange = '3 months';
  
  static const List<String> _timeRanges = ['1 month', '3 months', '6 months', '1 year'];
  
  InsightCalculator? _calculator;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _calculator = null;
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      await Future.wait([
        context.read<InsightProvider>().fetchInsights(),
        context.read<CycleProvider>().fetchCycles(),
        context.read<SymptomProvider>().fetchAllSymptoms(),
      ]);

      if (!mounted) return;

      final cycleProvider = context.read<CycleProvider>();
      final symptomProvider = context.read<SymptomProvider>();
      
      _calculator = InsightCalculator(
        cycles: cycleProvider.cycles,
        symptoms: symptomProvider.allSymptoms,
      );

      setState(() => _isLoading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Failed to load insights. Please try again.';
      });
    }
  }

  Future<void> _refreshData() async {
    await _loadData();
  }

  String get _insightTitle => switch (widget.insightType) {
    'cycle' => 'Cycle Insights',
    'symptom' => 'Symptom Insights',
    'health' => 'Health Insights',
    _ => 'Insights',
  };

  IconData get _insightIcon => switch (widget.insightType) {
    'cycle' => Icons.calendar_month,
    'symptom' => Icons.sick,
    'health' => Icons.favorite,
    _ => Icons.insights,
  };

  Color get _insightColor => switch (widget.insightType) {
    'cycle' => AppColors.primary,
    'symptom' => const Color(0xFFE94DA0),
    'health' => Colors.green,
    _ => Colors.blue,
  };

  String get _summaryText => switch (widget.insightType) {
    'cycle' => 'Track your cycle patterns and predictions',
    'symptom' => 'Monitor symptom frequency and patterns',
    'health' => 'Track your overall health metrics',
    _ => 'Detailed insights for your health',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          _insightTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: _onTimeRangeSelected,
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
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_hasError) {
      return _buildErrorState();
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSummaryCard(),
            const SizedBox(height: 16),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _buildDetailContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            _errorMessage,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A2E),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _onTimeRangeSelected(String value) {
    setState(() => _timeRange = value);
    _loadData();
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _insightColor.withValues(alpha: 0.9),
            _insightColor.withValues(alpha: 0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _insightColor.withValues(alpha: 0.2),
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
            child: Icon(_insightIcon, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _insightTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _summaryText,
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
            child: const Row(
              children: [
                Icon(Icons.check_circle, size: 12, color: Colors.white70),
                SizedBox(width: 4),
                Text(
                  'Updated',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailContent() {
    if (_calculator == null) {
      return _buildEmptyState();
    }

    return switch (widget.insightType) {
      'cycle' => _buildCycleInsights(),
      'symptom' => _buildSymptomInsights(),
      'health' => _buildHealthInsights(),
      _ => _buildGeneralInsights(),
    };
  }

  Widget _buildCycleInsights() {
    if (!_calculator!.hasCycleData) {
      return _buildEmptyState(
        icon: Icons.calendar_month,
        title: 'No Cycle Data',
        message: 'Start tracking your cycles to see insights',
      );
    }

    final stats = _calculator!.getCycleStatistics();
    
    return Column(
      key: const ValueKey('cycle_insights'),
      children: [
        _StatCard(
          title: 'Average Cycle Length',
          value: '${stats.averageCycleLength} days',
          icon: Icons.timeline,
          color: AppColors.primary,
        ),
        const SizedBox(height: 12),
        _StatCard(
          title: 'Average Period Length',
          value: '${stats.averagePeriodLength} days',
          icon: Icons.water_drop,
          color: const Color(0xFFE94DA0),
        ),
        const SizedBox(height: 12),
        _StatCard(
          title: 'Cycle Regularity',
          value: stats.regularity,
          icon: Icons.show_chart,
          color: _getRegularityColor(stats.regularity),
        ),
        const SizedBox(height: 16),
        _buildCycleChart(),
        const SizedBox(height: 16),
        _buildCycleInsightsList(),
      ],
    );
  }

  Widget _buildSymptomInsights() {
    if (!_calculator!.hasSymptomData) {
      return _buildEmptyState(
        icon: Icons.sick,
        title: 'No Symptom Data',
        message: 'Log your symptoms to see patterns and insights',
      );
    }

    final stats = _calculator!.getSymptomStatistics();
    
    return Column(
      key: const ValueKey('symptom_insights'),
      children: [
        _StatCard(
          title: 'Total Symptoms Logged',
          value: '${stats.totalSymptoms}',
          icon: Icons.sick,
          color: const Color(0xFFE94DA0),
        ),
        const SizedBox(height: 12),
        _StatCard(
          title: 'Most Common Symptom',
          value: stats.mostCommonSymptom,
          icon: Icons.favorite,
          color: Colors.orange,
        ),
        const SizedBox(height: 12),
        _StatCard(
          title: 'Average Severity',
          value: stats.averageSeverity,
          icon: Icons.signal_cellular_alt,
          color: _getSeverityColor(stats.averageSeverity),
        ),
        const SizedBox(height: 16),
        _buildSymptomFrequencyChart(),
        const SizedBox(height: 16),
        _buildSymptomInsightsList(),
      ],
    );
  }

  Widget _buildHealthInsights() {
    return Consumer<InsightProvider>(
      builder: (context, provider, _) {
        return Column(
          key: const ValueKey('health_insights'),
          children: [
            _StatCard(
              title: 'Health Score',
              value: '${provider.healthScore}/100',
              icon: Icons.health_and_safety,
              color: _getHealthScoreColor(provider.healthScore),
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
    return _buildEmptyState(
      icon: Icons.insights,
      title: 'No Insights Available',
      message: 'This insight type is not yet supported',
    );
  }

  Widget _buildEmptyState({
    IconData icon = Icons.insights_outlined,
    String title = 'No data available yet',
    String message = 'Start tracking your health to see insights here',
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCycleChart() {
    final cycleLengths = _calculator!.getCycleLengthHistory();
    
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
                              if (index >= 0 && index < cycleLengths.length) {
                                return Text(
                                  'Cycle ${index + 1}',
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
                              return Text(
                                '${value.toInt()}d',
                                style: const TextStyle(fontSize: 10),
                              );
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
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

  Widget _buildSymptomFrequencyChart() {
    final topSymptoms = _calculator!.getTopSymptoms(limit: 5);
    
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
                      maxY: topSymptoms.first.count.toDouble() + 1,
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index >= 0 && index < topSymptoms.length) {
                                final symptomName = topSymptoms[index].name;
                                return Text(
                                  symptomName.length >= 4 
                                      ? symptomName.substring(0, 4) 
                                      : symptomName,
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
                              return Text(
                                value.toInt().toString(),
                                style: const TextStyle(fontSize: 10),
                              );
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: topSymptoms.asMap().entries.map((entry) {
                        return BarChartGroupData(
                          x: entry.key,
                          barRods: [
                            BarChartRodData(
                              toY: entry.value.count.toDouble(),
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

  Widget _buildCycleInsightsList() {
    final insights = _calculator!.getCycleInsights();
    
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
          ...insights.asMap().entries.map((entry) {
            final index = entry.key;
            final insight = entry.value;
            return Column(
              children: [
                _InsightItem(
                  icon: _getInsightIcon(index),
                  text: insight,
                  color: _getInsightColor(index),
                ),
                if (index < insights.length - 1) const Divider(),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSymptomInsightsList() {
    final insights = _calculator!.getSymptomInsights();
    
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
          ...insights.asMap().entries.map((entry) {
            final index = entry.key;
            final insight = entry.value;
            return Column(
              children: [
                _InsightItem(
                  icon: _getInsightIcon(index),
                  text: insight,
                  color: _getInsightColor(index),
                ),
                if (index < insights.length - 1) const Divider(),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildHealthRecommendations() {
    final recommendations = [
      (
        icon: Icons.water_drop,
        text: 'Aim for 2-3 liters of water daily. Proper hydration helps with PCOS symptoms.',
        color: Colors.blue,
      ),
      (
        icon: Icons.bed,
        text: 'Maintain a consistent sleep schedule of 7-9 hours for better hormone balance.',
        color: Colors.purple,
      ),
      (
        icon: Icons.fitness_center,
        text: 'Aim for 150 minutes of moderate exercise weekly. Walking and swimming are great options.',
        color: Colors.green,
      ),
      (
        icon: Icons.self_improvement,
        text: 'Practice stress-reducing activities like meditation, yoga, or deep breathing daily.',
        color: Colors.orange,
      ),
    ];
    
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
          ...recommendations.asMap().entries.map((entry) {
            final index = entry.key;
            final recommendation = entry.value;
            return Column(
              children: [
                _InsightItem(
                  icon: recommendation.icon,
                  text: recommendation.text,
                  color: recommendation.color,
                ),
                if (index < recommendations.length - 1) const Divider(),
              ],
            );
          }),
        ],
      ),
    );
  }

  Color _getRegularityColor(String regularity) {
    return switch (regularity) {
      'Very Regular' => Colors.green,
      'Regular' => Colors.lightGreen,
      'Somewhat Irregular' => Colors.orange,
      'Irregular' => Colors.red,
      _ => Colors.grey,
    };
  }

  Color _getSeverityColor(String severity) {
    return switch (severity) {
      'Mild' => Colors.green,
      'Moderate' => Colors.orange,
      'Severe' => Colors.red,
      _ => Colors.grey,
    };
  }

  Color _getHealthScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  IconData _getInsightIcon(int index) {
    return switch (index) {
      0 => Icons.info_outline,
      1 => Icons.trending_up,
      2 => Icons.tips_and_updates,
      _ => Icons.health_and_safety,
    };
  }

  Color _getInsightColor(int index) {
    return switch (index) {
      0 => _insightColor,
      1 => Colors.orange,
      2 => Colors.green,
      _ => Colors.blue,
    };
  }
}

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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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
                    fontWeight: FontWeight.w500,
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
                  overflow: TextOverflow.ellipsis,
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
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
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