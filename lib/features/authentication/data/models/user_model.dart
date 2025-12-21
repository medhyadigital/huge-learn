import '../../domain/entities/user.dart';

/// User model (data layer representation)
class UserModel extends User {
  const UserModel({
    required super.id,
    super.email,
    super.phone,
    required super.name,
    super.avatarUrl,
    super.createdAt,
  });
  
  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Handle NextAuth user format from HUGE API
    final role = json['role'] as Map<String, dynamic>?;
    return UserModel(
      id: json['id']?.toString() ?? '',
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      name: json['name'] as String ?? '',
      avatarUrl: json['image'] as String? ?? json['avatar_url'] as String? ?? json['avatarUrl'] as String?,
      createdAt: json['joinDate'] != null
          ? DateTime.parse(json['joinDate'] as String)
          : (json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : null),
    );
  }
  
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phone': phone,
      'name': name,
      'avatar_url': avatarUrl,
      'created_at': createdAt?.toIso8601String(),
    };
  }
  
  /// Convert to domain entity
  User toEntity() {
    return User(
      id: id,
      email: email,
      phone: phone,
      name: name,
      avatarUrl: avatarUrl,
      createdAt: createdAt,
    );
  }
}

