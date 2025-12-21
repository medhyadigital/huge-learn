import '../../../../core/utils/result.dart';
import '../entities/learning_profile.dart';

/// Learning profile repository interface
abstract class LearningProfileRepository {
  /// Get or auto-create learning profile
  FutureResult<LearningProfile> getOrCreateProfile();
  
  /// Update learning profile
  FutureResult<LearningProfile> updateProfile({
    Map<String, dynamic>? preferences,
    bool? onboardingCompleted,
  });
  
  /// Get cached learning profile
  FutureResult<LearningProfile?> getCachedProfile();
  
  /// Clear learning profile data
  FutureResult<void> clearProfile();
}




