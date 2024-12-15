// services/api_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:nibret/models/auction.dart';

class ApiService {
  static const String baseUrl = 'https://nibret-vercel-django.vercel.app';
  static const int itemsPerPage = 10;
  final http.Client _client = http.Client();

  static const Duration timeoutDuration = Duration(seconds: 30);

  Future<Map<String, dynamic>> getAuctions(
      {String? next, String? searchQuery, String? category}) async {
    try {
      final Uri uri;
      if (next != null) {
        uri = Uri.parse(next);
      } else {
        final queryParameters = {
          'limit': '10',
          if (searchQuery != "") 'search': searchQuery,
          if (category != null) 'type': category
        };
        uri = Uri.parse('$baseUrl/auctions/').replace(
          queryParameters: queryParameters,
        );
      }

      final response = await _client.get(uri).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data;
      } else {
        throw HttpException(
            'Failed to load Auctions. Status: ${response.statusCode}');
      }
    } on SocketException catch (e) {
      throw HttpException(
          'Network error: Please check your internet connection. ${e.message}');
    } on TimeoutException {
      throw const HttpException('Request timed out. Please try again.');
    } on HttpException catch (e) {
      throw HttpException(e.message);
    } catch (e) {
      throw HttpException(
          'Network error: Please check your internet connection. $e');
    }
  }

  Future<Auction> getAuction(String id) async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/auctions/$id'))
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        final auction = Auction.fromJson(jsonData);

        return auction;
      } else {
        throw HttpException(
            'Failed to load Auctions. Status: ${response.statusCode}');
      }
    } on SocketException catch (e) {
      throw HttpException(
          'Network error: Please check your internet connection. ${e.message}');
    } on TimeoutException {
      throw const HttpException('Request timed out. Please try again.');
    } on HttpException catch (e) {
      throw HttpException(e.message);
    } catch (e) {
      throw HttpException('An unexpected error occurred listing here: $e');
    }
  }

// Flutter/Dart client code
  Future<void> toggleWishlist({
    required String itemId,
    required bool isWishlisted,
    required bool isProperty, // true for property, false for auction
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/wishlist/add_items'),
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
