// lib/features/dashboard/presentation/providers/dashboard_provider.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  User? _currentUser;
  User? get currentUser => _currentUser;
  
  // Data
  int _currentCycleDay = 1;
  int get currentCycleDay => _currentCycleDay;
  
  String _currentPhase = 'Follicular';
  String get currentPhase => _currentPhase;
  
  int _nextPeriodDays = 0;
  int get nextPeriodDays => _nextPeriodDays;
  
  int _waterIntake = 0;
  int get waterIntake => _waterIntake;
  
  int _waterGoal = 2000; // ml
  int get waterGoal => _waterGoal;
  
  double _sleepHours = 0;
  double get sleepHours => _sleepHours;
  
  double _weight = 0;
  double get weight => _weight;
  
  String _mood = 'Good';
  String get mood => _mood;
  
  bool _isLoading = true;
  bool get isLoading => _isLoading;
  
  DashboardProvider() {
    _initialize();
  }
  
  Future<void> _initialize() async {
    _currentUser = _supabase.auth.currentUser;
    if (_currentUser != null) {
      await fetchDashboardData();
    }
  }
  
  Future<void> fetchDashboardData() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await Future.wait([
        _fetchCycleData(),
        _fetchWaterIntake(),
        _fetchSleepData(),
        _fetchWeightData(),
        _fetchMoodData(),
      ]);
    } catch (e) {
      debugPrint('Error fetching dashboard data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> _fetchCycleData() async {
    try {
      final response = await _supabase
          .from('cycles')
          .select()
          .eq('user_id', _currentUser!.id)
          .order('start_date', ascending: false)
          .limit(5);
      
      if (response.isNotEmpty) {
        final lastCycle = response[0];
        final lastPeriodStart = DateTime.parse(lastCycle['start_date']);
        final daysSinceLastPeriod = DateTime.now().difference(lastPeriodStart).inDays;
        _currentCycleDay = daysSinceLastPeriod + 1;
        
        // Calculate next period (assuming 32 day cycle for PCOS)
        _nextPeriodDays = 32 - _currentCycleDay;
        if (_nextPeriodDays < 0) _nextPeriodDays = 3;
        
        // Determine phase
        if (_currentCycleDay <= 5) {
          _currentPhase = 'Menstrual';
        } else if (_currentCycleDay <= 14) {
          _currentPhase = 'Follicular';
        } else if (_currentCycleDay <= 16) {
          _currentPhase = 'Ovulatory';
        } else {
          _currentPhase = 'Luteal';
        }
      }
    } catch (e) {
      debugPrint('Error fetching cycle data: $e');
    }
  }
  
  Future<void> _fetchWaterIntake() async {
    try {
      final today = DateTime.now().toIso8601String().split('T').first;
      
      final response = await _supabase
          .from('water_intake')
          .select()
          .eq('user_id', _currentUser!.id)
          .eq('date', today)
          .maybeSingle();
      
      if (response != null) {
        _waterIntake = response['amount'] ?? 0;
        _waterGoal = response['goal'] ?? 2000;
      }
    } catch (e) {
      debugPrint('Error fetching water intake: $e');
    }
  }
  
  Future<void> _fetchSleepData() async {
    try {
      final today = DateTime.now().toIso8601String().split('T').first;
      
      final response = await _supabase
          .from('sleep_logs')
          .select()
          .eq('user_id', _currentUser!.id)
          .eq('date', today)
          .maybeSingle();
      
      if (response != null) {
        _sleepHours = (response['hours'] ?? 0).toDouble();
      }
    } catch (e) {
      debugPrint('Error fetching sleep data: $e');
    }
  }
  
  Future<void> _fetchWeightData() async {
    try {
      final response = await _supabase
          .from('weight_logs')
          .select()
          .eq('user_id', _currentUser!.id)
          .order('date', ascending: false)
          .limit(1)
          .maybeSingle();
      
      if (response != null) {
        _weight = (response['weight'] ?? 0).toDouble();
      }
    } catch (e) {
      debugPrint('Error fetching weight data: $e');
    }
  }
  
  Future<void> _fetchMoodData() async {
    try {
      final today = DateTime.now().toIso8601String().split('T').first;
      
      final response = await _supabase
          .from('mood_logs')
          .select()
          .eq('user_id', _currentUser!.id)
          .eq('date', today)
          .maybeSingle();
      
      if (response != null) {
        final moodValue = response['mood'] ?? 3;
        switch (moodValue) {
          case 1: _mood = 'Very Low'; break;
          case 2: _mood = 'Low'; break;
          case 3: _mood = 'Neutral'; break;
          case 4: _mood = 'Good'; break;
          case 5: _mood = 'Excellent'; break;
          default: _mood = 'Good';
        }
      }
    } catch (e) {
      debugPrint('Error fetching mood data: $e');
    }
  }
  
  Future<void> updateWaterIntake() async {
    try {
      final today = DateTime.now().toIso8601String().split('T').first;
      final newAmount = _waterIntake + 250;
      
      if (newAmount <= _waterGoal) {
        _waterIntake = newAmount;
        
        await _supabase.from('water_intake').upsert({
          'user_id': _currentUser!.id,
          'date': today,
          'amount': _waterIntake,
          'goal': _waterGoal,
          'updated_at': DateTime.now().toIso8601String(),
        });
        
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating water intake: $e');
    }
  }
}