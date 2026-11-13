// lib/core/utils/insight_calculator.dart
import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import '../../features/cycle_tracking/data/models/cycle_model.dart';
import '../../features/symptoms/data/models/symptom_model.dart';

class InsightCalculator {
  final List<CycleModel> cycles;
  final List<SymptomModel> symptoms;
  
  InsightCalculator({
    required this.cycles,
    required this.symptoms,
  });
  
  bool get hasCycleData => cycles.isNotEmpty;
  bool get hasSymptomData => symptoms.isNotEmpty;

  CycleStatistics getCycleStatistics() {
    return CycleStatistics(
      averageCycleLength: _calculateAverageCycleLength(),
      averagePeriodLength: _calculateAveragePeriodLength(),
      regularity: _calculateRegularity(),
    );
  }

  SymptomStatistics getSymptomStatistics() {
    return SymptomStatistics(
      totalSymptoms: symptoms.length,
      mostCommonSymptom: _getMostCommonSymptom(),
      averageSeverity: _getAverageSeverity(),
    );
  }

  List<FlSpot> getCycleLengthHistory() {
    final cycleLengths = <FlSpot>[];
    for (int i = 1; i < cycles.length && i < 12; i++) {
      final prevStart = cycles[i - 1].startDate;
      final currStart = cycles[i].startDate;
      final diff = currStart.difference(prevStart).inDays;
      if (diff > 20 && diff < 60) {
        cycleLengths.add(FlSpot((i - 1).toDouble(), diff.toDouble()));
      }
    }
    return cycleLengths;
  }

  List<SymptomCount> getTopSymptoms({int limit = 5}) {
    final Map<String, int> counts = {};
    for (final symptomEntry in symptoms) {
      for (final s in symptomEntry.symptoms) {
        counts[s] = (counts[s] ?? 0) + 1;
      }
    }
    
    final sortedSymptoms = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedSymptoms
        .take(limit)
        .map((entry) => SymptomCount(name: entry.key, count: entry.value))
        .toList();
  }

  List<String> getCycleInsights() {
    final stats = getCycleStatistics();
    final insights = <String>[];
    
    if (stats.averageCycleLength == 0) {
      insights.add('Log more cycles to see patterns');
    } else if (stats.averageCycleLength > 35) {
      insights.add('Your cycles are longer than average (${stats.averageCycleLength} days). This is common with PCOS.');
    } else {
      insights.add('Your average cycle length is ${stats.averageCycleLength} days, which is within normal range.');
    }
    
    if (stats.regularity == 'Insufficient data') {
      insights.add('Continue logging to track cycle regularity.');
    } else if (stats.regularity == 'Irregular' || stats.regularity == 'Somewhat Irregular') {
      insights.add('Your cycles show some irregularity. Consider tracking diet and stress factors.');
    } else {
      insights.add('Your cycles are ${stats.regularity}. Keep up the good tracking!');
    }
    
    if (cycles.length < 2) {
      insights.add('Log 2+ cycles to get personalized predictions.');
    } else {
      insights.add('Based on your pattern, your next period is predicted in approximately ${stats.averageCycleLength} days.');
    }
    
    return insights;
  }

  List<String> getSymptomInsights() {
    final stats = getSymptomStatistics();
    final insights = <String>[];
    
    if (symptoms.isEmpty) {
      insights.add('Log symptoms to get personalized insights.');
    } else {
      insights.add('Your most common symptom is "${stats.mostCommonSymptom}". Consider tracking when it occurs most often.');
    }
    
    if (symptoms.length < 3) {
      insights.add('Log more symptoms to identify patterns.');
    } else {
      final advice = stats.averageSeverity == 'Severe' 
          ? 'Consider discussing with your doctor.' 
          : 'Keep monitoring for changes.';
      insights.add('Your average symptom severity is ${stats.averageSeverity}. $advice');
    }
    
    if (symptoms.isEmpty) {
      insights.add('Track symptoms to see correlations.');
    } else {
      insights.add('Regular symptom logging helps identify triggers and patterns. Keep it up!');
    }
    
    return insights;
  }

  int _calculateAverageCycleLength() {
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
    return (totalDays / count).round();
  }

  int _calculateAveragePeriodLength() {
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
    return (totalDays / count).round();
  }

  String _calculateRegularity() {
    if (cycles.length < 3) return 'Insufficient data';
    
    List<int> lengths = [];
    for (int i = 1; i < cycles.length; i++) {
      final diff = cycles[i].startDate.difference(cycles[i - 1].startDate).inDays;
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

  String _getMostCommonSymptom() {
    if (symptoms.isEmpty) return 'None';
    
    final Map<String, int> counts = {};
    for (final symptomEntry in symptoms) {
      for (final s in symptomEntry.symptoms) {
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

  String _getAverageSeverity() {
    if (symptoms.isEmpty) return 'N/A';
    
    // Use the severity getter from SymptomModel
    final severityCounts = <String, int>{};
    for (final symptomEntry in symptoms) {
      final severity = symptomEntry.severity;
      severityCounts[severity] = (severityCounts[severity] ?? 0) + 1;
    }
    
    if (severityCounts.isEmpty) return 'None';
    
    // Find the most common severity
    String mostCommonSeverity = '';
    int highestCount = 0;
    for (final entry in severityCounts.entries) {
      if (entry.value > highestCount) {
        highestCount = entry.value;
        mostCommonSeverity = entry.key;
      }
    }
    
    return mostCommonSeverity;
  }
}

class CycleStatistics {
  final int averageCycleLength;
  final int averagePeriodLength;
  final String regularity;

  const CycleStatistics({
    required this.averageCycleLength,
    required this.averagePeriodLength,
    required this.regularity,
  });
}

class SymptomStatistics {
  final int totalSymptoms;
  final String mostCommonSymptom;
  final String averageSeverity;

  const SymptomStatistics({
    required this.totalSymptoms,
    required this.mostCommonSymptom,
    required this.averageSeverity,
  });
}

class SymptomCount {
  final String name;
  final int count;

  const SymptomCount({
    required this.name,
    required this.count,
  });
}