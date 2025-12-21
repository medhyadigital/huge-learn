import 'package:equatable/equatable.dart';

/// User entity
class User extends Equatable {
  final String id;
  final String? email;
  final String? phone;
  final String name;
  final String? avatarUrl;
  final DateTime? createdAt;
  
  const User({
    required this.id,
    this.email,
    this.phone,
    required this.name,
    this.avatarUrl,
    this.createdAt,
  });
  
  @override
  List<Object?> get props => [id, email, phone, name, avatarUrl, createdAt];
  
  /// Create user from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      name: json['name'] as String,
      avatarUrl: json['avatar_url'] as String? ?? json['avatarUrl'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }
  
  /// Convert user to JSON
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
}


