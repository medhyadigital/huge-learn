import 'package:dio/dio.dart';

/// Interceptor to handle common errors
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Handle 401 Unauthorized - token expired
    if (err.response?.statusCode == 401) {
      // TODO: Implement token refresh logic
      // For now, just pass through
    }
    
    // Handle 403 Forbidden
    if (err.response?.statusCode == 403) {
      // TODO: Handle forbidden access
    }
    
    // Handle 500 Server Error
    if (err.response?.statusCode == 500) {
      // TODO: Log server errors
    }
    
    handler.next(err);
  }
}




