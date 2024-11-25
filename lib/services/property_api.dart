// services/api_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/property.dart';

class ApiService {
  static const String baseUrl = 'https://nibret-backend-1.onrender.com';

  // Create a custom http client with timeout
  final http.Client _client = http.Client();
  static const Duration timeoutDuration = Duration(seconds: 30);

  Future<List<Property>> getProperties() async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/properties'))
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        print(response.body);
        final List<dynamic> jsonList = json.decode(response.body);

        final proprty =
            jsonList.map((json) => Property.fromJson(json)).toList();
        for (var property in proprty) {
          print('Property: ${property.name}');
          for (var picture in property.pictures) {
            print('Image URL: ${picture.imageUrl}');
          }
        }
        return jsonList.map((json) => Property.fromJson(json)).toList();
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

  Future<Property> getProperty(String id) async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/properties/$id'))
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        print(response.body);
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
