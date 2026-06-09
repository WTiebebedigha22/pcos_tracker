// lib/features/symptoms/presentation/provider/symptoms_provider.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/symptom_model.dart';

class SymptomProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  List<SymptomModel> _recentSymptoms = [];
  List<SymptomModel> get recentSymptoms => _recentSymptoms;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  String? _error;
  String? get error => _error;
  
  Future<void> fetchRecentSymptoms() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;
      
      final response = await _supabase
          .from('symptoms')
          .select()
          .eq('user_id', user.id)
          .order('date', ascending: false)
          .limit(5);
      
      _recentSymptoms = (response as List)
          .map((json) => SymptomModel.fromJson(json))
          .toList();
          
    } catch (e) {
      _error = e.toString();
      debugPrint('Error fetching symptoms: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> addSymptom(SymptomModel symptom) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;
      
      await _supabase.from('symptoms').insert(symptom.toJson());
      await fetchRecentSymptoms(); // Refresh list
    } catch (e) {
      debugPrint('Error adding symptom: $e');
      rethrow;
    }
  }
}