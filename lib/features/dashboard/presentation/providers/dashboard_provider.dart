// lib/features/dashboard/presentation/providers/dashboard_provider.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  User? _currentUser;
  User? get currentUser => _currentUser;
  
  // User Profile Data
  String _userName = 'User';
  String get userName => _userName;
  
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
  
  String? _error;
  String? get error => _error;
  
  // Average cycle length for better predictions
  int _averageCycleLength = 32;
  int get averageCycleLength => _averageCycleLength;

  DashboardProvider() {
    _initialize();
  }
  
  Future<void> _initialize() async {
    _currentUser = _supabase.auth.currentUser;
    if (_currentUser != null) {
      await fetchDashboardData();
    }
    
    // Listen to auth changes
    _supabase.auth.onAuthStateChange.listen((event) {
      if (event.session != null) {
        _currentUser = event.session!.user;
        fetchDashboardData();
      } else {
        _clearData();
      }
    });
  }
  
  void _clearData() {
    _userName = 'User';
    _currentCycleDay = 1;
    _currentPhase = 'Follicular';
    _nextPeriodDays = 0;
    _waterIntake = 0;
    _waterGoal = 2000;
    _sleepHours = 0;
    _weight = 0;
    _mood = 'Good';
    _averageCycleLength = 32;
    _isLoading = false;
    notifyListeners();
  }
  
  Future<void> fetchDashboardData() async {
    if (_currentUser == null) return;
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await Future.wait([
        _fetchUserProfile(),
        _fetchCycleData(),
        _fetchWaterIntake(),
        _fetchSleepData(),
        _fetchWeightData(),
        _fetchMoodData(),
        _fetchAverageCycleLength(),
      ]);
    } catch (e) {
      _error = e.toString();
      debugPrint('Error fetching dashboard data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> _fetchUserProfile() async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('name, first_name, last_name')
          .eq('user_id', _currentUser!.id)
          .maybeSingle();
      
      if (response != null) {
        // Try to get name from different possible fields
        if (response['name'] != null && response['name'].toString().isNotEmpty) {
          _userName = response['name'].toString().split(' ')[0];
        } else if (response['first_name'] != null && response['first_name'].toString().isNotEmpty) {
          _userName = response['first_name'].toString();
        } else {
          // Fallback to email username
          final email = _currentUser!.email ?? '';
          _userName = email.split('@').first;
        }
      } else {
        // Fallback to email username
        final email = _currentUser!.email ?? '';
        _userName = email.split('@').first;
      }
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
      // Fallback to email username
      final email = _currentUser!.email ?? '';
      _userName = email.split('@').first;
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
        
        // Use average cycle length for better prediction
        final cycleLength = _averageCycleLength > 0 ? _averageCycleLength : 32;
        _nextPeriodDays = cycleLength - _currentCycleDay;
        if (_nextPeriodDays < 0) _nextPeriodDays = 3;
        
        // Determine phase based on actual cycle length
        final phaseDay = _currentCycleDay % cycleLength;
        if (phaseDay <= 5) {
          _currentPhase = 'Menstrual';
        } else if (phaseDay <= 14) {
          _currentPhase = 'Follicular';
        } else if (phaseDay <= 16) {
          _currentPhase = 'Ovulatory';
        } else {
          _currentPhase = 'Luteal';
        }
      }
    } catch (e) {
      debugPrint('Error fetching cycle data: $e');
      _error = e.toString();
    }
  }
  
  Future<void> _fetchAverageCycleLength() async {
    try {
      final response = await _supabase
          .from('cycles')
          .select('start_date')
          .eq('user_id', _currentUser!.id)
          .order('start_date', ascending: true);
      
      if (response.length >= 2) {
        int totalDays = 0;
        int cycleCount = 0;
        
        for (int i = 1; i < response.length; i++) {
          final prevStart = DateTime.parse(response[i - 1]['start_date']);
          final currStart = DateTime.parse(response[i]['start_date']);
          final daysDiff = currStart.difference(prevStart).inDays;
          
          if (daysDiff > 20 && daysDiff < 60) { // Valid cycle range
            totalDays += daysDiff;
            cycleCount++;
          }
        }
        
        if (cycleCount > 0) {
          _averageCycleLength = (totalDays / cycleCount).round();
        }
      }
    } catch (e) {
      debugPrint('Error calculating average cycle length: $e');
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
      } else {
        // Create default record for today if not exists
        await _supabase.from('water_intake').insert({
          'user_id': _currentUser!.id,
          'date': today,
          'amount': 0,
          'goal': _waterGoal,
          'created_at': DateTime.now().toIso8601String(),
        });
        _waterIntake = 0;
      }
    } catch (e) {
      debugPrint('Error fetching water intake: $e');
      _error = e.toString();
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
      } else {
        _sleepHours = 0;
      }
    } catch (e) {
      debugPrint('Error fetching sleep data: $e');
      _error = e.toString();
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
      } else {
        _weight = 0;
      }
    } catch (e) {
      debugPrint('Error fetching weight data: $e');
      _error = e.toString();
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
      } else {
        _mood = 'Not logged';
      }
    } catch (e) {
      debugPrint('Error fetching mood data: $e');
      _error = e.toString();
    }
  }
  
  Future<void> updateWaterIntake() async {
    if (_currentUser == null) return;
    
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
        
        // Show success feedback
        debugPrint('Water intake updated: $_waterIntake ml');
      }
    } catch (e) {
      debugPrint('Error updating water intake: $e');
      _error = e.toString();
    }
  }
  
  Future<void> addWaterIntake(int amount) async {
    if (_currentUser == null) return;
    
    try {
      final today = DateTime.now().toIso8601String().split('T').first;
      final newAmount = _waterIntake + amount;
      
      if (newAmount <= _waterGoal) {
        _waterIntake = newAmount;
      } else {
        _waterIntake = _waterGoal;
      }
      
      await _supabase.from('water_intake').upsert({
        'user_id': _currentUser!.id,
        'date': today,
        'amount': _waterIntake,
        'goal': _waterGoal,
        'updated_at': DateTime.now().toIso8601String(),
      });
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding water intake: $e');
      _error = e.toString();
    }
  }
  
  Future<void> resetWaterIntake() async {
    if (_currentUser == null) return;
    
    try {
      final today = DateTime.now().toIso8601String().split('T').first;
      _waterIntake = 0;
      
      await _supabase.from('water_intake').upsert({
        'user_id': _currentUser!.id,
        'date': today,
        'amount': 0,
        'goal': _waterGoal,
        'updated_at': DateTime.now().toIso8601String(),
      });
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error resetting water intake: $e');
      _error = e.toString();
    }
  }
  
  Future<void> refreshDashboard() async {
    await fetchDashboardData();
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
}