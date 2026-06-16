// lib/features/symptoms/presentation/provider/symptoms_provider.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/symptom_model.dart';

class SymptomProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  List<SymptomModel> _recentSymptoms = [];
  List<SymptomModel> get recentSymptoms => _recentSymptoms;
  
  List<SymptomModel> _allSymptoms = [];
  List<SymptomModel> get allSymptoms => _allSymptoms;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  String? _error;
  String? get error => _error;

  SymptomProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      await fetchAllSymptoms();
      await fetchRecentSymptoms();
    }
    
    // Listen to auth changes
    _supabase.auth.onAuthStateChange.listen((event) {
      if (event.session != null) {
        fetchAllSymptoms();
        fetchRecentSymptoms();
      } else {
        _clearData();
      }
    });
  }

  void _clearData() {
    _recentSymptoms = [];
    _allSymptoms = [];
    _isLoading = false;
    notifyListeners();
  }

  // Fetch all symptoms (for history page)
  Future<void> fetchAllSymptoms() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        _allSymptoms = [];
        _isLoading = false;
        notifyListeners();
        return;
      }
      
      final response = await _supabase
          .from('symptoms')
          .select()
          .eq('user_id', user.id)
          .order('date', ascending: false);
      
      _allSymptoms = (response as List)
          .map((json) => SymptomModel.fromJson(json))
          .toList();
          
      debugPrint('Loaded ${_allSymptoms.length} total symptoms');
    } catch (e) {
      _error = e.toString();
      debugPrint('Error fetching all symptoms: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch recent symptoms (for dashboard)
  Future<void> fetchRecentSymptoms({int limit = 5}) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        _recentSymptoms = [];
        notifyListeners();
        return;
      }
      
      final response = await _supabase
          .from('symptoms')
          .select()
          .eq('user_id', user.id)
          .order('date', ascending: false)
          .limit(limit);
      
      _recentSymptoms = (response as List)
          .map((json) => SymptomModel.fromJson(json))
          .toList();
          
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching recent symptoms: $e');
    }
  }
  
  // Add new symptom
  Future<bool> addSymptom(SymptomModel symptom) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;
      
      final newSymptom = symptom.copyWith(
        userId: user.id,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await _supabase.from('symptoms').insert(newSymptom.toJson());
      
      // Refresh lists
      await fetchAllSymptoms();
      await fetchRecentSymptoms();
      
      return true;
    } catch (e) {
      debugPrint('Error adding symptom: $e');
      _error = e.toString();
      return false;
    }
  }
  
  // Update existing symptom
  Future<bool> updateSymptom(SymptomModel symptom) async {
    try {
      final updatedSymptom = symptom.copyWith(
        updatedAt: DateTime.now(),
      );
      
      await _supabase
          .from('symptoms')
          .update(updatedSymptom.toJson())
          .eq('id', symptom.id);
      
      // Refresh lists
      await fetchAllSymptoms();
      await fetchRecentSymptoms();
      
      return true;
    } catch (e) {
      debugPrint('Error updating symptom: $e');
      _error = e.toString();
      return false;
    }
  }
  
  // Delete symptom
  Future<bool> deleteSymptom(String id) async {
    try {
      await _supabase.from('symptoms').delete().eq('id', id);
      
      // Refresh lists
      await fetchAllSymptoms();
      await fetchRecentSymptoms();
      
      return true;
    } catch (e) {
      debugPrint('Error deleting symptom: $e');
      _error = e.toString();
      return false;
    }
  }
  
  // Get symptoms by date range
  Future<List<SymptomModel>> getSymptomsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return [];
      
      final response = await _supabase
          .from('symptoms')
          .select()
          .eq('user_id', user.id)
          .gte('date', startDate.toIso8601String())
          .lte('date', endDate.toIso8601String())
          .order('date', ascending: false);
      
      return (response as List)
          .map((json) => SymptomModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Error fetching symptoms by date range: $e');
      return [];
    }
  }
  
  // Get symptoms by severity
  Future<List<SymptomModel>> getSymptomsBySeverity(String severity) async {
    await fetchAllSymptoms();
    return _allSymptoms.where((s) => s.severity == severity).toList();
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
}