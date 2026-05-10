class MedicationModel {
  final String id;
  final String medicationName;
  final String dosage;
  final String frequency;
  final String reminderTime;

  MedicationModel({
    required this.id,
    required this.medicationName,
    required this.dosage,
    required this.frequency,
    required this.reminderTime,
  });

  factory MedicationModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return MedicationModel(
      id: json['id'],
      medicationName:
          json['medication_name'],
      dosage: json['dosage'],
      frequency: json['frequency'],
      reminderTime: json['reminder_time'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'medication_name':
          medicationName,
      'dosage': dosage,
      'frequency': frequency,
      'reminder_time':
          reminderTime,
    };
  }
}