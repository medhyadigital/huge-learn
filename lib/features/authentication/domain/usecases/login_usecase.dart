import 'package:dartz/dartz.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/extensions.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Login use case
class LoginUseCase {
  final AuthRepository repository;
  
  LoginUseCase(this.repository);
  
  FutureResult<User> call(String email, String password) async {
    // Validate inputs
    if (email.isEmpty) {
      return const Left(ValidationFailure('Email cannot be empty'));
    }
    
    if (!email.isValidEmail) {
      return const Left(ValidationFailure('Please enter a valid email address'));
    }
    
    if (password.isEmpty) {
      return const Left(ValidationFailure('Password cannot be empty'));
    }
    
    if (password.length < 6) {
      return const Left(ValidationFailure('Password must be at least 6 characters'));
    }
    
    return await repository.login(email, password);
  }
}

