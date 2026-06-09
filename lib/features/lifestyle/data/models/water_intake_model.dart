// lib/features/lifestyle/data/models/water_intake_model.dart
import 'package:equatable/equatable.dart';

class WaterIntakeModel extends Equatable {
  final String id;
  final String userId;
  final DateTime date;
  final int amount; // in milliliters
  final int goal; // daily goal in milliliters
  final DateTime? lastUpdated;
  final DateTime createdAt;
  final DateTime updatedAt;

  const WaterIntakeModel({
    required this.id,
    required this.userId,
    required this.date,
    required this.amount,
    required this.goal,
    this.lastUpdated,
    required this.createdAt,
    required this.updatedAt,
  });

  int get percentage => ((amount / goal) * 100).toInt();
  bool get isGoalMet => amount >= goal;
  String get amountInLiters => '${(amount / 1000).toStringAsFixed(1)}L';
  String get goalInLiters => '${(goal / 1000).toStringAsFixed(1)}L';

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'date': date.toIso8601String(),
    'amount': amount,
    'goal': goal,
    'last_updated': lastUpdated?.toIso8601String(),
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  factory WaterIntakeModel.fromJson(Map<String, dynamic> json) {
    return WaterIntakeModel(
      id: json['id'],
      userId: json['user_id'],
      date: DateTime.parse(json['date']),
      amount: json['amount'] ?? 0,
      goal: json['goal'] ?? 2000,
      lastUpdated: json['last_updated'] != null ? DateTime.parse(json['last_updated']) : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  WaterIntakeModel copyWith({
    String? id,
    String? userId,
    DateTime? date,
    int? amount,
    int? goal,
    DateTime? lastUpdated,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WaterIntakeModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      goal: goal ?? this.goal,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, userId, date, amount, goal];
}