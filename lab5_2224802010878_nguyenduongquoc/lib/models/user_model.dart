class UserModel {
  final String id;
  final String email;
  final String? fullName;

  UserModel({
    required this.id,
    required this.email,
    this.fullName,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'],
    );
  }
}
