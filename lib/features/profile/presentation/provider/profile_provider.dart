import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
// Models
// ─────────────────────────────────────────────
class UserProfile {
  final String name;
  final String email;
  final String avatarInitial;
  final String dateOfBirth;
  final String diagnosedYear;
  final String doctorName;

  const UserProfile({
    required this.name,
    required this.email,
    required this.avatarInitial,
    required this.dateOfBirth,
    required this.diagnosedYear,
    required this.doctorName,
  });

  UserProfile copyWith({
    String? name,
    String? email,
    String? avatarInitial,
    String? dateOfBirth,
    String? diagnosedYear,
    String? doctorName,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      avatarInitial: avatarInitial ?? this.avatarInitial,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      diagnosedYear: diagnosedYear ?? this.diagnosedYear,
      doctorName: doctorName ?? this.doctorName,
    );
  }
}

class HealthSettings {
  final int cycleLength;
  final int periodLength;
  final bool notificationsEnabled;
  final bool periodReminder;
  final bool ovulationReminder;
  final bool medicationReminder;
  final String weightUnit; // 'kg' | 'lbs'
  final String temperatureUnit; // '°C' | '°F'

  const HealthSettings({
    required this.cycleLength,
    required this.periodLength,
    required this.notificationsEnabled,
    required this.periodReminder,
    required this.ovulationReminder,
    required this.medicationReminder,
    required this.weightUnit,
    required this.temperatureUnit,
  });

  HealthSettings copyWith({
    int? cycleLength,
    int? periodLength,
    bool? notificationsEnabled,
    bool? periodReminder,
    bool? ovulationReminder,
    bool? medicationReminder,
    String? weightUnit,
    String? temperatureUnit,
  }) {
    return HealthSettings(
      cycleLength: cycleLength ?? this.cycleLength,
      periodLength: periodLength ?? this.periodLength,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      periodReminder: periodReminder ?? this.periodReminder,
      ovulationReminder: ovulationReminder ?? this.ovulationReminder,
      medicationReminder: medicationReminder ?? this.medicationReminder,
      weightUnit: weightUnit ?? this.weightUnit,
      temperatureUnit: temperatureUnit ?? this.temperatureUnit,
    );
  }
}

// ─────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────
class UserProvider extends ChangeNotifier {
  UserProfile _profile = const UserProfile(
    name: 'Maya Johnson',
    email: 'maya.johnson@email.com',
    avatarInitial: 'M',
    dateOfBirth: 'March 14, 1995',
    diagnosedYear: '2021',
    doctorName: 'Dr. Sarah Williams',
  );

  HealthSettings _settings = const HealthSettings(
    cycleLength: 28,
    periodLength: 5,
    notificationsEnabled: true,
    periodReminder: true,
    ovulationReminder: true,
    medicationReminder: false,
    weightUnit: 'kg',
    temperatureUnit: '°C',
  );

  // ── Getters ──────────────────────────────────
  UserProfile get profile => _profile;
  HealthSettings get settings => _settings;

  String get displayName => _profile.name;
  String get email => _profile.email;
  String get avatarInitial => _profile.avatarInitial;

  // ── Profile updates ──────────────────────────
  void updateProfile(UserProfile updated) {
    _profile = updated;
    notifyListeners();
  }

  void updateName(String name) {
    _profile = _profile.copyWith(
      name: name,
      avatarInitial: name.isNotEmpty ? name[0].toUpperCase() : 'U',
    );
    notifyListeners();
  }

  void updateEmail(String email) {
    _profile = _profile.copyWith(email: email);
    notifyListeners();
  }

  void updateDoctorName(String doctorName) {
    _profile = _profile.copyWith(doctorName: doctorName);
    notifyListeners();
  }

  // ── Health settings updates ───────────────────
  void updateSettings(HealthSettings updated) {
    _settings = updated;
    notifyListeners();
  }

  void toggleNotifications(bool value) {
    _settings = _settings.copyWith(notificationsEnabled: value);
    notifyListeners();
  }

  void togglePeriodReminder(bool value) {
    _settings = _settings.copyWith(periodReminder: value);
    notifyListeners();
  }

  void toggleOvulationReminder(bool value) {
    _settings = _settings.copyWith(ovulationReminder: value);
    notifyListeners();
  }

  void toggleMedicationReminder(bool value) {
    _settings = _settings.copyWith(medicationReminder: value);
    notifyListeners();
  }

  void updateCycleLength(int days) {
    _settings = _settings.copyWith(cycleLength: days);
    notifyListeners();
  }

  void updatePeriodLength(int days) {
    _settings = _settings.copyWith(periodLength: days);
    notifyListeners();
  }

  void updateWeightUnit(String unit) {
    _settings = _settings.copyWith(weightUnit: unit);
    notifyListeners();
  }

  void updateTemperatureUnit(String unit) {
    _settings = _settings.copyWith(temperatureUnit: unit);
    notifyListeners();
  }
}