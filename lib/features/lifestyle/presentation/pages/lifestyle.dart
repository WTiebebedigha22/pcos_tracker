// lib/features/lifestyle/presentation/pages/lifestyle_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/app_colors.dart';
import '../provider/lifestyle_provider.dart';
import 'water_tracker.dart';
import 'sleep_tracker.dart';
import 'weight_tracker.dart';
import 'mood_tracker.dart';

class LifestylePage extends StatefulWidget {
  const LifestylePage({super.key});

  @override
  State<LifestylePage> createState() => _LifestylePageState();
}

class _LifestylePageState extends State<LifestylePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  
  // Metrics data
  int _todayWaterIntake = 0;
  int _waterGoal = 2000;
  double _todaySleepHours = 0;
  double _currentWeight = 0;
  int _todayMood = 3;
  int _weeklyWorkouts = 0;
  int _streakDays = 0;
  
  // Weekly data
  List<Map<String, dynamic>> _weeklyWaterData = [];
  List<Map<String, dynamic>> _weeklySleepData = [];
  List<Map<String, dynamic>> _weightHistory = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadLifestyleData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadLifestyleData() async {
    setState(() => _isLoading = true);
    
    try {
      await Future.wait([
        _loadWaterIntake(),
        _loadSleepData(),
        _loadWeightData(),
        _loadMoodData(),
        _loadWeeklyWaterData(),
        _loadWeeklySleepData(),
        _loadWeightHistory(),
      ]);
    } catch (e) {
      debugPrint('Error loading lifestyle data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadWaterIntake() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    
    final today = DateTime.now().toIso8601String().split('T').first;
    
    final response = await Supabase.instance.client
        .from('water_intake')
        .select()
        .eq('user_id', user.id)
        .eq('date', today)
        .maybeSingle();
    
    if (response != null) {
      _todayWaterIntake = response['amount'] ?? 0;
      _waterGoal = response['goal'] ?? 2000;
    }
  }

  Future<void> _loadSleepData() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    
    final today = DateTime.now().toIso8601String().split('T').first;
    
    final response = await Supabase.instance.client
        .from('sleep_logs')
        .select()
        .eq('user_id', user.id)
        .eq('date', today)
        .maybeSingle();
    
    if (response != null) {
      _todaySleepHours = (response['hours'] ?? 0).toDouble();
    }
  }

  Future<void> _loadWeightData() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    
    final response = await Supabase.instance.client
        .from('weight_logs')
        .select()
        .eq('user_id', user.id)
        .order('date', ascending: false)
        .limit(1)
        .maybeSingle();
    
    if (response != null) {
      _currentWeight = (response['weight'] ?? 0).toDouble();
    }
  }

  Future<void> _loadMoodData() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    
    final today = DateTime.now().toIso8601String().split('T').first;
    
    final response = await Supabase.instance.client
        .from('mood_logs')
        .select()
        .eq('user_id', user.id)
        .eq('date', today)
        .maybeSingle();
    
    if (response != null) {
      _todayMood = response['mood'] ?? 3;
    }
  }

  Future<void> _loadWeeklyWaterData() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    
    final today = DateTime.now();
    final weekAgo = today.subtract(const Duration(days: 6));
    
    final response = await Supabase.instance.client
        .from('water_intake')
        .select()
        .eq('user_id', user.id)
        .gte('date', weekAgo.toIso8601String().split('T').first)
        .lte('date', today.toIso8601String().split('T').first);
    
    _weeklyWaterData = (response as List).map((item) => {
      'date': DateTime.parse(item['date']),
      'amount': item['amount'] ?? 0,
    }).toList();
  }

  Future<void> _loadWeeklySleepData() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    
    final today = DateTime.now();
    final weekAgo = today.subtract(const Duration(days: 6));
    
    final response = await Supabase.instance.client
        .from('sleep_logs')
        .select()
        .eq('user_id', user.id)
        .gte('date', weekAgo.toIso8601String().split('T').first)
        .lte('date', today.toIso8601String().split('T').first);
    
    _weeklySleepData = (response as List).map((item) => ({
      'date': DateTime.parse(item['date']),
      'hours': (item['hours'] ?? 0).toDouble(),
    })).toList();
  }

  Future<void> _loadWeightHistory() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    
    final response = await Supabase.instance.client
        .from('weight_logs')
        .select()
        .eq('user_id', user.id)
        .order('date', ascending: false)
        .limit(30);
    
    _weightHistory = (response as List).map((item) => ({
      'date': DateTime.parse(item['date']),
      'weight': item['weight'] ?? 0.0,
    })).toList();
  }

  String _getMoodEmoji(int mood) {
    switch (mood) {
      case 1: return '😞';
      case 2: return '😕';
      case 3: return '😐';
      case 4: return '🙂';
      case 5: return '😊';
      default: return '😐';
    }
  }

  String _getMoodLabel(int mood) {
    switch (mood) {
      case 1: return 'Terrible';
      case 2: return 'Bad';
      case 3: return 'Okay';
      case 4: return 'Good';
      case 5: return 'Great';
      default: return 'Okay';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const Text(
          'Lifestyle Tracker',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
              children: [
                // Metrics Summary Cards
                _buildMetricsSummary(),
                const SizedBox(height: 16),
                
                // Tab Bar
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: AppColors.primary,
                    indicatorSize: TabBarIndicatorSize.label,
                    tabs: const [
                      Tab(text: 'Water', icon: Icon(Icons.water_drop)),
                      Tab(text: 'Sleep', icon: Icon(Icons.bed)),
                      Tab(text: 'Weight', icon: Icon(Icons.monitor_weight)),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _WaterTab(weeklyData: _weeklyWaterData, onRefresh: _loadLifestyleData),
                      _SleepTab(weeklyData: _weeklySleepData, onRefresh: _loadLifestyleData),
                      _WeightTab(weightHistory: _weightHistory, currentWeight: _currentWeight, onRefresh: _loadLifestyleData),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildMetricsSummary() {
    final waterPercentage = (_todayWaterIntake / _waterGoal) * 100;
    final sleepQuality = _todaySleepHours >= 8 ? 'Excellent' : _todaySleepHours >= 7 ? 'Good' : _todaySleepHours > 0 ? 'Needs Improvement' : 'Not logged';
    
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary.withOpacity(0.9), AppColors.blushPink.withOpacity(0.9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  icon: Icons.water_drop,
                  value: '${(_todayWaterIntake / 1000).toStringAsFixed(1)}L',
                  label: 'Water',
                  subtitle: '${waterPercentage.toStringAsFixed(0)}% of goal',
                  color: Colors.blue,
                ),
              ),
              Container(width: 1, height: 50, color: Colors.white24),
              Expanded(
                child: _MetricCard(
                  icon: Icons.bed,
                  value: _todaySleepHours > 0 ? '${_todaySleepHours.toStringAsFixed(1)}h' : '--',
                  label: 'Sleep',
                  subtitle: sleepQuality,
                  color: Colors.purple,
                ),
              ),
              Container(width: 1, height: 50, color: Colors.white24),
              Expanded(
                child: _MetricCard(
                  icon: Icons.monitor_weight,
                  value: _currentWeight > 0 ? '${_currentWeight.toStringAsFixed(1)} kg' : '--',
                  label: 'Weight',
                  subtitle: 'Current',
                  color: Colors.green,
                ),
              ),
              Container(width: 1, height: 50, color: Colors.white24),
              Expanded(
                child: _MetricCard(
                  icon: Icons.mood,
                  value: _getMoodEmoji(_todayMood),
                  label: 'Mood',
                  subtitle: _getMoodLabel(_todayMood),
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  icon: Icons.fitness_center,
                  value: '${_weeklyWorkouts}',
                  label: 'Workouts',
                  subtitle: 'This week',
                  color: Colors.red,
                ),
              ),
              Container(width: 1, height: 50, color: Colors.white24),
              Expanded(
                child: _MetricCard(
                  icon: Icons.local_fire_department,
                  value: '$_streakDays',
                  label: 'Day Streak',
                  subtitle: 'Tracking streak',
                  color: Colors.amber,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final String subtitle;
  final Color color;

  const _MetricCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
        Text(
          subtitle,
          style: const TextStyle(color: Colors.white54, fontSize: 9),
        ),
      ],
    );
  }
}

class _WaterTab extends StatelessWidget {
  final List<Map<String, dynamic>> weeklyData;
  final VoidCallback onRefresh;

  const _WaterTab({required this.weeklyData, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Quick action button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const WaterTrackerPage()),
                  ).then((_) => onRefresh());
                },
                icon: const Icon(Icons.add),
                label: const Text('Log Water Intake'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Weekly chart
            Container(
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
                    'Weekly Water Intake',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: 2500,
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                                if (value.toInt() >= 0 && value.toInt() < days.length) {
                                  return Text(days[value.toInt()], style: const TextStyle(fontSize: 10));
                                }
                                return const Text('');
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                return Text('${value.toInt()}ml', style: const TextStyle(fontSize: 9));
                              },
                            ),
                          ),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        gridData: const FlGridData(show: true),
                        borderData: FlBorderData(show: false),
                        barGroups: List.generate(7, (index) {
                          final dayData = weeklyData.isNotEmpty && index < weeklyData.length 
                              ? weeklyData[index]['amount'] ?? 0 
                              : 0;
                          return BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: dayData.toDouble(),
                                color: Colors.blue,
                                width: 20,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SleepTab extends StatelessWidget {
  final List<Map<String, dynamic>> weeklyData;
  final VoidCallback onRefresh;

  const _SleepTab({required this.weeklyData, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SleepTrackerPage()),
                  ).then((_) => onRefresh());
                },
                icon: const Icon(Icons.add),
                label: const Text('Log Sleep'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            Container(
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
                    'Weekly Sleep Hours',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: true),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                                if (value.toInt() >= 0 && value.toInt() < days.length) {
                                  return Text(days[value.toInt()], style: const TextStyle(fontSize: 10));
                                }
                                return const Text('');
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                return Text('${value.toInt()}h', style: const TextStyle(fontSize: 10));
                              },
                            ),
                          ),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: List.generate(7, (index) {
                              final dayData = weeklyData.isNotEmpty && index < weeklyData.length 
                                  ? weeklyData[index]['hours'] ?? 0 
                                  : 0;
                              return FlSpot(index.toDouble(), dayData);
                            }),
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
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F7FC),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.tips_and_updates, color: AppColors.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Aim for 7-9 hours of sleep per night for optimal hormone regulation',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeightTab extends StatelessWidget {
  final List<Map<String, dynamic>> weightHistory;
  final double currentWeight;
  final VoidCallback onRefresh;

  const _WeightTab({
    required this.weightHistory,
    required this.currentWeight,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final weightChange = weightHistory.length >= 2 
        ? weightHistory[0]['weight'] - weightHistory[1]['weight']
        : 0.0;
    
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const WeightTrackerPage()),
                  ).then((_) => onRefresh());
                },
                icon: const Icon(Icons.add),
                label: const Text('Log Weight'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Current weight card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.withOpacity(0.1), Colors.teal.withOpacity(0.1)],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text('Current', style: TextStyle(color: Colors.grey)),
                      Text(
                        currentWeight > 0 ? '${currentWeight.toStringAsFixed(1)} kg' : '--',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Container(width: 1, height: 40, color: Colors.grey.shade300),
                  Column(
                    children: [
                      const Text('Change', style: TextStyle(color: Colors.grey)),
                      Row(
                        children: [
                          Icon(
                            weightChange >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                            color: weightChange >= 0 ? Colors.red : Colors.green,
                            size: 16,
                          ),
                          Text(
                            weightChange != 0 
                                ? '${weightChange.abs().toStringAsFixed(1)} kg'
                                : '--',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: weightChange >= 0 ? Colors.red : Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Weight history chart
            if (weightHistory.isNotEmpty)
              Container(
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
                      'Weight History',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: LineChart(
                        LineChartData(
                          gridData: const FlGridData(show: true),
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  final index = value.toInt();
                                  if (index >= 0 && index < weightHistory.length) {
                                    return Text(
                                      DateFormat('MM/dd').format(weightHistory[index]['date']),
                                      style: const TextStyle(fontSize: 9),
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
                                  return Text('${value.toInt()}kg', style: const TextStyle(fontSize: 9));
                                },
                              ),
                            ),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: weightHistory.asMap().entries.map((entry) {
                                return FlSpot(entry.key.toDouble(), entry.value['weight']);
                              }).toList(),
                              isCurved: true,
                              color: Colors.green,
                              barWidth: 3,
                              dotData: const FlDotData(show: true),
                              belowBarData: BarAreaData(
                                show: true,
                                color: Colors.green.withOpacity(0.1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: 16),
            
            // BMI Card
            if (currentWeight > 0)
              Container(
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
                      'BMI Calculator',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    _buildBMICalculator(),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBMICalculator() {
    final heightCm = 165.0; // This should come from user profile
    final heightM = heightCm / 100;
    final bmi = currentWeight > 0 ? currentWeight / (heightM * heightM) : 0;
    String category;
    Color categoryColor;
    
    if (bmi < 18.5) {
      category = 'Underweight';
      categoryColor = Colors.orange;
    } else if (bmi < 25) {
      category = 'Normal weight';
      categoryColor = Colors.green;
    } else if (bmi < 30) {
      category = 'Overweight';
      categoryColor = Colors.orange;
    } else {
      category = 'Obese';
      categoryColor = Colors.red;
    }
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Your BMI:', style: TextStyle(fontWeight: FontWeight.w600)),
            Text(bmi.toStringAsFixed(1), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: categoryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: categoryColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'You are in the "$category" range. ${_getBMIRecommendation(category)}',
                  style: TextStyle(fontSize: 12, color: categoryColor),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getBMIRecommendation(String category) {
    switch (category) {
      case 'Underweight':
        return 'Consider consulting a nutritionist for healthy weight gain.';
      case 'Normal weight':
        return 'Great! Maintain a balanced diet and regular exercise.';
      case 'Overweight':
        return 'Small lifestyle changes can help achieve a healthy weight.';
      case 'Obese':
        return 'Consider consulting a healthcare provider for guidance.';
      default:
        return 'Track your weight regularly to monitor progress.';
    }
  }
}