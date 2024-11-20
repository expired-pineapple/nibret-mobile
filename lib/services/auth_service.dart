import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:nibret/models/user_model.dart';

class AuthService {
  final String baseUrl = 'https://nibret-backend-1.onrender.com';
  final _storage = const FlutterSecureStorage();
  static const String _tokenKey = 'access';
  static const String _userKey = 'user';

  final http.Client _client = http.Client();
  static const Duration timeoutDuration = Duration(seconds: 30);
  // Token management methods
  Future<void> saveToken(String token) async {
    print(token);
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
    print("here");
    await _storage.write(key: _userKey, value: json.encode(userData));
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
      // Get the token from secure storage
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
        print(response.body);
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
      print(e);
      throw Exception('Login failed: $e');
    }
  }

  Future<Map<String, dynamic>> updateUser(
      String email, String firstName, String lasName, String phone) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/accounts/user/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'first_name': firstName,
          'last_name': lasName,
          'email': email,
          'phone': phone
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        await saveUserData(responseData);

        return responseData;
      } else {
        throw Exception('Failed to update user: ${response.body}');
      }
    } catch (e) {
      throw Exception('Update failed: $e');
    }
  }

  Future<Map<String, dynamic>> loginWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) throw Exception('Google sign in cancelled');

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      print(json.encode({
        'access_token': googleAuth.accessToken,
        'id_token': googleAuth.idToken,
      }));

      final response = await http.post(
        Uri.parse('$baseUrl/accounts/google/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'access_token': googleAuth.accessToken,
          'id_token': googleAuth.idToken,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // Save token and user data
        await saveToken(responseData['access']);
        await saveUserData(responseData['user']);

        return responseData;
      } else {
        throw Exception('Failed to login with Google: ${response.body}');
      }
    } catch (e) {
      throw Exception('Google login failed: $e');
    }
  }

  // Logout method
  Future<void> logout() async {
    try {
      final token = await getToken();
      if (token != null) {
        // Optional: Call logout endpoint if your backend requires it
        await http.post(
          Uri.parse('$baseUrl/accounts/logout'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );
      }
    } catch (e) {
      print('Logout from server failed: $e');
    } finally {
      // Clear local storage regardless of server response
      await deleteToken();
      await deleteUserData();
      await GoogleSignIn()
          .signOut(); // Sign out from Google if using Google Sign In
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  // Get authenticated http client
  Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }
}
