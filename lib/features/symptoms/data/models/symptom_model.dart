// lib/features/symptoms/data/models/symptom_model.dart
import 'package:equatable/equatable.dart';

class SymptomModel extends Equatable {
  final String id;
  final String userId;
  final DateTime date;
  final List<String> symptoms;
  final int moodRating; // 1-5
  final int energyLevel; // 1-5
  final double sleepHours;
  final String? customSymptoms;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SymptomModel({
    required this.id,
    required this.userId,
    required this.date,
    required this.symptoms,
    required this.moodRating,
    required this.energyLevel,
    required this.sleepHours,
    this.customSymptoms,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  String get severity {
    if (symptoms.length <= 2) return 'Mild';
    if (symptoms.length <= 4) return 'Moderate';
    return 'Severe';
  }

  String get name => symptoms.isNotEmpty ? symptoms.first : 'No symptoms';

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'date': date.toIso8601String(),
    'symptoms': symptoms,
    'mood_rating': moodRating,
    'energy_level': energyLevel,
    'sleep_hours': sleepHours,
    'custom_symptoms': customSymptoms,
    'notes': notes,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  factory SymptomModel.fromJson(Map<String, dynamic> json) {
    return SymptomModel(
      id: json['id'],
      userId: json['user_id'],
      date: DateTime.parse(json['date']),
      symptoms: List<String>.from(json['symptoms'] ?? []),
      moodRating: json['mood_rating'] ?? 3,
      energyLevel: json['energy_level'] ?? 3,
      sleepHours: (json['sleep_hours'] ?? 0).toDouble(),
      customSymptoms: json['custom_symptoms'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  SymptomModel copyWith({
    String? id,
    String? userId,
    DateTime? date,
    List<String>? symptoms,
    int? moodRating,
    int? energyLevel,
    double? sleepHours,
    String? customSymptoms,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SymptomModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      symptoms: symptoms ?? this.symptoms,
      moodRating: moodRating ?? this.moodRating,
      energyLevel: energyLevel ?? this.energyLevel,
      sleepHours: sleepHours ?? this.sleepHours,
      customSymptoms: customSymptoms ?? this.customSymptoms,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, userId, date, symptoms, moodRating, energyLevel];
}