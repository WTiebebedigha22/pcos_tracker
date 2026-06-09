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
    final List<MedLog> sorted = [];
    sorted.addAll(_logs);
    sorted.sort((a, b) => b.takenAt.compareTo(a.takenAt));
    return sorted;
  }

  Future<void> initialize() async {
    await Future.wait([
      fetchMedications(),
      fetchLogs(),
    ]);
  }

  Future<void> fetchMedications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final response = await _supabase
          .from('medications')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      _medications = (response as List)
          .map((json) => Medication.fromJson(json))
          .toList();
    } catch (e) {
      _error = e.toString();
      debugPrint('Error fetching medications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchLogs() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final response = await _supabase
          .from('medication_logs')
          .select()
          .eq('user_id', user.id)
          .order('taken_at', ascending: false)
          .limit(50);

      _logs = (response as List)
          .map((json) => MedLog.fromJson(json))
          .toList();
          
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching logs: $e');
    }
  }

  Future<void> addMedication(Medication medication) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final now = DateTime.now();
      final newMedication = Medication(
        id: 'med_${now.millisecondsSinceEpoch}_${now.microsecond}',
        name: medication.name,
        dosage: medication.dosage,
        frequency: medication.frequency,
        category: medication.category,
        times: List.from(medication.times),
        notes: medication.notes,
        startDate: now,
        pillsRemaining: medication.pillsRemaining,
        pillsTotal: medication.pillsTotal,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      final json = newMedication.toJson();
      json['user_id'] = user.id;

      await _supabase.from('medications').insert(json);
      
      _medications.insert(0, newMedication);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding medication: $e');
      _error = e.toString();
    }
  }

  Future<void> logTaken(String medicationId) async {
    try {
      final user = _supabase.auth.currentUser;
      final medication = _medications.firstWhere((m) => m.id == medicationId);
      
      if (user == null) return;

      final log = MedLog(
        id: 'log_${DateTime.now().millisecondsSinceEpoch}',
        medicationId: medicationId,
        medicationName: medication.name,
        dosage: medication.dosage,
        takenAt: DateTime.now(),
        skipped: false,
      );

      final json = log.toJson();
      json['user_id'] = user.id;

      await _supabase.from('medication_logs').insert(json);
      
      if (medication.pillsRemaining > 0) {
        final updatedMed = Medication(
          id: medication.id,
          name: medication.name,
          dosage: medication.dosage,
          frequency: medication.frequency,
          category: medication.category,
          times: medication.times,
          notes: medication.notes,
          startDate: medication.startDate,
          pillsRemaining: medication.pillsRemaining - 1,
          pillsTotal: medication.pillsTotal,
          isActive: medication.isActive,
          createdAt: medication.createdAt,
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
      }
      
      _logs.insert(0, log);
      notifyListeners();
    } catch (e) {
      debugPrint('Error logging taken: $e');
      _error = e.toString();
    }
  }

  Future<void> logSkipped(String medicationId, {String? note}) async {
    try {
      final user = _supabase.auth.currentUser;
      final medication = _medications.firstWhere((m) => m.id == medicationId);
      
      if (user == null) return;

      final log = MedLog(
        id: 'log_${DateTime.now().millisecondsSinceEpoch}',
        medicationId: medicationId,
        medicationName: medication.name,
        dosage: medication.dosage,
        takenAt: DateTime.now(),
        skipped: true,
        note: note,
      );

      final json = log.toJson();
      json['user_id'] = user.id;

      await _supabase.from('medication_logs').insert(json);
      
      _logs.insert(0, log);
      notifyListeners();
    } catch (e) {
      debugPrint('Error logging skipped: $e');
      _error = e.toString();
    }
  }

  Future<void> toggleActive(String medicationId) async {
    try {
      final medication = _medications.firstWhere((m) => m.id == medicationId);
      final updatedMed = Medication(
        id: medication.id,
        name: medication.name,
        dosage: medication.dosage,
        frequency: medication.frequency,
        category: medication.category,
        times: medication.times,
        notes: medication.notes,
        startDate: medication.startDate,
        pillsRemaining: medication.pillsRemaining,
        pillsTotal: medication.pillsTotal,
        isActive: !medication.isActive,
        createdAt: medication.createdAt,
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
      debugPrint('Error toggling active: $e');
      _error = e.toString();
    }
  }

  bool isTakenToday(String medicationId) {
    final now = DateTime.now();
    for (final log in _logs) {
      if (log.medicationId == medicationId &&
          log.takenAt.year == now.year &&
          log.takenAt.month == now.month &&
          log.takenAt.day == now.day &&
          !log.skipped) {
        return true;
      }
    }
    return false;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}