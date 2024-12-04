import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/property.dart';

class SearchService {
  static const String baseUrl = 'https://nibret-vercel-django.vercel.app';

  Future<List<Property>> searchProperties({
    String? query,
    String? propertyType,
    double? minPrice,
    double? maxPrice,
    int? bedrooms,
    int? bathrooms,
  }) async {
    try {
      final queryParams = {
        if (query != null && query.isNotEmpty) 'search': query,
        if (propertyType != null) 'type': propertyType,
        if (minPrice != null) 'min_price': minPrice.toString(),
        if (maxPrice != null) 'max_price': maxPrice.toString(),
        if (bedrooms != null) 'bedrooms': bedrooms.toString(),
        if (bathrooms != null) 'bathrooms': bathrooms.toString(),
      };

      final uri = Uri.parse('$baseUrl/properties/')
          .replace(queryParameters: queryParams);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Property.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search properties');
      }
    } catch (e) {
      throw Exception('Error searching properties: $e');
    }
  }
}
