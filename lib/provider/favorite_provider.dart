// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';

class FavoriteProvider extends ChangeNotifier {
  List<String> _favoriteIds = [];
  final String baseUrl = 'https://nibret-backend-1.onrender.com/wishlist';

  List<String> get favorites => _favoriteIds;

  FavoriteProvider() {
    loadFavorite();
  }

  // Toggle favorites states
  void toggleFavorite(String placeId) async {
    if (_favoriteIds.contains(placeId)) {
      _favoriteIds.remove(placeId);
      await _removeFavorite(placeId);
    } else {
      _favoriteIds.add(placeId);
      await _addFavorites(placeId);
    }
    notifyListeners();
  }

  // Check if a place is favorited
  bool isExist(String placeId) {
    return _favoriteIds.contains(placeId);
  }

  // Add favorites items to your backend
  Future<void> _addFavorites(String placeId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/add_items/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'item_id': placeId}),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to add favorite');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  // Remove favorites items from your backend
  Future<void> _removeFavorite(String placeId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/add_items/$placeId'), // Adjust this URL as needed
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to remove favorite');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  // Load favorites items from your backend
  Future<void> loadFavorite() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _favoriteIds = data.map((item) => item['item_id'] as String).toList();
      } else {
        throw Exception('Failed to load favorites');
      }
    } catch (e) {
      print(e.toString());
    }
    notifyListeners();
  }

  // Static method to access the provider from any context
  static FavoriteProvider of(BuildContext context, {bool listen = true}) {
    return Provider.of<FavoriteProvider>(
      context,
      listen: listen,
    );
  }
}
