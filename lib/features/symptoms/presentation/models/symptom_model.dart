// lib/features/symptoms/data/models/symptom_model.dart
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class SymptomModel extends Equatable {
  final String id;
  final String userId;
  final DateTime date;
  final List<String> symptoms;
  final int moodRating;
  final int energyLevel;
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

  // Helper getters
  String get severity {
    if (symptoms.length <= 2) return 'Mild';
    if (symptoms.length <= 4) return 'Moderate';
    return 'Severe';
  }

  String get name {
    if (symptoms.isNotEmpty) return symptoms.first;
    if (customSymptoms != null && customSymptoms!.isNotEmpty) return customSymptoms!;
    return 'No symptoms';
  }

  String get moodLabel {
    switch (moodRating) {
      case 1: return 'Terrible';
      case 2: return 'Bad';
      case 3: return 'Okay';
      case 4: return 'Good';
      case 5: return 'Great';
      default: return 'Okay';
    }
  }

  String get energyLabel {
    switch (energyLevel) {
      case 1: return 'Exhausted';
      case 2: return 'Tired';
      case 3: return 'Normal';
      case 4: return 'Energetic';
      case 5: return 'Very Energetic';
      default: return 'Normal';
    }
  }

  IconData get moodIcon {
    switch (moodRating) {
      case 1: return Icons.sentiment_very_dissatisfied;
      case 2: return Icons.sentiment_dissatisfied;
      case 3: return Icons.sentiment_neutral;
      case 4: return Icons.sentiment_satisfied;
      case 5: return Icons.sentiment_very_satisfied;
      default: return Icons.sentiment_neutral;
    }
  }

  Color get moodColor {
    switch (moodRating) {
      case 1: return Colors.red;
      case 2: return Colors.orange;
      case 3: return Colors.yellow;
      case 4: return Colors.lightGreen;
      case 5: return Colors.green;
      default: return Colors.grey;
    }
  }

  // JSON Serialization
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

  // Copy with method for immutability
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

  // Empty instance
  static SymptomModel empty() {
    return SymptomModel(
      id: '',
      userId: '',
      date: DateTime.now(),
      symptoms: [],
      moodRating: 3,
      energyLevel: 3,
      sleepHours: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
    id, 
    userId, 
    date, 
    symptoms, 
    moodRating, 
    energyLevel, 
    sleepHours,
  ];
}