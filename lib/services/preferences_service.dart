import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PreferencesService {
  static const String _keyFirstTime = 'first_time';
  static const String _keyUserName = 'user_name';
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyUserPreferences = 'user_preferences';

  // Singleton pattern
  static final PreferencesService _instance = PreferencesService._internal();
  factory PreferencesService() => _instance;
  PreferencesService._internal();

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<bool> isFirstTime() async {
    return _prefs.getBool(_keyFirstTime) ?? true;
  }

  Future<void> setFirstTimeDone() async {
    await _prefs.setBool(_keyFirstTime, false);
  }

  Future<void> setLoggedIn(bool value) async {
    await _prefs.setBool(_keyIsLoggedIn, value);
  }

  Future<bool> isLoggedIn() async {
    return _prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  Future<void> setUserName(String name) async {
    await _prefs.setString(_keyUserName, name);
  }

  Future<void> setThemeMode(String mode) async {
    await _prefs.setString(_keyThemeMode, mode);
  }

  Future<String> getThemeMode() async {
    return _prefs.getString(_keyThemeMode) ?? 'system';
  }

  Future<void> saveUserPreferences(Map<String, dynamic> preferences) async {
    final jsonString = json.encode(preferences);
    await _prefs.setString(_keyUserPreferences, jsonString);
  }

  Future<Map<String, dynamic>?> getUserPreferences() async {
    final jsonString = _prefs.getString(_keyUserPreferences);
    if (jsonString != null) {
      return json.decode(jsonString) as Map<String, dynamic>;
    }
    return null;
  }

  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
