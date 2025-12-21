import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

/// Local storage using SharedPreferences
class LocalStorage {
  final SharedPreferences _prefs;
  
  LocalStorage(this._prefs);
  
  // Auth tokens
  Future<bool> saveAuthToken(String token) async {
    return await _prefs.setString(AppConstants.authTokenKey, token);
  }
  
  String? getAuthToken() {
    return _prefs.getString(AppConstants.authTokenKey);
  }
  
  Future<bool> saveRefreshToken(String token) async {
    return await _prefs.setString(AppConstants.refreshTokenKey, token);
  }
  
  String? getRefreshToken() {
    return _prefs.getString(AppConstants.refreshTokenKey);
  }
  
  Future<bool> saveUserId(String userId) async {
    return await _prefs.setString(AppConstants.userIdKey, userId);
  }
  
  String? getUserId() {
    return _prefs.getString(AppConstants.userIdKey);
  }
  
  // Onboarding
  Future<bool> setOnboardingCompleted(bool completed) async {
    return await _prefs.setBool(AppConstants.isOnboardingCompletedKey, completed);
  }
  
  bool isOnboardingCompleted() {
    return _prefs.getBool(AppConstants.isOnboardingCompletedKey) ?? false;
  }
  
  // Generic methods
  Future<bool> saveString(String key, String value) async {
    return await _prefs.setString(key, value);
  }
  
  String? getString(String key) {
    return _prefs.getString(key);
  }
  
  Future<bool> saveBool(String key, bool value) async {
    return await _prefs.setBool(key, value);
  }
  
  bool? getBool(String key) {
    return _prefs.getBool(key);
  }
  
  Future<bool> saveInt(String key, int value) async {
    return await _prefs.setInt(key, value);
  }
  
  int? getInt(String key) {
    return _prefs.getInt(key);
  }
  
  Future<bool> remove(String key) async {
    return await _prefs.remove(key);
  }
  
  Future<bool> clear() async {
    return await _prefs.clear();
  }
  
  // Clear auth data
  Future<bool> clearAuthData() async {
    final results = await Future.wait([
      remove(AppConstants.authTokenKey),
      remove(AppConstants.refreshTokenKey),
      remove(AppConstants.userIdKey),
      remove('cached_user'), // Clear cached user for session-based auth
    ]);
    return results.every((result) => result);
  }
}


