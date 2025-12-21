import 'package:dartz/dartz.dart';
import '../network/api_client.dart';
import '../error/exceptions.dart';
import '../error/failures.dart';
import '../utils/result.dart';

/// Auth response model (NextAuth format)
class AuthResponse {
  final Map<String, dynamic> user;
  final String? expires;
  
  AuthResponse({
    required this.user,
    this.expires,
  });
  
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: json['user'] as Map<String, dynamic>? ?? {},
      expires: json['expires'] as String?,
    );
  }
  
  String get userId => user['id']?.toString() ?? '';
}

/// Service for HUGE Foundations User Auth integration
class AuthService {
  final ApiClient _apiClient;
  
  AuthService(this._apiClient);
  
  /// Login with email and password
  /// 
  /// NextAuth.js blocks direct POST to /callback/credentials from external clients.
  /// HUGE Foundations backend should expose a custom mobile authentication endpoint.
  /// 
  /// Trying multiple approaches:
  /// 1. /api/auth/mobile/login (if custom mobile endpoint exists)
  /// 2. /api/auth/login (if custom endpoint exists)
  /// 3. /api/auth/signin (NextAuth standard, might require CSRF)
  FutureResult<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      // Try custom mobile login endpoint first (if HUGE has one)
      try {
        final response = await _apiClient.post(
          '/mobile/login',
          data: {
            'email': email,
            'password': password,
          },
        );
        
        if (response.data != null && (response.data as Map).isNotEmpty) {
          final responseData = response.data as Map<String, dynamic>;
          if (responseData.containsKey('error')) {
            // Continue to next method
          } else {
            final authResponse = AuthResponse.fromJson(responseData);
            return Right(authResponse);
          }
        }
      } catch (e) {
        // Mobile endpoint doesn't exist, try next method
      }
      
      // Try custom /api/auth/login endpoint (if HUGE has one)
      try {
        final response = await _apiClient.post(
          '/login',
          data: {
            'email': email,
            'password': password,
          },
        );
        
        if (response.data != null && (response.data as Map).isNotEmpty) {
          final responseData = response.data as Map<String, dynamic>;
          if (responseData.containsKey('error')) {
            final errorMessage = responseData['error'] as String? ?? 
                                responseData['message'] as String? ?? 
                                'Login failed';
            return Left(AuthFailure(errorMessage));
          }
          
          // Handle different response formats
          if (responseData.containsKey('user')) {
            final authResponse = AuthResponse.fromJson(responseData);
            return Right(authResponse);
          } else if (responseData.containsKey('access_token')) {
            // JWT token format - convert to session format
            final user = responseData['user'] as Map<String, dynamic>? ?? {};
            final authResponse = AuthResponse(user: user, expires: null);
            return Right(authResponse);
          }
        }
      } catch (e) {
        // Custom login endpoint doesn't exist, try NextAuth signin
      }
      
      // Try NextAuth /api/auth/signin with JSON
      // Some NextAuth configurations allow JSON for mobile
      try {
        final response = await _apiClient.post(
          '/signin',
          data: {
            'email': email,
            'password': password,
            'redirect': false,
            'json': true,
          },
        );
        
        // If signin returns 200, get session
        if (response.statusCode == 200) {
          final sessionResponse = await _apiClient.get('/session');
          if (sessionResponse.data != null && (sessionResponse.data as Map).isNotEmpty) {
            final sessionData = sessionResponse.data as Map<String, dynamic>;
            final authResponse = AuthResponse.fromJson(sessionData);
            return Right(authResponse);
          }
        }
      } catch (e) {
        // NextAuth signin failed, return error
        return Left(AuthFailure('Authentication failed. Please contact support if this issue persists.'));
      }
      
      return const Left(AuthFailure('No authentication endpoint available'));
    } on AppException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (e) {
      final errorMessage = e.toString();
      if (errorMessage.contains('Connection refused') || 
          errorMessage.contains('Failed host lookup') ||
          errorMessage.contains('SocketException')) {
        return Left(NetworkFailure('Cannot connect to server. Please check your internet connection.'));
      }
      return Left(UnknownFailure('An unexpected error occurred: ${errorMessage}'));
    }
  }
  
  /// Register new user (HUGE Foundations API format)
  FutureResult<AuthResponse> register({
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
  }) async {
    try {
      final data = <String, dynamic>{
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'confirmPassword': confirmPassword,
        'address': address,
        'city': city,
        'state': state,
        'country': country,
        'pinCode': pinCode,
        'dateOfBirth': dateOfBirth,
        'gender': gender,
      };
      
      if (occupation != null) data['occupation'] = occupation;
      if (referralCode != null) data['referralCode'] = referralCode;
      if (recaptchaToken != null) data['recaptchaToken'] = recaptchaToken;
      if (emailOTP != null) data['emailOTP'] = emailOTP;
      
      final response = await _apiClient.post(
        '/register',
        data: data,
      );
      
      // Registration response format: { message: "...", user: {...} }
      final responseData = response.data as Map<String, dynamic>;
      
      // Check for error in response
      if (responseData.containsKey('error')) {
        final errorMessage = responseData['error'] as String? ?? 
                            responseData['message'] as String? ?? 
                            'Registration failed';
        return Left(AuthFailure(errorMessage));
      }
      
      final user = responseData['user'] as Map<String, dynamic>? ?? {};
      
      if (user.isEmpty) {
        return const Left(AuthFailure('Registration failed: No user data received'));
      }
      
      final authResponse = AuthResponse(
        user: user,
        expires: null,
      );
      
      return Right(authResponse);
    } on AppException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (e) {
      final errorMessage = e.toString();
      if (errorMessage.contains('Connection refused') || 
          errorMessage.contains('Failed host lookup') ||
          errorMessage.contains('SocketException')) {
        return Left(NetworkFailure('Cannot connect to server. Please check your internet connection.'));
      }
      return Left(UnknownFailure('An unexpected error occurred: ${errorMessage}'));
    }
  }
  
  /// Send OTP for email verification
  FutureResult<void> sendOTP({
    required String email,
    String type = 'REGISTRATION',
  }) async {
    try {
      await _apiClient.post(
        '/send-otp',
        data: {
          'email': email,
          'type': type,
        },
      );
      
      return const Right(null);
    } on AppException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (e) {
      return Left(UnknownFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }
  
  /// Verify OTP
  FutureResult<void> verifyOTP({
    required String email,
    required String otp,
    String type = 'REGISTRATION',
  }) async {
    try {
      await _apiClient.post(
        '/verify-otp',
        data: {
          'email': email,
          'otp': otp,
          'type': type,
        },
      );
      
      return const Right(null);
    } on AppException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (e) {
      return Left(UnknownFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }
  
  /// Forgot password - request reset link
  FutureResult<void> forgotPassword({
    required String email,
  }) async {
    try {
      await _apiClient.post(
        '/send-otp',
        data: {
          'email': email,
          'type': 'PASSWORD_RESET',
        },
      );
      
      return const Right(null);
    } on AppException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (e) {
      final errorMessage = e.toString();
      if (errorMessage.contains('Connection refused') || 
          errorMessage.contains('Failed host lookup') ||
          errorMessage.contains('SocketException')) {
        return Left(NetworkFailure('Cannot connect to server. Please check your internet connection.'));
      }
      return Left(UnknownFailure('An unexpected error occurred: ${errorMessage}'));
    }
  }
  
  /// Get current session
  FutureResult<AuthResponse> getSession() async {
    try {
      final response = await _apiClient.get('/session');
      
      if (response.data == null || (response.data as Map).isEmpty) {
        return const Left(AuthFailure('No active session'));
      }
      
      final authResponse = AuthResponse.fromJson(response.data as Map<String, dynamic>);
      return Right(authResponse);
    } on AppException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (e) {
      return Left(UnknownFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }
  
  /// Logout
  FutureResult<void> logout() async {
    try {
      await _apiClient.post('/signout');
      return const Right(null);
    } on AppException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (e) {
      return Left(UnknownFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }
  
  /// Map exceptions to failures
  Failure _mapExceptionToFailure(AppException exception) {
    if (exception is AuthException) {
      return AuthFailure(exception.message);
    } else if (exception is NetworkException) {
      return NetworkFailure(exception.message);
    } else if (exception is ServerException) {
      return ServerFailure(exception.message, statusCode: exception.statusCode);
    } else {
      return UnknownFailure(exception.message);
    }
  }
}

