import '../../../../core/utils/result.dart';
import '../entities/learning_profile.dart';
import '../repositories/learning_profile_repository.dart';

/// Get or auto-create learning profile use case
class GetOrCreateLearningProfileUseCase {
  final LearningProfileRepository repository;
  
  GetOrCreateLearningProfileUseCase(this.repository);
  
  FutureResult<LearningProfile> call() async {
    return await repository.getOrCreateProfile();
  }
}




