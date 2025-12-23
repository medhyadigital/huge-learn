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
    // Handle different response formats
    Map<String, dynamic> userData;
    
    if (json.containsKey('user')) {
      userData = json['user'] as Map<String, dynamic>;
    } else if (json.containsKey('id') || json.containsKey('email')) {
      // Direct user object
      userData = json;
    } else {
      userData = {};
    }
    
    return AuthResponse(
      user: userData,
      expires: json['expires'] as String?,
    );
  }
  
  String get userId => user['id']?.toString() ?? '';
  
  String? get accessToken => user['access_token'] as String?;
  String? get refreshToken => user['refresh_token'] as String?;
  String? get sessionId => user['sessionId'] as String?;
}

/// Service for HUGE Foundations User Auth integration
class AuthService {
  final ApiClient _apiClient;
  
  AuthService(this._apiClient);
  
  /// Login with email and password
  /// 
  /// Uses /api/auth/callback/credentials endpoint (was working before)
  /// Only falls back to other endpoints if NextAuth specifically blocks it
  FutureResult<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final loginData = {
      'email': email,
      'password': password,
    };
    
    // Primary endpoint: /api/auth/callback/credentials (was working before)
    try {
      final response = await _apiClient.post(
        '/callback/credentials',
        data: loginData,
      );
      
      if (response.data != null && (response.data as Map).isNotEmpty) {
        final responseData = response.data as Map<String, dynamic>;
        
        if (responseData.containsKey('error')) {
          final errorMessage = responseData['error'] as String? ?? 
                              responseData['message'] as String? ?? 
                              'Login failed';
          // Check if it's specifically the NextAuth blocking error
          if (errorMessage.toLowerCase().contains('http post is not supported') ||
              errorMessage.toLowerCase().contains('this action with http post')) {
            // Only then try fallback endpoints
            return await _tryFallbackEndpoints(loginData);
          }
          return Left(AuthFailure(errorMessage));
        }
        
        final authResponse = AuthResponse.fromJson(responseData);
        return Right(authResponse);
      }
      
      return const Left(AuthFailure('Invalid response from server'));
    } on ServerException catch (e) {
      // Check if it's the specific NextAuth blocking error
      final errorMessage = e.message.toLowerCase();
      if (errorMessage.contains('http post is not supported') ||
          errorMessage.contains('this action with http post') ||
          (errorMessage.contains('not supported') && errorMessage.contains('nextauth'))) {
        // Only then try fallback endpoints
        return await _tryFallbackEndpoints(loginData);
      }
      // For other server errors, return the actual error message
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on AppException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (e) {
      final errorMessage = e.toString();
      if (errorMessage.contains('Connection refused') || 
          errorMessage.contains('Failed host lookup') ||
          errorMessage.contains('SocketException') ||
          errorMessage.contains('Connection timed out')) {
        return Left(NetworkFailure('Cannot connect to server. Please check your internet connection and try again.'));
      }
      return Left(UnknownFailure('Login failed: ${errorMessage}'));
    }
  }
  
  /// Try fallback endpoints if NextAuth blocks the primary endpoint
  FutureResult<AuthResponse> _tryFallbackEndpoints(Map<String, dynamic> loginData) async {
    // Try /api/auth/login as fallback
    try {
      final response = await _apiClient.post(
        '/login',
        data: loginData,
      );
      
      if (response.data != null && (response.data as Map).isNotEmpty) {
        final responseData = response.data as Map<String, dynamic>;
        
        if (responseData.containsKey('error')) {
          // Continue to next fallback
        } else {
          // Handle JWT token format or NextAuth format
          if (responseData.containsKey('user')) {
            final authResponse = AuthResponse.fromJson(responseData);
            return Right(authResponse);
          } else if (responseData.containsKey('access_token')) {
            // JWT token format - convert to NextAuth format
            final user = responseData['user'] as Map<String, dynamic>? ?? 
                        {'id': responseData['id'], 'email': loginData['email']};
            final authResponse = AuthResponse(user: user, expires: null);
            return Right(authResponse);
          }
        }
      }
    } catch (e) {
      // Fallback endpoint doesn't exist
    }
    
    return const Left(AuthFailure(
      'Mobile authentication not supported. The backend needs to enable mobile login. Please contact support.'
    ));
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

