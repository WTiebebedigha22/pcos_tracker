class WeightLogModel {
  final String id;
  final double weight;
  final DateTime createdAt;

  WeightLogModel({
    required this.id,
    required this.weight,
    required this.createdAt,
  });

  factory WeightLogModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return WeightLogModel(
      id: json['id'],
      weight:
          (json['weight'] as num)
              .toDouble(),
      createdAt: DateTime.parse(
        json['created_at'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'weight': weight,
      'created_at':
          createdAt.toIso8601String(),
    };
  }
}