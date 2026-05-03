import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _keyToken = 'auth_token';
  static const String _keyFirebaseCustomToken = 'firebase_custom_token';
  static const String _keyUserData = 'user_data';
  static const String _keyUserType = 'user_type';
  static const String _keyLanguage = 'app_language';
  static const String _keyNearestSellerId = 'nearest_seller_id';
  static const String _keyNearestSellerName = 'nearest_seller_name';
  static const String _keyNearestSellerKm = 'nearest_seller_km';

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

  Future<void> saveFirebaseCustomToken(String token) async {
    await _prefs.setString(_keyFirebaseCustomToken, token);
  }

  String? getFirebaseCustomToken() {
    return _prefs.getString(_keyFirebaseCustomToken);
  }

  Future<void> removeFirebaseCustomToken() async {
    await _prefs.remove(_keyFirebaseCustomToken);
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
    await removeFirebaseCustomToken();
    await removeUserData();
    await removeUserType();
    await clearNearestSeller();
    // Note: We don't clear language preference on logout
  }

  Future<void> saveNearestSeller({
    required int id,
    required String name,
    required double distanceKm,
  }) async {
    await _prefs.setInt(_keyNearestSellerId, id);
    await _prefs.setString(_keyNearestSellerName, name);
    await _prefs.setDouble(_keyNearestSellerKm, distanceKm);
  }

  ({int id, String name, double distanceKm})? getNearestSeller() {
    final id = _prefs.getInt(_keyNearestSellerId);
    final name = _prefs.getString(_keyNearestSellerName);
    final km = _prefs.getDouble(_keyNearestSellerKm);
    if (id == null || name == null || km == null) return null;
    return (id: id, name: name, distanceKm: km);
  }

  Future<void> clearNearestSeller() async {
    await _prefs.remove(_keyNearestSellerId);
    await _prefs.remove(_keyNearestSellerName);
    await _prefs.remove(_keyNearestSellerKm);
  }
}
