import 'package:equatable/equatable.dart';

class ProfileModel extends Equatable {
  final String userId;
  final String name;
  final String email;
  final String dateOfBirth;
  final String doctorName;
  final String avatarInitial;
  final String? avatarUrl;
  final String pcosDiagnosedYear;
  final List<String> pcosSymptoms;
  final String pcosType;
  final String medicationPreference;
  final int cycleTrackingReminderDays;
  final bool isPregnancyMode;
  final bool shareWithDoctor;
  final DateTime? lastPeriodDate;
  final DateTime? nextPeriodPredicted;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProfileModel({
    this.userId = '',
    this.name = '',
    this.email = '',
    this.dateOfBirth = '',
    this.doctorName = '',
    this.avatarInitial = 'U',
    this.avatarUrl,
    this.pcosDiagnosedYear = '2024',
    this.pcosSymptoms = const [],
    this.pcosType = 'PCOS',
    this.medicationPreference = 'pill',
    this.cycleTrackingReminderDays = 2,
    this.isPregnancyMode = false,
    this.shareWithDoctor = false,
    this.lastPeriodDate,
    this.nextPeriodPredicted,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  String get displayName {
    if (name.isEmpty) return 'User';
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0]} ${parts[1].substring(0, 1)}.';
    }
    return name;
  }

  int get age {
    if (dateOfBirth.isEmpty) return 0;
    try {
      final birthDate = DateTime.parse(dateOfBirth);
      final today = DateTime.now();
      int age = today.year - birthDate.year;
      if (today.month < birthDate.month ||
          (today.month == birthDate.month && today.day < birthDate.day)) {
        age--;
      }
      return age;
    } catch (e) {
      return 0;
    }
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'name': name,
        'email': email,
        'date_of_birth': dateOfBirth,
        'doctor_name': doctorName,
        'avatar_initial': avatarInitial,
        'avatar_url': avatarUrl,
        'pcos_diagnosed_year': pcosDiagnosedYear,
        'pcos_symptoms': pcosSymptoms,
        'pcos_type': pcosType,
        'medication_preference': medicationPreference,
        'cycle_tracking_reminder_days': cycleTrackingReminderDays,
        'is_pregnancy_mode': isPregnancyMode,
        'share_with_doctor': shareWithDoctor,
        'last_period_date': lastPeriodDate?.toIso8601String(),
        'next_period_predicted': nextPeriodPredicted?.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      userId: json['user_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      dateOfBirth: json['date_of_birth'] ?? '',
      doctorName: json['doctor_name'] ?? '',
      avatarInitial: json['avatar_initial'] ?? 'U',
      avatarUrl: json['avatar_url'],
      pcosDiagnosedYear: json['pcos_diagnosed_year'] ?? '2024',
      pcosSymptoms: json['pcos_symptoms'] != null
          ? List<String>.from(json['pcos_symptoms'])
          : [],
      pcosType: json['pcos_type'] ?? 'PCOS',
      medicationPreference: json['medication_preference'] ?? 'pill',
      cycleTrackingReminderDays: json['cycle_tracking_reminder_days'] ?? 2,
      isPregnancyMode: json['is_pregnancy_mode'] ?? false,
      shareWithDoctor: json['share_with_doctor'] ?? false,
      lastPeriodDate: json['last_period_date'] != null
          ? DateTime.parse(json['last_period_date'])
          : null,
      nextPeriodPredicted: json['next_period_predicted'] != null
          ? DateTime.parse(json['next_period_predicted'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }

  ProfileModel copyWith({
    String? userId,
    String? name,
    String? email,
    String? dateOfBirth,
    String? doctorName,
    String? avatarInitial,
    String? avatarUrl,
    String? pcosDiagnosedYear,
    List<String>? pcosSymptoms,
    String? pcosType,
    String? medicationPreference,
    int? cycleTrackingReminderDays,
    bool? isPregnancyMode,
    bool? shareWithDoctor,
    DateTime? lastPeriodDate,
    DateTime? nextPeriodPredicted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProfileModel(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      doctorName: doctorName ?? this.doctorName,
      avatarInitial: avatarInitial ?? this.avatarInitial,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      pcosDiagnosedYear: pcosDiagnosedYear ?? this.pcosDiagnosedYear,
      pcosSymptoms: pcosSymptoms ?? this.pcosSymptoms,
      pcosType: pcosType ?? this.pcosType,
      medicationPreference: medicationPreference ?? this.medicationPreference,
      cycleTrackingReminderDays:
          cycleTrackingReminderDays ?? this.cycleTrackingReminderDays,
      isPregnancyMode: isPregnancyMode ?? this.isPregnancyMode,
      shareWithDoctor: shareWithDoctor ?? this.shareWithDoctor,
      lastPeriodDate: lastPeriodDate ?? this.lastPeriodDate,
      nextPeriodPredicted: nextPeriodPredicted ?? this.nextPeriodPredicted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static ProfileModel empty() => ProfileModel();

  @override
  List<Object?> get props => [
        userId,
        name,
        email,
        dateOfBirth,
        doctorName,
        avatarInitial,
        avatarUrl,
        pcosDiagnosedYear,
        pcosSymptoms,
        pcosType,
        medicationPreference,
        cycleTrackingReminderDays,
        isPregnancyMode,
        shareWithDoctor,
        lastPeriodDate,
        nextPeriodPredicted,
      ];
}