// lib/features/profile/data/models/user_settings_model.dart
import 'package:equatable/equatable.dart';

class UserSettingsModel extends Equatable {
  final String userId;
  final int cycleLength;
  final int periodLength;
  final bool notificationsEnabled;
  final bool periodReminder;
  final bool ovulationReminder;
  final bool medicationReminder;
  final String weightUnit;
  final String temperatureUnit;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserSettingsModel({
    required this.userId,
    this.cycleLength = 32,
    this.periodLength = 5,
    this.notificationsEnabled = true,
    this.periodReminder = true,
    this.ovulationReminder = false,
    this.medicationReminder = true,
    this.weightUnit = 'kg',
    this.temperatureUnit = '°C',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'cycle_length': cycleLength,
        'period_length': periodLength,
        'notifications_enabled': notificationsEnabled,
        'period_reminder': periodReminder,
        'ovulation_reminder': ovulationReminder,
        'medication_reminder': medicationReminder,
        'weight_unit': weightUnit,
        'temperature_unit': temperatureUnit,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  factory UserSettingsModel.fromJson(Map<String, dynamic> json) {
    return UserSettingsModel(
      userId: json['user_id'],
      cycleLength: json['cycle_length'] ?? 32,
      periodLength: json['period_length'] ?? 5,
      notificationsEnabled: json['notifications_enabled'] ?? true,
      periodReminder: json['period_reminder'] ?? true,
      ovulationReminder: json['ovulation_reminder'] ?? false,
      medicationReminder: json['medication_reminder'] ?? true,
      weightUnit: json['weight_unit'] ?? 'kg',
      temperatureUnit: json['temperature_unit'] ?? '°C',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  UserSettingsModel copyWith({
    String? userId,
    int? cycleLength,
    int? periodLength,
    bool? notificationsEnabled,
    bool? periodReminder,
    bool? ovulationReminder,
    bool? medicationReminder,
    String? weightUnit,
    String? temperatureUnit,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserSettingsModel(
      userId: userId ?? this.userId,
      cycleLength: cycleLength ?? this.cycleLength,
      periodLength: periodLength ?? this.periodLength,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      periodReminder: periodReminder ?? this.periodReminder,
      ovulationReminder: ovulationReminder ?? this.ovulationReminder,
      medicationReminder: medicationReminder ?? this.medicationReminder,
      weightUnit: weightUnit ?? this.weightUnit,
      temperatureUnit: temperatureUnit ?? this.temperatureUnit,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static UserSettingsModel empty() {
    return UserSettingsModel(userId: '');
  }

  @override
  List<Object?> get props => [userId, cycleLength, periodLength];
}