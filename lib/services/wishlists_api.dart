import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class WishlistItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final double discount;
  final bool isSoldOut;
  final bool isStore;
  final String type;
  final DateTime moveInDate;
  bool? isAuction;
  final String imageUrl;

  WishlistItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.discount,
    required this.isSoldOut,
    required this.isStore,
    required this.type,
    required this.moveInDate,
    required this.isAuction,
    required this.imageUrl,
  });

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    return WishlistItem(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      discount: json['discount'].toDouble(),
      isSoldOut: json['sold_out'],
      isStore: json['is_store'],
      type: json['type'],
      moveInDate: DateTime.parse(json['move_in_date']),
      isAuction: json['is_auction'],
      imageUrl: json['pictures'][0]['image_url'],
    );
  }
}

class AuctionItem {
  final String id;
  final String name;
  final String description;
  final double startingBid;
  final DateTime startDate;
  final DateTime endDate;
  final String imageUrl;

  AuctionItem({
    required this.id,
    required this.name,
    required this.description,
    required this.startingBid,
    required this.startDate,
    required this.endDate,
    required this.imageUrl,
  });

  factory AuctionItem.fromJson(Map<String, dynamic> json) {
    return AuctionItem(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      startingBid: json['starting_bid'].toDouble(),
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      imageUrl: json['pictures'][0]['image_url'],
    );
  }
}

class WishlistApiService {
  static const _baseUrl = 'https://nibret-backend-1.onrender.com/wishlist/';
  final http.Client _client = http.Client();
  static const Duration timeoutDuration = Duration(seconds: 30);

  Future<List<WishlistItem>> getWishlistedProperties() async {
    final response = await http.get(Uri.parse(_baseUrl));
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body) as List<dynamic>;
      return jsonData
          .map((item) => WishlistItem.fromJson(item['property'][0]))
          .toList();
    } else {
      throw Exception('Failed to fetch wishlist properties');
    }
  }

  Future<List<AuctionItem>> getWishlistedAuctions() async {
    final response = await http.get(Uri.parse(_baseUrl));
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body) as List<dynamic>;
      return jsonData
          .map((item) => AuctionItem.fromJson(item['auctions'][0]))
          .toList();
    } else {
      throw Exception('Failed to fetch wishlist auctions');
    }
  }

  Future<void> toggleWishlist({
    required String itemId,
    required bool isWishlisted,
    required bool isProperty, // true for property, false for auction
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/wishlist/add_items'),
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
