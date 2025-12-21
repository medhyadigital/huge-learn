import 'package:dartz/dartz.dart';
import '../../../../core/utils/result.dart';
import '../repositories/auth_repository.dart';
import '../../../learning/domain/repositories/learning_profile_repository.dart';

/// Logout use case with graceful sync across apps
class LogoutWithSyncUseCase {
  final AuthRepository authRepository;
  final LearningProfileRepository learningProfileRepository;
  
  LogoutWithSyncUseCase(
    this.authRepository,
    this.learningProfileRepository,
  );
  
  FutureResult<void> call() async {
    // Step 1: Try to logout from auth service (best effort)
    final logoutResult = await authRepository.logout();
    
    // Step 2: Clear learning profile (regardless of auth logout result)
    await learningProfileRepository.clearProfile();
    
    // Step 3: Return logout result
    // Even if server logout fails (network error), we've cleared local data
    return logoutResult.fold(
      (failure) {
        // Log the failure but don't prevent logout
        // User's local data is already cleared
        return const Right(null);
      },
      (success) => const Right(null),
    );
  }
}

