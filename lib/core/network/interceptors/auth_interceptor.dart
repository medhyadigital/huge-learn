import 'package:dio/dio.dart';

/// Interceptor to add auth token to requests
class AuthInterceptor extends Interceptor {
  final String token;
  
  AuthInterceptor(this.token);
  
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['Authorization'] = 'Bearer $token';
    handler.next(options);
  }
}






