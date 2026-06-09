import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
// Enums
// ─────────────────────────────────────────────
enum MedFrequency { daily, twiceDaily, weekly, asNeeded }

enum MedCategory { hormone, supplement, prescription, otc }

extension MedFrequencyLabel on MedFrequency {
  String get label {
    switch (this) {
      case MedFrequency.daily:
        return 'Once daily';
      case MedFrequency.twiceDaily:
        return 'Twice daily';
      case MedFrequency.weekly:
        return 'Weekly';
      case MedFrequency.asNeeded:
        return 'As needed';
    }
  }

  String get shortLabel {
    switch (this) {
      case MedFrequency.daily:
        return '1×/day';
      case MedFrequency.twiceDaily:
        return '2×/day';
      case MedFrequency.weekly:
        return '1×/week';
      case MedFrequency.asNeeded:
        return 'As needed';
    }
  }
}

extension MedCategoryLabel on MedCategory {
  String get label {
    switch (this) {
      case MedCategory.hormone:
        return 'Hormone';
      case MedCategory.supplement:
        return 'Supplement';
      case MedCategory.prescription:
        return 'Prescription';
      case MedCategory.otc:
        return 'OTC';
    }
  }

  Color get color {
    switch (this) {
      case MedCategory.hormone:
        return const Color(0xFFE94DA0);
      case MedCategory.supplement:
        return const Color(0xFF2DB96B);
      case MedCategory.prescription:
        return const Color(0xFF8B3FD9);
      case MedCategory.otc:
        return const Color(0xFF5B7FD9);
    }
  }

  Color get bgColor {
    switch (this) {
      case MedCategory.hormone:
        return const Color(0xFFFDE8F0);
      case MedCategory.supplement:
        return const Color(0xFFE6F9EE);
      case MedCategory.prescription:
        return const Color(0xFFEDE8F9);
      case MedCategory.otc:
        return const Color(0xFFE8EEF9);
    }
  }
}

// ─────────────────────────────────────────────
// Models
// ─────────────────────────────────────────────
class Medication {
  final String id;
  final String name;
  final String dosage;
  final MedFrequency frequency;
  final MedCategory category;
  final List<TimeOfDay> times; // scheduled times
  final String? notes;
  final bool isActive;
  final DateTime startDate;
  final DateTime? endDate;
  final int pillsRemaining;
  final int pillsTotal;

  const Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.category,
    required this.times,
    required this.startDate,
    required this.pillsRemaining,
    required this.pillsTotal,
    this.notes,
    this.isActive = true,
    this.endDate,
  });

  double get supplyPercent =>
      pillsTotal > 0 ? pillsRemaining / pillsTotal : 0.0;

  bool get isLowSupply => supplyPercent < 0.25;

  Medication copyWith({
    String? name,
    String? dosage,
    MedFrequency? frequency,
    MedCategory? category,
    List<TimeOfDay>? times,
    String? notes,
    bool? isActive,
    DateTime? endDate,
    int? pillsRemaining,
    int? pillsTotal,
  }) {
    return Medication(
      id: id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      category: category ?? this.category,
      times: times ?? this.times,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      startDate: startDate,
      endDate: endDate ?? this.endDate,
      pillsRemaining: pillsRemaining ?? this.pillsRemaining,
      pillsTotal: pillsTotal ?? this.pillsTotal,
    );
  }
}

class MedLog {
  final String id;
  final String medicationId;
  final String medicationName;
  final String dosage;
  final DateTime takenAt;
  final bool skipped;
  final String? note;

  const MedLog({
    required this.id,
    required this.medicationId,
    required this.medicationName,
    required this.dosage,
    required this.takenAt,
    this.skipped = false,
    this.note,
  });
}

// ─────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────
class MedicationProvider extends ChangeNotifier {
  final List<Medication> _medications = [
    Medication(
      id: 'm1',
      name: 'Metformin',
      dosage: '500mg',
      frequency: MedFrequency.twiceDaily,
      category: MedCategory.prescription,
      times: [const TimeOfDay(hour: 8, minute: 0), const TimeOfDay(hour: 20, minute: 0)],
      startDate: DateTime(2024, 1, 15),
      pillsRemaining: 18,
      pillsTotal: 60,
      notes: 'Take with food to reduce nausea',
    ),
    Medication(
      id: 'm2',
      name: 'Inositol',
      dosage: '2g',
      frequency: MedFrequency.twiceDaily,
      category: MedCategory.supplement,
      times: [const TimeOfDay(hour: 8, minute: 0), const TimeOfDay(hour: 20, minute: 0)],
      startDate: DateTime(2024, 2, 1),
      pillsRemaining: 45,
      pillsTotal: 60,
      notes: 'Mix with water or juice',
    ),
    Medication(
      id: 'm3',
      name: 'Spearmint',
      dosage: '400mg',
      frequency: MedFrequency.daily,
      category: MedCategory.supplement,
      times: [const TimeOfDay(hour: 9, minute: 0)],
      startDate: DateTime(2024, 3, 10),
      pillsRemaining: 52,
      pillsTotal: 60,
    ),
    Medication(
      id: 'm4',
      name: 'Vitamin D3',
      dosage: '2000 IU',
      frequency: MedFrequency.daily,
      category: MedCategory.supplement,
      times: [const TimeOfDay(hour: 8, minute: 30)],
      startDate: DateTime(2024, 1, 1),
      pillsRemaining: 8,
      pillsTotal: 90,
    ),
    Medication(
      id: 'm5',
      name: 'Progesterone',
      dosage: '100mg',
      frequency: MedFrequency.daily,
      category: MedCategory.hormone,
      times: [const TimeOfDay(hour: 22, minute: 0)],
      startDate: DateTime(2024, 4, 1),
      pillsRemaining: 30,
      pillsTotal: 30,
      notes: 'Take at bedtime',
    ),
  ];

  final List<MedLog> _logs = [
    MedLog(
      id: 'l1',
      medicationId: 'm1',
      medicationName: 'Metformin',
      dosage: '500mg',
      takenAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    MedLog(
      id: 'l2',
      medicationId: 'm2',
      medicationName: 'Inositol',
      dosage: '2g',
      takenAt: DateTime.now().subtract(const Duration(hours: 2, minutes: 5)),
    ),
    MedLog(
      id: 'l3',
      medicationId: 'm3',
      medicationName: 'Spearmint',
      dosage: '400mg',
      takenAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
    ),
    MedLog(
      id: 'l4',
      medicationId: 'm4',
      medicationName: 'Vitamin D3',
      dosage: '2000 IU',
      takenAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
    ),
    MedLog(
      id: 'l5',
      medicationId: 'm1',
      medicationName: 'Metformin',
      dosage: '500mg',
      takenAt: DateTime.now().subtract(const Duration(days: 1, hours: 14)),
    ),
    MedLog(
      id: 'l6',
      medicationId: 'm5',
      medicationName: 'Progesterone',
      dosage: '100mg',
      takenAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    MedLog(
      id: 'l7',
      medicationId: 'm2',
      medicationName: 'Inositol',
      dosage: '2g',
      takenAt: DateTime.now().subtract(const Duration(days: 2, hours: 3)),
      skipped: true,
      note: 'Forgot in the morning',
    ),
  ];

  // ── Getters ──────────────────────────────────
  List<Medication> get medications => List.unmodifiable(_medications);
  List<Medication> get activeMedications =>
      _medications.where((m) => m.isActive).toList();
  List<MedLog> get logs => List.unmodifiable(_logs);

  List<Medication> get lowSupplyMeds =>
      _medications.where((m) => m.isActive && m.isLowSupply).toList();

  /// Logs for today only
  List<MedLog> get todayLogs {
    final today = DateTime.now();
    return _logs
        .where((l) =>
            l.takenAt.year == today.year &&
            l.takenAt.month == today.month &&
            l.takenAt.day == today.day)
        .toList()
      ..sort((a, b) => b.takenAt.compareTo(a.takenAt));
  }

  /// All logs sorted newest-first
  List<MedLog> get sortedLogs =>
      [..._logs]..sort((a, b) => b.takenAt.compareTo(a.takenAt));

  /// IDs of meds already taken today
  Set<String> get takenTodayIds =>
      todayLogs.where((l) => !l.skipped).map((l) => l.medicationId).toSet();

  int get todayTakenCount => takenTodayIds.length;
  int get todayTotalCount => activeMedications.length;

  double get todayAdherencePercent =>
      todayTotalCount > 0 ? todayTakenCount / todayTotalCount : 0.0;

  // ── Actions ──────────────────────────────────
  void logTaken(String medicationId, {String? note}) {
    final med = _medications.firstWhere((m) => m.id == medicationId);
    _logs.add(MedLog(
      id: 'l${DateTime.now().millisecondsSinceEpoch}',
      medicationId: medicationId,
      medicationName: med.name,
      dosage: med.dosage,
      takenAt: DateTime.now(),
      note: note,
    ));
    // decrement supply
    final idx = _medications.indexWhere((m) => m.id == medicationId);
    if (idx != -1 && _medications[idx].pillsRemaining > 0) {
      _medications[idx] = _medications[idx]
          .copyWith(pillsRemaining: _medications[idx].pillsRemaining - 1);
    }
    notifyListeners();
  }

  void logSkipped(String medicationId, {String? note}) {
    final med = _medications.firstWhere((m) => m.id == medicationId);
    _logs.add(MedLog(
      id: 'l${DateTime.now().millisecondsSinceEpoch}',
      medicationId: medicationId,
      medicationName: med.name,
      dosage: med.dosage,
      takenAt: DateTime.now(),
      skipped: true,
      note: note,
    ));
    notifyListeners();
  }

  void addMedication(Medication med) {
    _medications.add(med);
    notifyListeners();
  }

  void updateMedication(Medication updated) {
    final idx = _medications.indexWhere((m) => m.id == updated.id);
    if (idx != -1) {
      _medications[idx] = updated;
      notifyListeners();
    }
  }

  void toggleActive(String id) {
    final idx = _medications.indexWhere((m) => m.id == id);
    if (idx != -1) {
      _medications[idx] =
          _medications[idx].copyWith(isActive: !_medications[idx].isActive);
      notifyListeners();
    }
  }

  void deleteMedication(String id) {
    _medications.removeWhere((m) => m.id == id);
    notifyListeners();
  }

  bool isTakenToday(String medicationId) =>
      takenTodayIds.contains(medicationId);
}