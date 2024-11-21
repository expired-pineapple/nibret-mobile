import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:nibret/models/wishlist.dart';

class WishlistService {
  final String baseUrl = 'https://nibret-backend-1.onrender.com/wishlist/';
  final http.Client _client = http.Client();
  static const Duration timeoutDuration = Duration(seconds: 30);

  Future<List<WishlistItem>> fetchWishlistData() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List<dynamic>;
      return data.map((item) => WishlistItem.fromJson(item)).toList();
    } else {
      throw Exception('Failed to fetch wishlist data');
    }
  }

  Future<void> toggleWishlist({
    required String itemId,
    required bool isWishlisted,
    required bool isProperty, // true for property, false for auction
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/wishlist/add_items/'),
        body: {
          'item_id': itemId,
          'is_wishlisted': isWishlisted.toString(),
          'is_property': isProperty.toString(),
        },
      ).timeout(timeoutDuration);

      if (response.statusCode != 200) {
        throw HttpException(
            'Failed to update wishlist. Status: ${response.statusCode}');
      }
    } on SocketException catch (e) {
      throw HttpException(
          'Network error: Please check your internet connection. ${e.message}');
    } on TimeoutException {
      throw const HttpException('Request timed out. Please try again.');
    } on HttpException catch (e) {
      throw HttpException(e.message);
    } catch (e) {
      throw HttpException('An unexpected error occurred from api service: $e');
    }
  }

  void dispose() {
    _client.close();
  }
}
