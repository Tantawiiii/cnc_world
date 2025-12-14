import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _keyToken = 'auth_token';
  static const String _keyUserData = 'user_data';
  static const String _keyUserType = 'user_type';
  static const String _keyLanguage = 'app_language';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  // Token methods
  Future<void> saveToken(String token) async {
    await _prefs.setString(_keyToken, token);
  }

  String? getToken() {
    return _prefs.getString(_keyToken);
  }

  Future<void> removeToken() async {
    await _prefs.remove(_keyToken);
  }

  // User data methods
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    final jsonString = jsonEncode(userData);
    await _prefs.setString(_keyUserData, jsonString);
  }

  Map<String, dynamic>? getUserData() {
    final jsonString = _prefs.getString(_keyUserData);
    if (jsonString == null) return null;
    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  Future<void> removeUserData() async {
    await _prefs.remove(_keyUserData);
  }

  // User type methods
  Future<void> saveUserType(String type) async {
    await _prefs.setString(_keyUserType, type);
  }

  String? getUserType() {
    return _prefs.getString(_keyUserType);
  }

  Future<void> removeUserType() async {
    await _prefs.remove(_keyUserType);
  }

  // Language methods
  Future<void> saveLanguage(String languageCode) async {
    await _prefs.setString(_keyLanguage, languageCode);
  }

  String? getLanguage() {
    return _prefs.getString(_keyLanguage);
  }

  Future<void> removeLanguage() async {
    await _prefs.remove(_keyLanguage);
  }

  // Clear all auth data
  Future<void> clearAll() async {
    await removeToken();
    await removeUserData();
    await removeUserType();
    // Note: We don't clear language preference on logout
  }
}
