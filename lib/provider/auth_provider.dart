import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  Future<void> loadUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson != null) {
      _user = User.fromJson(json.decode(userJson));
      notifyListeners();
    }
  }

  Future<void> login(User user) async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', json.encode(user.toJson()));
      _user = user;
    } catch (e) {
      print('Login error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user');
      _user = null;
    } catch (e) {
      print('Logout error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }
}
