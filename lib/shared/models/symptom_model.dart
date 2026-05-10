class SymptomModel {
  final String id;
  final String symptomName;
  final int severity;
  final String? note;
  final DateTime createdAt;

  SymptomModel({
    required this.id,
    required this.symptomName,
    required this.severity,
    this.note,
    required this.createdAt,
  });

  factory SymptomModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return SymptomModel(
      id: json['id'],
      symptomName: json['symptom_name'],
      severity: json['severity'],
      note: json['note'],
      createdAt: DateTime.parse(
        json['created_at'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symptom_name': symptomName,
      'severity': severity,
      'note': note,
      'created_at': createdAt.toIso8601String(),
    };
  }
}