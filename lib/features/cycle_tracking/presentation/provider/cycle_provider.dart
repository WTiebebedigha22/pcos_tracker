// lib/features/cycle_tracking/presentation/provider/cycle_provider.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/cycle_model.dart';

class CycleProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  List<CycleModel> _cycles = [];
  List<CycleModel> get cycles => List.unmodifiable(_cycles);
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  String? _error;
  String? get error => _error;

  CycleProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      await fetchCycles();
    }
  }

  Future<void> fetchCycles() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;
    
    _isLoading = true;
    notifyListeners();
    
    try {
      final response = await _supabase
          .from('cycles')
          .select()
          .eq('user_id', user.id)
          .order('start_date', ascending: false);
      
      _cycles = (response as List)
          .map((json) => CycleModel.fromJson(json))
          .toList();
          
      debugPrint('Loaded ${_cycles.length} cycles');
    } catch (e) {
      _error = e.toString();
      debugPrint('Error fetching cycles: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCycle(CycleModel cycle) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;
    
    try {
      await _supabase.from('cycles').insert(cycle.toJson());
      await fetchCycles();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      debugPrint('Error adding cycle: $e');
      rethrow;
    }
  }

  Future<void> updateCycle(CycleModel cycle) async {
    try {
      await _supabase
          .from('cycles')
          .update(cycle.toJson())
          .eq('id', cycle.id);
      
      final index = _cycles.indexWhere((c) => c.id == cycle.id);
      if (index != -1) {
        _cycles[index] = cycle;
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      debugPrint('Error updating cycle: $e');
    }
  }

  Future<void> deleteCycle(String id) async {
    try {
      await _supabase.from('cycles').delete().eq('id', id);
      _cycles.removeWhere((c) => c.id == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      debugPrint('Error deleting cycle: $e');
    }
  }

  String getDailyInsight() {
    if (_cycles.isEmpty) {
      return 'Log your first period to start receiving personalized insights about your cycle.';
    }
    
    // Simple insight based on cycle patterns
    final lastCycle = _cycles.first;
    final daysSinceLastPeriod = DateTime.now().difference(lastCycle.startDate).inDays;
    
    if (daysSinceLastPeriod <= 5) {
      return 'Your period is active. Rest well and stay hydrated. Iron-rich foods can help maintain energy levels.';
    } else if (daysSinceLastPeriod <= 14) {
      return 'You are in your follicular phase. Energy levels typically increase. Great time for exercise and new activities!';
    } else if (daysSinceLastPeriod <= 16) {
      return 'Ovulation window approaching. You may notice increased libido and energy.';
    } else {
      return 'Luteal phase - you might experience PMS symptoms. Focus on self-care and balanced nutrition.';
    }
  }

  DateTime? getNextPredictedPeriod() {
    if (_cycles.isEmpty) return null;
    
    // Calculate average cycle length
    final cyclesWithEnd = _cycles.where((c) => c.endDate != null).toList();
    if (cyclesWithEnd.length < 2) return null;
    
    int totalDays = 0;
    for (int i = 1; i < cyclesWithEnd.length; i++) {
      final previous = cyclesWithEnd[i];
      final current = cyclesWithEnd[i - 1];
      final daysBetween = previous.startDate.difference(current.startDate).inDays.abs();
      totalDays += daysBetween;
    }
    
    final avgCycleLength = (totalDays / (cyclesWithEnd.length - 1)).round();
    final lastPeriodStart = _cycles.first.startDate;
    final nextPeriod = lastPeriodStart.add(Duration(days: avgCycleLength));
    
    return nextPeriod;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}