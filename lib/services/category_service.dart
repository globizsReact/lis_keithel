// lib/services/category_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/category_model.dart';

class CategoryService {
  final String baseUrl;

  CategoryService({required this.baseUrl});

  Future<List<Category>> fetchCategories() async {
    final url = '$baseUrl/products/client_app_producttype';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'token': 'k8ASjLOE0TQC2vnDRKY0ayehsUY-CFb_'
          // Add any auth headers if needed
          // 'Authorization': 'Bearer YOUR_TOKEN',
        },
        // Add request body if needed
        // body: jsonEncode({'param': 'value'}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((item) => Category.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching categories: $e');
    }
  }
}
