import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nibret/models/home_loan.dart';

class HomeLoanApiService {
  static const String baseUrl = 'https://nibret-vercel-django.vercel.app';
  static const int itemsPerPage = 10;

  Future<List<LoanResponse>> getHomeLoans({
    required int page,
    String? searchQuery,
  }) async {
    try {
      final queryParameters = {
        'page': page.toString(),
        'limit': itemsPerPage.toString(),
        if (searchQuery != null && searchQuery.isNotEmpty)
          'search': searchQuery,
      };

      final uri = Uri.parse('$baseUrl/home-loan/').replace(
        queryParameters: queryParameters,
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> jsonList = data['results'];
        return jsonList.map((json) => LoanResponse.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load home loans');
      }
    } catch (e) {
      print(e);
      throw Exception('Error fetching home loans: $e');
    }
  }
}
