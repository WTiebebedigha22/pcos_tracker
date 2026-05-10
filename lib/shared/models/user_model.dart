class UserModel {
  final String id;
  final String email;
  final String fullName;
  final int age;
  final double height;
  final double weight;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.age,
    required this.height,
    required this.weight,
  });

  factory UserModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      fullName: json['full_name'],
      age: json['age'],
      height: (json['height'] as num).toDouble(),
      weight: (json['weight'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'age': age,
      'height': height,
      'weight': weight,
    };
  }
}