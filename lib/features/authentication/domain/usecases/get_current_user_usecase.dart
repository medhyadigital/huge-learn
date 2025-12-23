import '../../../../core/utils/result.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Get current user use case
class GetCurrentUserUseCase {
  final AuthRepository repository;
  
  GetCurrentUserUseCase(this.repository);
  
  FutureResult<User?> call() async {
    return await repository.getCurrentUser();
  }
}






