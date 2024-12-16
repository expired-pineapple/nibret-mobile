// tour_api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nibret/services/auth_service.dart';

class TourApiService {
  final String baseUrl = 'https://nibret-vercel-django.vercel.app';

  Future<Map<String, dynamic>> requestTour({
    required String propertyId,
    required DateTime tourDate,
    String? notes,
  }) async {
    try {
      final authService = AuthService();
      final token = await authService.getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/tour/add_items/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'item_id': propertyId,
          'date': tourDate.toIso8601String(),
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Failed to create tour request: $e');
    }
  }
}
