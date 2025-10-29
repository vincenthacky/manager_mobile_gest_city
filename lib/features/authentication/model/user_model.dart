class UserModel {
  final int id;
  final String fullName;
  final String email;
  final String phone;
  final int? villaId;
  final String? imageUrl;
  final String role;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    this.villaId,
    this.imageUrl,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      fullName: json['full_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      villaId: json['villa_id'] != null ? (json['villa_id'] as num).toInt() : null,
      imageUrl: json['image_url'] as String?,
      role: json['role'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'villa_id': villaId,
      'image_url': imageUrl,
      'role': role,
    };
  }

  @override
  String toString() {
    return 'UserModel(id: $id, fullName: $fullName, email: $email, phone: $phone, villaId: $villaId, imageUrl: $imageUrl, role: $role)';
  }
}