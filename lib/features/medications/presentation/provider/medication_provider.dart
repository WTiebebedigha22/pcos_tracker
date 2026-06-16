// lib/features/medications/presentation/provider/medication_provider.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/medication_model.dart';

class MedicationProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  List<Medication> _medications = [];
  List<Medication> get medications => List.unmodifiable(_medications);
  
  List<MedLog> _logs = [];
  List<MedLog> get logs => List.unmodifiable(_logs);
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  String? _error;
  String? get error => _error;

  User? get _currentUser => _supabase.auth.currentUser;

  // Getters for UI
  List<Medication> get activeMedications => 
      _medications.where((m) => m.isActive).toList();
  
  List<Medication> get lowSupplyMeds => 
      _medications.where((m) => m.isActive && m.isLowSupply).toList();
  
  int get todayTotalCount {
    final now = DateTime.now();
    int count = 0;
    for (final med in activeMedications) {
      for (final time in med.times) {
        final medTime = DateTime(now.year, now.month, now.day, time.hour, time.minute);
        if (medTime.isBefore(now.add(const Duration(hours: 1)))) {
          count++;
        }
      }
    }
    return count;
  }
  
  int get todayTakenCount {
    final now = DateTime.now();
    int count = 0;
    for (final log in _logs) {
      if (log.takenAt.year == now.year &&
          log.takenAt.month == now.month &&
          log.takenAt.day == now.day &&
          !log.skipped) {
        count++;
      }
    }
    return count;
  }
  
  double get todayAdherencePercent {
    final total = todayTotalCount;
    if (total == 0) return 0;
    return todayTakenCount / total;
  }
  
  List<MedLog> get sortedLogs {
    final List<MedLog> sorted = List.from(_logs);
    sorted.sort((a, b) => b.takenAt.compareTo(a.takenAt));
    return sorted;
  }

  // Constructor - auto initialize
  MedicationProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    if (_currentUser != null) {
      await fetchData();
    }
    
    // Listen to auth changes
    _supabase.auth.onAuthStateChange.listen((event) {
      if (event.session != null && _currentUser != null) {
        fetchData();
      } else if (event.session == null) {
        _clearData();
      }
    });
  }

  void _clearData() {
    _medications = [];
    _logs = [];
    notifyListeners();
  }

  // NEW: fetchData method - public method to refresh all data
  Future<void> fetchData() async {
    if (_currentUser == null) return;
    
    _isLoading = true;
    notifyListeners();
    
    try {
      await Future.wait([
        fetchMedications(),
        fetchLogs(),
      ]);
    } catch (e) {
      _error = e.toString();
      debugPrint('Error fetching medication data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMedications() async {
    if (_currentUser == null) return;
    
    try {
      final response = await _supabase
          .from('medications')
          .select()
          .eq('user_id', _currentUser!.id)
          .order('created_at', ascending: false);
      
      _medications = (response as List)
          .map((json) => Medication.fromJson(json))
          .toList();
          
      debugPrint('Loaded ${_medications.length} medications');
    } catch (e) {
      debugPrint('Error fetching medications: $e');
      rethrow;
    }
  }

  Future<void> fetchLogs() async {
    if (_currentUser == null) return;
    
    try {
      final response = await _supabase
          .from('medication_logs')
          .select()
          .eq('user_id', _currentUser!.id)
          .order('taken_at', ascending: false)
          .limit(100);
      
      _logs = (response as List)
          .map((json) => MedLog.fromJson(json))
          .toList();
          
      debugPrint('Loaded ${_logs.length} logs');
    } catch (e) {
      debugPrint('Error fetching logs: $e');
      rethrow;
    }
  }

  // Add new medication
  Future<void> addMedication(Medication medication) async {
    if (_currentUser == null) return;
    
    try {
      await _supabase.from('medications').insert(medication.toJson());
      
      // Refresh the list
      await fetchData();
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding medication: $e');
      _error = e.toString();
      rethrow;
    }
  }

  // Log medication as taken
  Future<void> logTaken(String medicationId) async {
    if (_currentUser == null) return;
    
    try {
      final medication = _medications.firstWhere((m) => m.id == medicationId);
      
      final log = MedLog(
        id: 'log_${DateTime.now().millisecondsSinceEpoch}',
        userId: _currentUser!.id,
        medicationId: medicationId,
        medicationName: medication.name,
        dosage: medication.dosage,
        takenAt: DateTime.now(),
        skipped: false,
      );
      
      await _supabase.from('medication_logs').insert(log.toJson());
      
      // Update pill count
      if (medication.pillsRemaining > 0) {
        final updatedMed = medication.copyWith(
          pillsRemaining: medication.pillsRemaining - 1,
          updatedAt: DateTime.now(),
        );
        
        await _supabase
            .from('medications')
            .update(updatedMed.toJson())
            .eq('id', medicationId);
      }
      
      // Refresh data
      await fetchData();
    } catch (e) {
      debugPrint('Error logging taken: $e');
      _error = e.toString();
    }
  }

  // Log medication as skipped
  Future<void> logSkipped(String medicationId, {String? note}) async {
    if (_currentUser == null) return;
    
    try {
      final medication = _medications.firstWhere((m) => m.id == medicationId);
      
      final log = MedLog(
        id: 'log_${DateTime.now().millisecondsSinceEpoch}',
        userId: _currentUser!.id,
        medicationId: medicationId,
        medicationName: medication.name,
        dosage: medication.dosage,
        takenAt: DateTime.now(),
        skipped: true,
        note: note,
      );
      
      await _supabase.from('medication_logs').insert(log.toJson());
      
      // Refresh data
      await fetchData();
    } catch (e) {
      debugPrint('Error logging skipped: $e');
      _error = e.toString();
    }
  }

  // Toggle medication active status
  Future<void> toggleActive(String medicationId) async {
    try {
      final medication = _medications.firstWhere((m) => m.id == medicationId);
      final updatedMed = medication.copyWith(
        isActive: !medication.isActive,
        updatedAt: DateTime.now(),
      );
      
      await _supabase
          .from('medications')
          .update(updatedMed.toJson())
          .eq('id', medicationId);
      
      // Update local list
      final index = _medications.indexWhere((m) => m.id == medicationId);
      if (index != -1) {
        _medications[index] = updatedMed;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling active: $e');
      _error = e.toString();
    }
  }

  // Check if medication was taken today
  bool isTakenToday(String medicationId) {
    final now = DateTime.now();
    return _logs.any((log) {
      return log.medicationId == medicationId &&
             log.takenAt.year == now.year &&
             log.takenAt.month == now.month &&
             log.takenAt.day == now.day &&
             !log.skipped;
    });
  }

  // Delete medication
  Future<void> deleteMedication(String medicationId) async {
    try {
      await _supabase
          .from('medications')
          .delete()
          .eq('id', medicationId);
      
      _medications.removeWhere((m) => m.id == medicationId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting medication: $e');
      _error = e.toString();
    }
  }

  // Update supply
  Future<void> updateSupply(String medicationId, int newSupply) async {
    try {
      final medication = _medications.firstWhere((m) => m.id == medicationId);
      final updatedMed = medication.copyWith(
        pillsRemaining: newSupply,
        updatedAt: DateTime.now(),
      );
      
      await _supabase
          .from('medications')
          .update(updatedMed.toJson())
          .eq('id', medicationId);
      
      final index = _medications.indexWhere((m) => m.id == medicationId);
      if (index != -1) {
        _medications[index] = updatedMed;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating supply: $e');
      _error = e.toString();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}