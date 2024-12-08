// services/api_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/property.dart';

class ApiService {
  static const String baseUrl = 'https://nibret-vercel-django.vercel.app';
  static const int itemsPerPage = 10;

  final http.Client _client = http.Client();
  static const Duration timeoutDuration = Duration(seconds: 30);

  Future<Map<String, dynamic>> getProperties(
      {int? offset, String? searchQuery, String? type, String? next}) async {
    try {
      final queryParameters = {
        'offset': offset.toString(),
        'limit': itemsPerPage.toString(),
        if (searchQuery != null && searchQuery.isNotEmpty)
          'search': searchQuery,
      };
      final response = await _client
          .get(Uri.parse('$baseUrl/properties').replace(
            queryParameters: queryParameters,
          ))
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data;
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
      throw HttpException(
          'Network error: Please check your internet connection. $e');
    }
  }

  Future<Property> getProperty(String id) async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/properties/$id'))
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        final property = Property.fromJson(jsonData);

        return property;
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

  void dispose() {
    _client.close();
  }
}
