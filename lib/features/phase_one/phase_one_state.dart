import 'package:flutter/foundation.dart';

import '../../core/services/local_storage_service.dart';

const String lunoraMedicalDisclaimer =
    'Lunora is a tracking tool, not a medical device, and does not diagnose PCOS. '
    'Your records are for personal tracking and are not a substitute for medical advice.';

const Map<String, List<Map<String, String>>> symptomGroups = {
  'hormonal': [
    {'id': 'acne', 'label': 'Acne'},
    {'id': 'hirsutism', 'label': 'Excess hair'},
    {'id': 'hair_thinning', 'label': 'Hair thinning'},
    {'id': 'skin_darkening', 'label': 'Skin darkening'},
  ],
  'metabolic': [
    {'id': 'cravings', 'label': 'Cravings'},
    {'id': 'energy_crash', 'label': 'Energy crash'},
    {'id': 'bloating', 'label': 'Bloating'},
    {'id': 'weight_change', 'label': 'Weight change'},
  ],
  'mental': [
    {'id': 'anxiety', 'label': 'Anxiety'},
    {'id': 'mood_swings', 'label': 'Mood swings'},
    {'id': 'brain_fog', 'label': 'Brain fog'},
    {'id': 'low_motivation', 'label': 'Low motivation'},
  ],
  'cycle': [
    {'id': 'spotting', 'label': 'Spotting'},
    {'id': 'cramping', 'label': 'Cramping'},
    {'id': 'flow_heavy', 'label': 'Heavy flow'},
    {'id': 'flow_light', 'label': 'Light flow'},
  ],
};

const Map<String, String> symptomGroupLabels = {
  'hormonal': 'Hormonal',
  'metabolic': 'Metabolic',
  'mental': 'Mental and emotional',
  'cycle': 'Cycle-related',
};

const List<String> medicationPresets = [
  'Metformin 500mg',
  'Inositol 2g',
  'Spironolactone 50mg',
  'Birth control daily',
  'Vitamin D 2000 IU',
  'Omega-3 1000mg',
];

String localDateKey([DateTime? value]) {
  final date = value ?? DateTime.now();
  return '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

class PhaseDayLog {
  const PhaseDayLog({
    this.symptoms = const [],
    this.severity = 3,
    this.notes = '',
    this.meds = const [],
    required this.updatedAt,
  });

  final List<String> symptoms;
  final int severity;
  final String notes;
  final List<String> meds;
  final int updatedAt;

  factory PhaseDayLog.fromMap(Map<dynamic, dynamic> map) => PhaseDayLog(
        symptoms: List<String>.from(map['symptoms'] as List? ?? const []),
        severity: (map['severity'] as num?)?.toInt() ?? 3,
        notes: map['notes'] as String? ?? '',
        meds: List<String>.from(map['meds'] as List? ?? const []),
        updatedAt: (map['updatedAt'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toMap() => {
        'symptoms': symptoms,
        'severity': severity,
        'notes': notes,
        'meds': meds,
        'updatedAt': updatedAt,
      };
}

class PhaseMedication {
  const PhaseMedication({
    required this.id,
    required this.name,
    required this.dose,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String dose;
  final int createdAt;

  factory PhaseMedication.fromMap(Map<dynamic, dynamic> map) => PhaseMedication(
        id: map['id'] as String? ?? '',
        name: map['name'] as String? ?? '',
        dose: map['dose'] as String? ?? '',
        createdAt: (map['createdAt'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'dose': dose,
        'createdAt': createdAt,
      };
}

/// Local-only Phase 1 root state. All fields are stored together in Hive.
class PhaseOneState extends ChangeNotifier {
  static const _box = 'lunora_phase1';
  static const _key = 'root_state';

  Map<String, dynamic>? onboarding;
  final Map<String, PhaseDayLog> logs = {};
  final List<PhaseMedication> meds = [];
  bool _isReady = false;

  bool get isReady => _isReady;

  Future<void> load() async {
    final raw = await LocalStorageService.getData(_box, _key);
    if (raw is Map) {
      final data = Map<dynamic, dynamic>.from(raw);
      final savedOnboarding = data['onboarding'];
      onboarding = savedOnboarding is Map
          ? Map<String, dynamic>.from(savedOnboarding)
          : null;
      logs
        ..clear()
        ..addEntries((data['logs'] as Map? ?? const {}).entries.map((entry) =>
            MapEntry(entry.key.toString(),
                PhaseDayLog.fromMap(Map<dynamic, dynamic>.from(entry.value as Map)))));
      meds
        ..clear()
        ..addAll((data['meds'] as List? ?? const []).whereType<Map>().map(
            (item) => PhaseMedication.fromMap(Map<dynamic, dynamic>.from(item))));
    }
    _isReady = true;
    notifyListeners();
  }

  Future<void> _persist() async {
    await LocalStorageService.saveData(_box, _key, {
      'onboarding': onboarding,
      'logs': logs.map((key, value) => MapEntry(key, value.toMap())),
      'meds': meds.map((med) => med.toMap()).toList(),
    });
  }

  Future<void> saveOnboarding({
    required String? goal,
    required String? lastPeriod,
    required List<String> priorities,
    required bool? notificationsEnabled,
  }) async {
    onboarding = {
      'goal': goal,
      'lastPeriod': lastPeriod,
      'priorities': priorities,
      'onboardedAt': DateTime.now().millisecondsSinceEpoch,
      'notificationsEnabled': notificationsEnabled ?? false,
    };
    await _persist();
    notifyListeners();
  }

  Future<void> skipOnboarding() => saveOnboarding(
        goal: 'symptoms',
        lastPeriod: null,
        priorities: const [],
        notificationsEnabled: false,
      );

  Future<void> rerunOnboarding() async {
    onboarding = null;
    await _persist();
    notifyListeners();
  }

  Future<void> saveSymptomLog({
    required List<String> symptoms,
    required int severity,
    required String notes,
  }) async {
    final key = localDateKey();
    final previous = logs[key];
    logs[key] = PhaseDayLog(
      symptoms: List.unmodifiable(symptoms),
      severity: severity,
      notes: notes,
      meds: previous?.meds ?? const [],
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
    await _persist();
    notifyListeners();
  }

  Future<void> toggleMedicationTaken(String medicationId, bool taken) async {
    final key = localDateKey();
    final previous = logs[key] ??
        PhaseDayLog(updatedAt: DateTime.now().millisecondsSinceEpoch);
    final selected = [...previous.meds];
    if (taken && !selected.contains(medicationId)) selected.add(medicationId);
    if (!taken) selected.remove(medicationId);
    logs[key] = PhaseDayLog(
      symptoms: previous.symptoms,
      severity: previous.severity,
      notes: previous.notes,
      meds: selected,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
    await _persist();
    notifyListeners();
  }

  Future<void> addMedication(String name, String dose) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    meds.add(PhaseMedication(
      id: '$now-${name.hashCode}',
      name: name.trim(),
      dose: dose.trim(),
      createdAt: now,
    ));
    await _persist();
    notifyListeners();
  }

  Future<void> deleteMedication(String id) async {
    meds.removeWhere((med) => med.id == id);
    // Historical logs intentionally retain the removed medication ID.
    await _persist();
    notifyListeners();
  }

  Future<void> clearAll() async {
    onboarding = null;
    logs.clear();
    meds.clear();
    await _persist();
    notifyListeners();
  }
}
