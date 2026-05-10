class CycleModel {
  final String id;
  final DateTime startDate;
  final DateTime endDate;
  final String flowLevel;
  final int painLevel;

  CycleModel({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.flowLevel,
    required this.painLevel,
  });

  factory CycleModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CycleModel(
      id: json['id'],
      startDate: DateTime.parse(
        json['start_date'],
      ),
      endDate: DateTime.parse(
        json['end_date'],
      ),
      flowLevel: json['flow_level'],
      painLevel: json['pain_level'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'start_date':
          startDate.toIso8601String(),
      'end_date':
          endDate.toIso8601String(),
      'flow_level': flowLevel,
      'pain_level': painLevel,
    };
  }
}