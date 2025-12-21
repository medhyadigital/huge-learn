import 'dart:async';
import 'package:dio/dio.dart';
import '../storage/local_storage.dart';
import 'token_manager.dart';
import 'auth_service.dart';

/// Token refresh manager for silent token refresh
class TokenRefreshManager {
  final AuthService _authService;
  final LocalStorage _localStorage;
  final TokenManager _tokenManager;
  
  bool _isRefreshing = false;
  Completer<bool>? _refreshCompleter;
  Timer? _autoRefreshTimer;
  
  TokenRefreshManager(
    this._authService,
    this._localStorage,
    this._tokenManager,
  );
  
  /// Initialize auto-refresh timer
  void initAutoRefresh() {
    _autoRefreshTimer?.cancel();
    
    // Check every 30 seconds if token needs refresh
    _autoRefreshTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _checkAndRefreshToken(),
    );
  }
  
  /// Stop auto-refresh timer
  void stopAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = null;
  }
  
  /// Check and refresh token if needed
  Future<void> _checkAndRefreshToken() async {
    if (_tokenManager.needsRefresh()) {
      await refreshToken();
    }
  }
  
  /// Refresh token (silent refresh)
  Future<bool> refreshToken() async {
    // If already refreshing, wait for the current refresh to complete
    if (_isRefreshing && _refreshCompleter != null) {
      return await _refreshCompleter!.future;
    }
    
    _isRefreshing = true;
    _refreshCompleter = Completer<bool>();
    
    try {
      final refreshToken = _localStorage.getRefreshToken();
      
      if (refreshToken == null) {
        _refreshCompleter!.complete(false);
        return false;
      }
      
      final result = await _authService.refreshToken(refreshToken);
      
      final success = result.fold(
        (failure) => false,
        (authResponse) {
          // Update tokens in local storage
          _localStorage.saveAuthToken(authResponse.accessToken);
          _localStorage.saveRefreshToken(authResponse.refreshToken);
          
          // Clear cached token metadata
          _tokenManager.clearCache();
          
          return true;
        },
      );
      
      _refreshCompleter!.complete(success);
      return success;
    } catch (e) {
      _refreshCompleter!.complete(false);
      return false;
    } finally {
      _isRefreshing = false;
      _refreshCompleter = null;
    }
  }
  
  /// Force refresh token
  Future<bool> forceRefresh() async {
    _isRefreshing = false;
    _refreshCompleter = null;
    return await refreshToken();
  }
  
  /// Dispose resources
  void dispose() {
    stopAutoRefresh();
    _refreshCompleter?.complete(false);
    _refreshCompleter = null;
  }
}

/// Dio interceptor for automatic token refresh on 401 errors
class TokenRefreshInterceptor extends Interceptor {
  final TokenRefreshManager _tokenRefreshManager;
  final LocalStorage _localStorage;
  
  TokenRefreshInterceptor(
    this._tokenRefreshManager,
    this._localStorage,
  );
  
  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Handle 401 Unauthorized
    if (err.response?.statusCode == 401) {
      final refreshSuccess = await _tokenRefreshManager.refreshToken();
      
      if (refreshSuccess) {
        // Retry the original request with new token
        final newToken = _localStorage.getAuthToken();
        if (newToken != null) {
          err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
          
          try {
            final response = await Dio().fetch(err.requestOptions);
            return handler.resolve(response);
          } catch (e) {
            return handler.next(err);
          }
        }
      }
    }
    
    return handler.next(err);
  }
}

