import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:nibret/models/wishlist_model.dart';
import 'package:nibret/services/auth_service.dart';

class WishListsApiService {
  static const String baseUrl = 'https://nibret-vercel-django.vercel.app';
  final http.Client _client = http.Client();
  static const Duration timeoutDuration = Duration(seconds: 30);

  Future<WishlistItem> getWishlistedItems() async {
    try {
      final authService = AuthService();
      final token = await authService.getToken();
      var headers = {
        'Content-Type': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await _client
          .get(Uri.parse('$baseUrl/wishlist/'), headers: headers)
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);

        final wishlist = WishlistItem.fromJson(responseBody[0]);
        return wishlist;
      } else {
        throw const HttpException('Failed to load properties');
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

  Future<void> toggleWishlist(String propertyId, bool isWishlisted) async {
    try {
      final authService = AuthService();
      final token = await authService.getToken();
      final response = await _client
          .post(
            Uri.parse('$baseUrl/wishlist/add_items/'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type':
                  'application/json', // Ensure the content type is set
            },
            body: json
                .encode({"item_id": propertyId, 'is_wishlisted': isWishlisted}),
          )
          .timeout(timeoutDuration);

      if (response.statusCode != 200) {
        throw const HttpException('Failed to update wishlist.');
      }
    } on SocketException catch (e) {
      throw HttpException(
          'Network error: Please check your internet connection. ${e.message}');
    } on TimeoutException {
      throw const HttpException('Request timed out. Please try again.');
    } on HttpException catch (e) {
      throw HttpException(e.message);
    } catch (e) {
      throw const HttpException('An unexpected error occurred');
    }
  }

  void dispose() {
    _client.close();
  }
}
