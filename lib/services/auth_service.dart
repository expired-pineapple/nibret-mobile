import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:nibret/models/user_model.dart';

class AuthService {
  final String baseUrl = 'https://nibret-vercel-django.vercel.app';
  final _storage = const FlutterSecureStorage();
  static const String _tokenKey = 'access';
  static const String _userKey = 'user';

  final http.Client _client = http.Client();
  static const Duration timeoutDuration = Duration(seconds: 30);
  // Token management methods
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  // User data management
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    try {
      await _storage.write(key: _userKey, value: json.encode(userData));
    } catch (e) {
      throw Exception("Failed while saving user data");
    }
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final userStr = await _storage.read(key: _userKey);
    if (userStr != null) {
      return json.decode(userStr);
    }
    return null;
  }

  Future<void> deleteUserData() async {
    await _storage.delete(key: _userKey);
  }

  Future<User> getUser() async {
    try {
      final token = await getToken();

      if (token == null) {
        throw const HttpException('No authentication token found');
      }

      final response = await _client.get(
        Uri.parse('$baseUrl/accounts/user/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final userResponse = User.fromJson(jsonData);
        return userResponse;
      } else if (response.statusCode == 401) {
        throw const HttpException('Unauthorized: Invalid or expired token');
      } else {
        throw HttpException(
            'Failed to load user data. Status: ${response.statusCode}');
      }
    } on SocketException catch (e) {
      throw HttpException(
          'Network error: Please check your internet connection. ${e.message}');
    } on TimeoutException {
      throw const HttpException('Request timed out. Please try again.');
    } on HttpException catch (e) {
      throw HttpException(e.message);
    } catch (e) {
      throw HttpException('An unexpected error occurred: $e');
    }
  }

  Future<Map<String, dynamic>> loginWithEmail(
      String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/accounts/login/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // Save token and user data
        await saveToken(responseData['access']);
        await saveUserData(responseData['user']);

        return responseData;
      } else {
        throw Exception('Failed to login: ${response.body}');
      }
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  Future<User> updateUser(
      String firstName, String lastName, String email, String phone) async {
    try {
      final token = await getToken();

      if (token == null) {
        throw const HttpException('No authentication token found');
      }

      final response = await http.put(
        Uri.parse('$baseUrl/accounts/user/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          'phone': phone
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        await saveUserData(responseData);

        final user = User.fromJson(responseData);
        return user;
      } else {
        throw Exception('Failed to update user: ${response.body}');
      }
    } catch (e) {
      throw Exception('Update failed: $e');
    }
  }

  Future<void> logout() async {
    try {
      final token = await getToken();
      print(token);
      if (token != null) {
        await http.post(
          Uri.parse('$baseUrl/accounts/logout'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );
      }
    } catch (e) {
      throw const HttpException("Logout failed");
    } finally {
      await deleteToken();
      await deleteUserData();
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();

    return token != null;
  }

  Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }
}
