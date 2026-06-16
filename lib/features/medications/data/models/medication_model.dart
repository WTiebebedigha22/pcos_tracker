// lib/features/medications/data/models/medication_model.dart
import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

enum MedFrequency {
  daily('Daily', 'Daily'),
  twiceDaily('Twice Daily', '2x/day'),
  threeTimesDaily('Three Times', '3x/day'),
  weekly('Weekly', 'Weekly'),
  monthly('Monthly', 'Monthly');

  final String label;
  final String shortLabel;
  const MedFrequency(this.label, this.shortLabel);
}

enum MedCategory {
  supplement('Supplement', Color(0xFF8B3FD9), Color(0xFFEDE8F9)),
  prescription('Prescription', Color(0xFF2DB96B), Color(0xFFE6F9EE)),
  otc('OTC', Color(0xFFE94DA0), Color(0xFFFDE8F0));

  final String label;
  final Color color;
  final Color bgColor;
  const MedCategory(this.label, this.color, this.bgColor);
}

enum DayPeriod { am, pm }

extension TimeOfDayExtension on TimeOfDay {
  int get hourOfPeriod {
    final h = hour;
    if (h == 0) return 12;
    if (h > 12) return h - 12;
    return h;
  }

  DayPeriod get period => hour < 12 ? DayPeriod.am : DayPeriod.pm;
  
  String toJson() => '${hour}:${minute}';
  
  static TimeOfDay fromJson(String json) {
    final parts = json.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }
}

class Medication extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String dosage;
  final MedFrequency frequency;
  final MedCategory category;
  final List<TimeOfDay> times;
  final String? notes;
  final DateTime startDate;
  final int pillsRemaining;
  final int pillsTotal;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Medication({
    required this.id,
    required this.userId,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.category,
    required this.times,
    this.notes,
    required this.startDate,
    required this.pillsRemaining,
    required this.pillsTotal,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  double get supplyPercent => pillsRemaining / pillsTotal;
  bool get isLowSupply => supplyPercent < 0.2;

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'name': name,
    'dosage': dosage,
    'frequency': frequency.name,
    'category': category.name,
    'times': times.map((t) => t.toJson()).toList(),
    'notes': notes,
    'start_date': startDate.toIso8601String(),
    'pills_remaining': pillsRemaining,
    'pills_total': pillsTotal,
    'is_active': isActive,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      dosage: json['dosage'],
      frequency: MedFrequency.values.firstWhere(
        (e) => e.name == json['frequency'],
        orElse: () => MedFrequency.daily,
      ),
      category: MedCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => MedCategory.supplement,
      ),
      times: (json['times'] as List)
          .map((t) => TimeOfDayExtension.fromJson(t))
          .toList(),
      notes: json['notes'],
      startDate: DateTime.parse(json['start_date']),
      pillsRemaining: json['pills_remaining'],
      pillsTotal: json['pills_total'],
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Medication copyWith({
    String? id,
    String? userId,
    String? name,
    String? dosage,
    MedFrequency? frequency,
    MedCategory? category,
    List<TimeOfDay>? times,
    String? notes,
    DateTime? startDate,
    int? pillsRemaining,
    int? pillsTotal,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Medication(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      category: category ?? this.category,
      times: times ?? this.times,
      notes: notes ?? this.notes,
      startDate: startDate ?? this.startDate,
      pillsRemaining: pillsRemaining ?? this.pillsRemaining,
      pillsTotal: pillsTotal ?? this.pillsTotal,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static Medication empty() {
    return Medication(
      id: '',
      userId: '',
      name: '',
      dosage: '',
      frequency: MedFrequency.daily,
      category: MedCategory.supplement,
      times: [],
      startDate: DateTime.now(),
      pillsRemaining: 0,
      pillsTotal: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [id, name, dosage, isActive];
}

class MedLog extends Equatable {
  final String id;
  final String userId;
  final String medicationId;
  final String medicationName;
  final String dosage;
  final DateTime takenAt;
  final bool skipped;
  final String? note;

  const MedLog({
    required this.id,
    required this.userId,
    required this.medicationId,
    required this.medicationName,
    required this.dosage,
    required this.takenAt,
    required this.skipped,
    this.note,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'medication_id': medicationId,
    'medication_name': medicationName,
    'dosage': dosage,
    'taken_at': takenAt.toIso8601String(),
    'skipped': skipped,
    'note': note,
  };

  factory MedLog.fromJson(Map<String, dynamic> json) {
    return MedLog(
      id: json['id'],
      userId: json['user_id'],
      medicationId: json['medication_id'],
      medicationName: json['medication_name'],
      dosage: json['dosage'],
      takenAt: DateTime.parse(json['taken_at']),
      skipped: json['skipped'] ?? false,
      note: json['note'],
    );
  }

  @override
  List<Object?> get props => [id, medicationId, takenAt];
}