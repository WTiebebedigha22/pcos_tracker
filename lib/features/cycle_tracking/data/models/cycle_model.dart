// lib/features/cycle_tracking/data/models/cycle_model.dart
import 'package:equatable/equatable.dart';

class CycleModel extends Equatable {
  final String id;
  final String userId;
  final DateTime startDate;
  final DateTime? endDate;
  final String flowIntensity; // light, medium, heavy
  final List<String> symptoms;
  final String? notes;
  final bool isIrregular;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CycleModel({
    required this.id,
    required this.userId,
    required this.startDate,
    this.endDate,
    required this.flowIntensity,
    required this.symptoms,
    this.notes,
    this.isIrregular = false,
    required this.createdAt,
    required this.updatedAt,
  });

  int get duration {
    if (endDate == null) return 0;
    return endDate!.difference(startDate).inDays + 1;
  }

  bool get isActive => endDate == null;

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'start_date': startDate.toIso8601String(),
    'end_date': endDate?.toIso8601String(),
    'flow_intensity': flowIntensity,
    'symptoms': symptoms,
    'notes': notes,
    'is_irregular': isIrregular,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  factory CycleModel.fromJson(Map<String, dynamic> json) {
    return CycleModel(
      id: json['id'],
      userId: json['user_id'],
      startDate: DateTime.parse(json['start_date']),
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      flowIntensity: json['flow_intensity'] ?? 'medium',
      symptoms: List<String>.from(json['symptoms'] ?? []),
      notes: json['notes'],
      isIrregular: json['is_irregular'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  CycleModel copyWith({
    String? id,
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
    String? flowIntensity,
    List<String>? symptoms,
    String? notes,
    bool? isIrregular,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CycleModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      flowIntensity: flowIntensity ?? this.flowIntensity,
      symptoms: symptoms ?? this.symptoms,
      notes: notes ?? this.notes,
      isIrregular: isIrregular ?? this.isIrregular,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, userId, startDate, endDate, flowIntensity, symptoms];
}