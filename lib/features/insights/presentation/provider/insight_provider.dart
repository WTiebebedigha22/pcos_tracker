// lib/features/insights/presentation/provider/insight_provider.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/app_colors.dart';

class InsightProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  int _averageCycleLength = 0;
  int get averageCycleLength => _averageCycleLength;
  
  int _averagePeriodLength = 0;
  int get averagePeriodLength => _averagePeriodLength;
  
  String _lastPeriodDate = '';
  String get lastPeriodDate => _lastPeriodDate;
  
  String _nextPredictedPeriod = '';
  String get nextPredictedPeriod => _nextPredictedPeriod;
  
  double _cycleRegularityScore = 0;
  double get cycleRegularityScore => _cycleRegularityScore;
  
  int _healthScore = 0;
  int get healthScore => _healthScore;
  
  int _averageWaterIntake = 0;
  int get averageWaterIntake => _averageWaterIntake;
  
  double _averageSleepHours = 0;
  double get averageSleepHours => _averageSleepHours;
  
  String _averageMoodRating = '';
  String get averageMoodRating => _averageMoodRating;
  
  List<Map<String, dynamic>> _topSymptoms = [];
  List<Map<String, dynamic>> get topSymptoms => _topSymptoms;

  Future<void> fetchInsights() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await Future.wait([
        _fetchCycleInsights(),
        _fetchSymptomInsights(),
        _fetchHealthInsights(),
      ]);
    } catch (e) {
      debugPrint('Error fetching insights: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchCycleInsights() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;
    
    final response = await _supabase
        .from('cycles')
        .select()
        .eq('user_id', user.id)
        .order('start_date', ascending: true);
    
    final cycles = response as List;
    
    if (cycles.isNotEmpty) {
      // Calculate average cycle length
      int totalCycleDays = 0;
      int cycleCount = 0;
      for (int i = 1; i < cycles.length; i++) {
        final prevStart = DateTime.parse(cycles[i - 1]['start_date']);
        final currStart = DateTime.parse(cycles[i]['start_date']);
        final daysDiff = currStart.difference(prevStart).inDays;
        if (daysDiff > 0) {
          totalCycleDays += daysDiff;
          cycleCount++;
        }
      }
      _averageCycleLength = cycleCount > 0 ? (totalCycleDays / cycleCount).round() : 32;
      
      // Calculate average period length
      int totalPeriodDays = 0;
      int periodCount = 0;
      for (final cycle in cycles) {
        if (cycle['end_date'] != null) {
          final start = DateTime.parse(cycle['start_date']);
          final end = DateTime.parse(cycle['end_date']);
          final days = end.difference(start).inDays + 1;
          totalPeriodDays += days;
          periodCount++;
        }
      }
      _averagePeriodLength = periodCount > 0 ? (totalPeriodDays / periodCount).round() : 5;
      
      // Last period date
      final lastCycle = cycles.first;
      _lastPeriodDate = _formatDate(DateTime.parse(lastCycle['start_date']));
      
      // Next predicted period
      final lastStart = DateTime.parse(lastCycle['start_date']);
      final nextPredicted = lastStart.add(Duration(days: _averageCycleLength));
      _nextPredictedPeriod = _formatDate(nextPredicted);
      
      // Regularity score
      _cycleRegularityScore = _calculateRegularityScore(cycles);
    } else {
      _averageCycleLength = 0;
      _averagePeriodLength = 0;
      _lastPeriodDate = 'No data';
      _nextPredictedPeriod = 'Log 2+ cycles';
      _cycleRegularityScore = 0;
    }
  }

  Future<void> _fetchSymptomInsights() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;
    
    final response = await _supabase
        .from('symptoms')
        .select()
        .eq('user_id', user.id);
    
    final symptoms = response as List;
    
    // Count symptom frequencies
    final Map<String, int> symptomCount = {};
    final Map<String, Color> symptomColors = {
      'Fatigue': Colors.blue,
      'Acne': Colors.red,
      'Mood Swings': Colors.purple,
      'Bloating': Colors.orange,
      'Headache': Colors.grey,
      'Cramps': Colors.red,
      'Hair Loss': Colors.brown,
      'Anxiety': Colors.indigo,
    };
    
    for (final symptom in symptoms) {
      final symptomsList = List<String>.from(symptom['symptoms'] ?? []);
      for (final s in symptomsList) {
        symptomCount[s] = (symptomCount[s] ?? 0) + 1;
      }
    }
    
    _topSymptoms = symptomCount.entries
        .map((e) => {
          'name': e.key,
          'count': e.value,
          'color': symptomColors[e.key] ?? Colors.grey,
          'shortName': e.key.length > 8 ? '${e.key.substring(0, 6)}...' : e.key,
        })
        .toList()
      ..sort((a, b) => (b['count'] as int).compareTo(a['count'] as int))
      ..take(5).toList();
  }

  Future<void> _fetchHealthInsights() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;
    
    // Get water intake
    final waterResponse = await _supabase
        .from('water_intake')
        .select()
        .eq('user_id', user.id)
        .limit(30);
    
    if (waterResponse.isNotEmpty) {
      int total = 0;
      for (final w in waterResponse) {
        total += (w['amount'] ?? 0) as int;
      }
      _averageWaterIntake = (total / waterResponse.length).round();
    }
    
    // Get sleep logs
    final sleepResponse = await _supabase
        .from('sleep_logs')
        .select()
        .eq('user_id', user.id)
        .limit(30);
    
    if (sleepResponse.isNotEmpty) {
      double total = 0;
      for (final s in sleepResponse) {
        total += (s['hours'] ?? 0).toDouble();
      }
      _averageSleepHours = total / sleepResponse.length;
    }
    
    // Calculate health score
    _healthScore = _calculateHealthScore();
  }

  double _calculateRegularityScore(List cycles) {
    if (cycles.length < 3) return 0.0;
    
    List<int> cycleLengths = [];
    for (int i = 1; i < cycles.length; i++) {
      final prevStart = DateTime.parse(cycles[i - 1]['start_date']);
      final currStart = DateTime.parse(cycles[i]['start_date']);
      cycleLengths.add(currStart.difference(prevStart).inDays);
    }
    
    if (cycleLengths.isEmpty) return 0.0;
    
    final avg = cycleLengths.reduce((a, b) => a + b) / cycleLengths.length;
    final variance = cycleLengths.map((l) => (l - avg) * (l - avg)).reduce((a, b) => a + b) / cycleLengths.length;
    final stdDev = variance.sqrt();
    
    // Lower standard deviation = more regular
    if (stdDev <= 3) return 0.9;
    if (stdDev <= 5) return 0.7;
    if (stdDev <= 7) return 0.5;
    return 0.3;
  }

  int _calculateHealthScore() {
    int score = 0;
    
    // Cycle regularity (up to 30 points)
    score += (_cycleRegularityScore * 30).toInt();
    
    // Water intake (up to 20 points)
    if (_averageWaterIntake >= 2000) score += 20;
    else if (_averageWaterIntake >= 1500) score += 15;
    else if (_averageWaterIntake >= 1000) score += 10;
    
    // Sleep (up to 25 points)
    if (_averageSleepHours >= 8) score += 25;
    else if (_averageSleepHours >= 7) score += 20;
    else if (_averageSleepHours >= 6) score += 15;
    else if (_averageSleepHours >= 5) score += 10;
    
    // Tracking consistency (up to 25 points)
    // Add logic based on how consistently user logs data
    
    return score.clamp(0, 100);
  }

  String getFatiguePattern() {
    return 'Fatigue is commonly reported around your luteal phase. Consider adjusting your schedule during this time.';
  }
  
  String getMoodPattern() {
    return 'Mood fluctuations often correlate with hormonal changes. Tracking can help you anticipate and manage these shifts.';
  }
  
  String getSleepImpact() {
    if (_averageSleepHours < 7) {
      return 'You are averaging ${_averageSleepHours.toStringAsFixed(1)} hours of sleep. Aim for 7-9 hours for optimal hormone regulation.';
    }
    return 'Your sleep duration is good! Maintain consistent sleep schedules for better hormone balance.';
  }
  
  String getHydrationRecommendation() {
    if (_averageWaterIntake < 2000) {
      return 'Increase water intake to 2L/day. Proper hydration helps with PCOS symptoms like bloating and fatigue.';
    }
    return 'Great job staying hydrated! Continue drinking 2-3L of water daily.';
  }
  
  String getSleepRecommendation() {
    if (_averageSleepHours < 7) {
      return 'Try to get 7-9 hours of sleep. Quality sleep helps regulate cortisol and insulin levels.';
    }
    return 'Maintain a consistent sleep schedule for better hormone balance.';
  }
  
  String getStressRecommendation() {
    return 'Incorporate stress-reducing activities like meditation, deep breathing, or gentle yoga.';
  }
  
  String getExerciseRecommendation() {
    return 'Aim for 150 minutes of moderate exercise weekly. Walking, swimming, and strength training are great options for PCOS.';
  }
  
  List<String> getDoctorDiscussionPoints() {
    final points = <String>[];
    points.add('Discuss your cycle irregularity patterns');
    if (_averageCycleLength > 35) points.add('Your longer cycle length (${_averageCycleLength} days)');
    if (_topSymptoms.isNotEmpty) points.add('Frequent symptoms: ${_topSymptoms.take(3).map((s) => s['name']).join(', ')}');
    points.add('Review your medication and supplement routine');
    points.add('Discuss lifestyle changes that could help manage symptoms');
    return points;
  }

  List<FlSpot> getCycleLengthSpots() {
    // Return mock data for chart - replace with actual data
    return [
      const FlSpot(0, 32),
      const FlSpot(1, 34),
      const FlSpot(2, 31),
      const FlSpot(3, 35),
      const FlSpot(4, 33),
    ];
  }

  String getMonthLabel(int index) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[index % 12];
  }

  List<BarChartGroupData> getSymptomFrequencyBars() {
    final bars = <BarChartGroupData>[];
    for (int i = 0; i < _topSymptoms.length && i < 5; i++) {
      final symptom = _topSymptoms[i];
      bars.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: (symptom['count'] as int).toDouble(),
              color: AppColors.primary,
              width: 20,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    }
    return bars;
  }

  int getMaxSymptomCount() {
    if (_topSymptoms.isEmpty) return 10;
    return _topSymptoms.map((s) => s['count'] as int).reduce((a, b) => a > b ? a : b) + 2;
  }

  Map<String, dynamic> getSymptomAtIndex(int index) {
    if (index < _topSymptoms.length) {
      return _topSymptoms[index];
    }
    return {'shortName': '', 'count': 0};
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  void clearError() {
    notifyListeners();
  }
}

extension on num {
  double sqrt() => (this as double).sqrt();
}