import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/quiz_category_model.dart';
import '../model/quiz_ques_model.dart';

class ApiService {
  static const String _baseUrl = 'https://sadiks-quiz-apihub.lovable.app/api/v1';

  /// Fetch all quiz categories
  Future<List<QuizCategory>> fetchCategories() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/categories'));
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        final List data = result['data'];
        return data.map((item) => QuizCategory.fromJson(item)).toList();
      } else {
        throw ApiException('Failed to load categories (Status: ${response.statusCode})');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: Could not connect to server');
    }
  }

  /// Fetch questions for a specific category
  Future<List<QuizQuestion>> fetchQuestions(int categoryId) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/categories/$categoryId/questions'));
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        final List data = result['data'];
        return data.map((item) => QuizQuestion.fromJson(item)).toList();
      } else {
        throw ApiException('Failed to load questions (Status: ${response.statusCode})');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: Could not connect to server');
    }
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}
