import 'dart:convert';
import 'package:dartz/dartz.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/error/failures.dart';
import '../models/user_model.dart';

/// Local data source for authentication
abstract class AuthLocalDataSource {
  FutureResult<void> cacheUser(UserModel user);
  FutureResult<UserModel?> getCachedUser();
  FutureResult<void> cacheAuthTokens(String accessToken, String refreshToken);
  FutureResult<String?> getAccessToken();
  FutureResult<String?> getRefreshToken();
  FutureResult<void> clearAuthData();
}

/// Implementation of AuthLocalDataSource
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final LocalStorage _localStorage;
  
  AuthLocalDataSourceImpl(this._localStorage);
  
  @override
  FutureResult<void> cacheUser(UserModel user) async {
    try {
      final userJson = user.toJson();
      final userJsonString = jsonEncode(userJson);
      await _localStorage.saveString('cached_user', userJsonString);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to cache user: ${e.toString()}'));
    }
  }
  
  @override
  FutureResult<UserModel?> getCachedUser() async {
    try {
      final userJsonString = _localStorage.getString('cached_user');
      if (userJsonString == null) {
        return const Right(null);
      }
      final userJson = jsonDecode(userJsonString) as Map<String, dynamic>;
      final userModel = UserModel.fromJson(userJson);
      return Right(userModel);
    } catch (e) {
      return Left(CacheFailure('Failed to get cached user: ${e.toString()}'));
    }
  }
  
  @override
  FutureResult<void> cacheAuthTokens(String accessToken, String refreshToken) async {
    // Session-based auth doesn't use tokens
    // This method is kept for compatibility but does nothing
    return const Right(null);
  }
  
  @override
  FutureResult<String?> getAccessToken() async {
    // Session-based auth doesn't use tokens
    // Return null to indicate no token-based auth
    return const Right(null);
  }
  
  @override
  FutureResult<String?> getRefreshToken() async {
    // Session-based auth doesn't use tokens
    // Return null to indicate no token-based auth
    return const Right(null);
  }
  
  @override
  FutureResult<void> clearAuthData() async {
    try {
      await _localStorage.clearAuthData();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to clear auth data: ${e.toString()}'));
    }
  }
}

