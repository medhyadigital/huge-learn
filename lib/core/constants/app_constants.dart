/// Application-wide constants
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'HUGE Learning Platform';
  static const String appVersion = '1.0.0';

  // API Configuration
  // HUGE Foundations Production API
  static const String hugeFoundationsAuthBaseUrl = 'https://hugefoundations.org/api/auth';
  static const String learningPlatformBaseUrl = 'https://hugefoundations.org/api/learning';
  static const String gitaApiBaseUrl = 'http://localhost:3000/api/gita';
  
  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';
  static const String isOnboardingCompletedKey = 'is_onboarding_completed';
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Cache Duration
  static const Duration defaultCacheDuration = Duration(hours: 1);
  static const Duration imageCacheDuration = Duration(days: 7);
}

