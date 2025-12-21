import '../entities/user.dart';
import '../../../../core/utils/result.dart';

/// Authentication repository interface
abstract class AuthRepository {
  /// Login with email and password (HUGE API only supports email)
  FutureResult<User> login({required String email, required String password});
  
  /// Register new user (HUGE API format)
  FutureResult<User> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
    required String address,
    required String city,
    required String state,
    required String country,
    required String pinCode,
    required String dateOfBirth,
    required String gender,
    String? occupation,
    String? referralCode,
    String? recaptchaToken,
    String? emailOTP,
  });
  
  /// Logout current user
  FutureResult<void> logout();
  
  /// Get current user
  FutureResult<User?> getCurrentUser();
  
  /// Check if user is authenticated
  FutureResult<bool> isAuthenticated();
  
  /// Forgot password - request reset link
  FutureResult<void> forgotPassword({required String email});
  
  /// Send OTP for email verification
  FutureResult<void> sendOTP({required String email, String type = 'REGISTRATION'});
  
  /// Verify OTP
  FutureResult<void> verifyOTP({required String email, required String otp, String type = 'REGISTRATION'});
}


