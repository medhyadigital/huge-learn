import 'package:equatable/equatable.dart';

/// Learning profile entity
class LearningProfile extends Equatable {
  final String learningProfileId;
  final String userId;  // Foreign key to HUGE Auth user
  final String? displayName;
  final Map<String, dynamic> preferences;
  final bool onboardingCompleted;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isNew;  // Flag for newly created profiles
  
  const LearningProfile({
    required this.learningProfileId,
    required this.userId,
    this.displayName,
    this.preferences = const {},
    this.onboardingCompleted = false,
    required this.createdAt,
    this.updatedAt,
    this.isNew = false,
  });
  
  @override
  List<Object?> get props => [
    learningProfileId,
    userId,
    displayName,
    preferences,
    onboardingCompleted,
    createdAt,
    updatedAt,
    isNew,
  ];
  
  /// Copy with
  LearningProfile copyWith({
    String? learningProfileId,
    String? userId,
    String? displayName,
    Map<String, dynamic>? preferences,
    bool? onboardingCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isNew,
  }) {
    return LearningProfile(
      learningProfileId: learningProfileId ?? this.learningProfileId,
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      preferences: preferences ?? this.preferences,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isNew: isNew ?? this.isNew,
    );
  }
}




