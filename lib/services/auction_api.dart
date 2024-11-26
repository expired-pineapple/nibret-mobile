// services/api_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:nibret/models/auction.dart';

class ApiService {
  static const String baseUrl = 'https://nibret-vercel-django.vercel.app';

  // Create a custom http client with timeout
  final http.Client _client = http.Client();
  static const Duration timeoutDuration = Duration(seconds: 30);

  Future<List<Auction>> getProperties() async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/auctions/'))
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        print(response.body);
        final List<dynamic> jsonList = json.decode(response.body);

        final proprty = jsonList.map((json) => Auction.fromJson(json)).toList();
        for (var property in proprty) {
          print('Auction: ${property.name}');
          for (var picture in property.pictures) {
            print('Image URL: ${picture.imageUrl}');
          }
        }
        return jsonList.map((json) => Auction.fromJson(json)).toList();
      } else {
        throw HttpException(
            'Failed to load properties. Status: ${response.statusCode}');
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

  Future<Auction> getAuction(String id) async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/auctions/$id'))
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        print(response.body);
        final jsonData = json.decode(response.body);

        final auction = Auction.fromJson(jsonData);

        return auction;
      } else {
        throw HttpException(
            'Failed to load properties. Status: ${response.statusCode}');
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
