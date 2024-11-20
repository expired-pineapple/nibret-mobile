import 'package:flutter/material.dart';
import 'package:nibret/models/user_model.dart';
import 'package:nibret/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  bool _isLoading = false;
  bool _isAuthenticated = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;

  AuthProvider() {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    _isLoading = true;
    notifyListeners();

    try {
      final isLoggedIn = await _authService.isLoggedIn();
      if (isLoggedIn) {
        final userData = await _authService.getUserData();
        if (userData != null) {
          _user = User.fromJson(userData);
          _isAuthenticated = true;
        }
      }
    } catch (e) {
      print('Error initializing auth: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _authService.loginWithEmail(email, password);
      print(response['user']);
      _user = User.fromJson(response['user']);
      print(_user);
      _isAuthenticated = true;
    } catch (e) {
      print(e);
      _isAuthenticated = false;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loginWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _authService.loginWithGoogle();
      _user = User.fromJson(response['user']);
      _isAuthenticated = true;
    } catch (e) {
      _isAuthenticated = false;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.logout();
      _user = null;
      _isAuthenticated = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUserProfile(
      String email, String firstName, String lastName, String phone) async {
    _isLoading = true;
    notifyListeners();

    try {
      final updatedUserData =
          await _authService.updateUser(email, firstName, lastName, phone);
      _user = User.fromJson(updatedUserData);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> getAuthToken() async {
    return await _authService.getToken();
  }
}
