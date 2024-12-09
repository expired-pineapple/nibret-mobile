import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:nibret/models/home_loan.dart';

class HomeLoanApiService {
  static const String baseUrl = 'https://nibret-vercel-django.vercel.app';
  static const int itemsPerPage = 10;

  final http.Client _client = http.Client();
  static const Duration timeoutDuration = Duration(seconds: 30);

  Future<Map<String, dynamic>> getHomeLoans(
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
        uri = Uri.parse('$baseUrl/home-loan/').replace(
          queryParameters: queryParameters,
        );
      }

      final response = await _client.get(uri).timeout(timeoutDuration);
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

  Future<LoanResponse> getHomeLoan(String id) async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/home-loan/$id/'))
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        final property = LoanResponse.fromJson(jsonData);

        return property;
      } else {
        throw const HttpException('Failed to load loans.');
      }
    } on SocketException {
      throw const HttpException('Oops, something went wrong');
    } on TimeoutException {
      throw const HttpException('Network error. Please try again.');
    } on HttpException catch (e) {
      throw HttpException(e.message);
    } catch (e) {
      throw const HttpException(
          'An unexpected error occurred.  Please try again.');
    }
  }
}
