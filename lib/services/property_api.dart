// services/api_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import '../models/property.dart';

class ApiService {
  static const String baseUrl =
      'https://nibret-vercel-django.vercel.app/properties';
  static const int itemsPerPage = 10;

  final dio = Dio();
  Future<Map<String, dynamic>> getProperties(
      {String? next, String? searchQuery, String? category}) async {
    try {
      final String uri;
      final queryParameters = {
        'limit': '10',
        if (searchQuery != "") 'search': searchQuery,
        if (category != null && category != "All") 'type': category
      };
      if (next != null) {
        uri = next;
      } else {
        uri = baseUrl;
      }
      final response = await dio.get(uri, queryParameters: queryParameters);

      if (response.statusCode == 200) {
        final data = response.data;

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

  Future<List<Property>> searchProperties(filters) async {
    try {
      final response =
          await dio.post('$baseUrl/search/', data: json.encode(filters));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.data);
        return data.map((json) => Property.fromJson(json)).toList();
      } else {
        throw HttpException(
            'Failed to load properties. Status: ${response.statusCode}');
      }
    } on SocketException catch (e) {
      throw HttpException(
          'Network error: Please check your internet connection. ${e.message}');
    } on TimeoutException {
      throw const HttpException('Request timed out. Please try again.');
    } catch (e) {
      throw HttpException('Error parsing properties: $e');
    }
  }

  Future<Property> getProperty(String id) async {
    try {
      final response = await dio.get('$baseUrl/$id/');
      print(response.data);

      if (response.statusCode == 200) {
        final jsonData = response.data;

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
    dio.close();
  }
}
