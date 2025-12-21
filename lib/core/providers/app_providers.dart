import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../network/api_client.dart';
import '../cache/cache_manager.dart';
import '../constants/app_constants.dart';
import '../auth/auth_service.dart';

/// Dio provider
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: AppConstants.learningPlatformBaseUrl,
    connectTimeout: AppConstants.connectTimeout,
    receiveTimeout: AppConstants.receiveTimeout,
    sendTimeout: AppConstants.sendTimeout,
  ));
  
  return dio;
});

/// API Client provider for Learning Platform
final learningApiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(
    baseUrl: AppConstants.learningPlatformBaseUrl,
  );
});

/// API Client provider for Gita API
final gitaApiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(
    baseUrl: AppConstants.gitaApiBaseUrl,
  );
});

/// Cache Manager provider
final cacheManagerProvider = Provider<CacheManager>((ref) {
  return CacheManager();
});

/// Hive box providers
final courseBoxProvider = Provider<Box>((ref) {
  return Hive.box('courses');
});

final progressBoxProvider = Provider<Box>((ref) {
  return Hive.box('progress');
});

/// API Client provider for HUGE Foundations Auth
final hugeAuthApiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(
    baseUrl: AppConstants.hugeFoundationsAuthBaseUrl,
  );
});

/// Auth Service provider
final authServiceProvider = Provider<AuthService>((ref) {
  final apiClient = ref.watch(hugeAuthApiClientProvider);
  return AuthService(apiClient);
});




