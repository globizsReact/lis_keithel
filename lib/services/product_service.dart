// lib/services/product_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/models.dart';

class ProductService {
  final String baseUrl;

  ProductService({required this.baseUrl});

  Future<List<Product>> fetchProducts() async {
    final url = '$baseUrl/products/client_app_productlist';

    try {
      // Access SharedPreferences instance
      // final prefs = await SharedPreferences.getInstance();

      // // Retrieve the token from SharedPreferences
      // final token = prefs.getString('token');
      // if (token == null || token.isEmpty) {
      //   throw Exception('Token not found in SharedPreferences');
      // }

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'token': 'k8ASjLOE0TQC2vnDRKY0ayehsUY-CFb_'

          // Add any auth headers if needed
          // 'Authorization': 'Bearer YOUR_TOKEN',
        },
        // Add request body if needed
        body: jsonEncode(
          {'type_id': '0'},
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((item) => Product.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching products: $e');
    }
  }
}
