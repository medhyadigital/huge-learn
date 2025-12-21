import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../storage/local_storage.dart';
import 'token_manager.dart';
import 'token_refresh_manager.dart';

/// Auth guard for protecting routes
class AuthGuard {
  final LocalStorage _localStorage;
  final TokenManager _tokenManager;
  final TokenRefreshManager _tokenRefreshManager;
  
  AuthGuard(
    this._localStorage,
    this._tokenManager,
    this._tokenRefreshManager,
  );
  
  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = _localStorage.getAuthToken();
    if (token == null) return false;
    
    final metadata = _tokenManager.detectTokenType(token);
    if (metadata == null) return false;
    
    // If token is expired, try to refresh
    if (metadata.isExpired) {
      return await _tokenRefreshManager.refreshToken();
    }
    
    return true;
  }
  
  /// Get redirect location for unauthenticated users
  String getRedirectLocation() {
    return '/login';
  }
}

/// GoRouter redirect handler for auth protection
String? authGuardRedirect(
  BuildContext context,
  GoRouterState state,
  AuthGuard authGuard,
) {
  // This is a sync function, so we can't await the async check
  // We'll use a simple token existence check
  final token = authGuard._localStorage.getAuthToken();
  final isLoggedIn = token != null && token.isNotEmpty;
  
  final isLoginPage = state.matchedLocation == '/login';
  
  // If not logged in and not on login page, redirect to login
  if (!isLoggedIn && !isLoginPage) {
    return '/login';
  }
  
  // If logged in and on login page, redirect to home
  if (isLoggedIn && isLoginPage) {
    return '/home';
  }
  
  // No redirect needed
  return null;
}



