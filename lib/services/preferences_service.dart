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

  // Initialize SharedPreferences
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // First Time Check Methods
  Future<bool> isFirstTime() async {
    return _prefs.getBool(_keyFirstTime) ?? true;
  }

  Future<void> setFirstTimeDone() async {
    await _prefs.setBool(_keyFirstTime, false);
  }

  // Login Status Methods
  Future<void> setLoggedIn(bool value) async {
    await _prefs.setBool(_keyIsLoggedIn, value);
  }

  Future<bool> isLoggedIn() async {
    // Made async and return Future<bool>
    return _prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  // User Data Methods
  Future<void> setUserName(String name) async {
    await _prefs.setString(_keyUserName, name);
  }

  Future<String?> getUserName() async {
    // Made async and return Future<String?>
    return _prefs.getString(_keyUserName);
  }

  // Theme Preference Methods
  Future<void> setThemeMode(String mode) async {
    await _prefs.setString(_keyThemeMode, mode);
  }

  Future<String> getThemeMode() async {
    // Made async and return Future<String>
    return _prefs.getString(_keyThemeMode) ?? 'system';
  }

  // Complex Data Example (using JSON)
  Future<void> saveUserPreferences(Map<String, dynamic> preferences) async {
    final jsonString = json.encode(preferences);
    await _prefs.setString(_keyUserPreferences, jsonString);
  }

  Future<Map<String, dynamic>?> getUserPreferences() async {
    // Made async and return Future<Map<String, dynamic>?>
    final jsonString = _prefs.getString(_keyUserPreferences);
    if (jsonString != null) {
      return json.decode(jsonString) as Map<String, dynamic>;
    }
    return null;
  }

  // Add clear method for cleaning up preferences
  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
