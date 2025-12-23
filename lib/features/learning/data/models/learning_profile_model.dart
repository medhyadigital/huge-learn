import '../../domain/entities/learning_profile.dart';

/// Learning profile model (data layer)
class LearningProfileModel extends LearningProfile {
  const LearningProfileModel({
    required super.learningProfileId,
    required super.userId,
    super.displayName,
    super.preferences,
    super.onboardingCompleted,
    required super.createdAt,
    super.updatedAt,
    super.isNew,
  });
  
  /// From JSON
  factory LearningProfileModel.fromJson(Map<String, dynamic> json) {
    return LearningProfileModel(
      learningProfileId: json['learning_profile_id'] as String,
      userId: json['user_id'] as String,
      displayName: json['display_name'] as String?,
      preferences: json['preferences'] as Map<String, dynamic>? ?? {},
      onboardingCompleted: json['onboarding_completed'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      isNew: json['is_new'] as bool? ?? false,
    );
  }
  
  /// To JSON
  Map<String, dynamic> toJson() {
    return {
      'learning_profile_id': learningProfileId,
      'user_id': userId,
      'display_name': displayName,
      'preferences': preferences,
      'onboarding_completed': onboardingCompleted,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_new': isNew,
    };
  }
  
  /// To entity
  LearningProfile toEntity() {
    return LearningProfile(
      learningProfileId: learningProfileId,
      userId: userId,
      displayName: displayName,
      preferences: preferences,
      onboardingCompleted: onboardingCompleted,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isNew: isNew,
    );
  }
}






