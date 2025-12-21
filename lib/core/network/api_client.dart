import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../constants/app_constants.dart';
import '../error/exceptions.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';

/// API Client for Learning Platform
class ApiClient {
  late final Dio _dio;
  
  ApiClient({
    required String baseUrl,
    String? authToken,
    List<Interceptor>? additionalInterceptors,
  }) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: AppConstants.connectTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        sendTimeout: AppConstants.sendTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    
    // Add interceptors
    _dio.interceptors.addAll([
      if (authToken != null) AuthInterceptor(authToken),
      ErrorInterceptor(),
      if (additionalInterceptors != null) ...additionalInterceptors,
      // Pretty logger for debugging (only in debug mode)
      if (const bool.fromEnvironment('dart.vm.product') == false)
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
        ),
    ]);
  }
  
  /// Update auth token
  void updateAuthToken(String? token) {
    final authInterceptor = _dio.interceptors
        .whereType<AuthInterceptor>()
        .firstOrNull;
    
    if (authInterceptor != null) {
      _dio.interceptors.remove(authInterceptor);
    }
    
    if (token != null) {
      _dio.interceptors.insert(0, AuthInterceptor(token));
    }
  }
  
  /// GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }
  
  /// POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }
  
  /// PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }
  
  /// DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }
  
  /// Handle Dio errors and convert to app exceptions
  AppException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException('Connection timeout. Please check your internet connection.');
      
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final responseData = error.response?.data;
        
        // Extract error message from HUGE API format
        String message = 'Server error occurred';
        if (responseData is Map) {
          message = responseData['error'] as String? ?? 
                   responseData['message'] as String? ?? 
                   responseData['error'] as String? ??
                   error.response?.statusMessage ?? 
                   'Server error occurred';
        } else if (responseData is String) {
          message = responseData;
        }
        
        // Handle specific error codes
        if (statusCode == 401) {
          return AuthException(message);
        } else if (statusCode == 400) {
          return ValidationException(message);
        } else if (statusCode == 409) {
          return AuthException(message);
        }
        
        return ServerException(message, statusCode: statusCode);
      
      case DioExceptionType.cancel:
        return NetworkException('Request was cancelled');
      
      case DioExceptionType.connectionError:
        if (error.message?.contains('Connection refused') == true ||
            error.message?.contains('Failed host lookup') == true ||
            error.message?.contains('Network is unreachable') == true) {
          return NetworkException('Cannot connect to server. Please check your internet connection.');
        }
        return NetworkException('Connection error. Please check your internet connection.');
      
      case DioExceptionType.unknown:
      default:
        if (error.message?.contains('SocketException') == true ||
            error.message?.contains('Connection refused') == true) {
          return NetworkException('Cannot connect to server. Please check your internet connection.');
        }
        if (error.message?.contains('Failed host lookup') == true) {
          return NetworkException('Cannot reach server. Please check your internet connection.');
        }
        return NetworkException(error.message ?? 'An unexpected error occurred');
    }
  }
}


