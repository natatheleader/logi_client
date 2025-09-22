import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class StorageService {
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  // Onboarding
  Future<bool> setOnboardingCompleted(bool completed) async {
    return await _prefs.setBool(AppConstants.isOnboardingCompletedKey, completed);
  }

  bool isOnboardingCompleted() {
    return _prefs.getBool(AppConstants.isOnboardingCompletedKey) ?? false;
  }

  // First Launch
  Future<bool> setFirstLaunch(bool isFirst) async {
    return await _prefs.setBool(AppConstants.isFirstLaunchKey, isFirst);
  }

  bool isFirstLaunch() {
    return _prefs.getBool(AppConstants.isFirstLaunchKey) ?? true;
  }

  // Authentication
  Future<bool> setAccessToken(String token) async {
    return await _prefs.setString(AppConstants.accessTokenKey, token);
  }

  String? getAccessToken() {
    return _prefs.getString(AppConstants.accessTokenKey);
  }

  Future<bool> setRefreshToken(String token) async {
    return await _prefs.setString(AppConstants.refreshTokenKey, token);
  }

  String? getRefreshToken() {
    return _prefs.getString(AppConstants.refreshTokenKey);
  }

  Future<bool> setUserData(String userData) async {
    return await _prefs.setString(AppConstants.userDataKey, userData);
  }

  String? getUserData() {
    return _prefs.getString(AppConstants.userDataKey);
  }

  // Clear all data (logout)
  Future<bool> clearAll() async {
    return await _prefs.clear();
  }

  // Clear only auth data
  Future<bool> clearAuthData() async {
    await _prefs.remove(AppConstants.accessTokenKey);
    await _prefs.remove(AppConstants.refreshTokenKey);
    await _prefs.remove(AppConstants.userDataKey);
    return true;
  }

  // Check if user is logged in
  bool isLoggedIn() {
    final token = getAccessToken();
    return token != null && token.isNotEmpty;
  }
}