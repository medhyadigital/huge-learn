import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../network/api_client.dart';
import '../cache/cache_manager.dart';
import '../constants/app_constants.dart';

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



