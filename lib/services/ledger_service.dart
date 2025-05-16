// lib/services/api_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lis_keithel/utils/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';

class LedgerService {
  final String baseUrl = Config.baseUrl;

  Future<List<ProductL>> getProducts() async {
    try {
      // Access SharedPreferences instance
      final prefs = await SharedPreferences.getInstance();

      // Retrieve the token from SharedPreferences
      final token = prefs.getString('token');
      if (token == null || token.isEmpty) {
        throw Exception('Token not found in SharedPreferences');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/ledgers/products'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'token': token,
        },
      );

      debugPrint('Status Code: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);

        return jsonData.map((data) => ProductL.fromJson(data)).toList();
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching products: $e');
    }
  }

  Future<List<ProductLedgerEntry>> getProductLedger({
    required int productId,
    required int page,
  }) async {
    try {
      // Access SharedPreferences instance
      final prefs = await SharedPreferences.getInstance();

      // Retrieve the token from SharedPreferences
      final token = prefs.getString('token');
      if (token == null || token.isEmpty) {
        throw Exception('Token not found in SharedPreferences');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/ledgers?product_id=$productId&_page=$page'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'token': token,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData
            .map((data) => ProductLedgerEntry.fromJson(data))
            .toList();
      } else {
        throw Exception('Failed to load ledger: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching ledger: $e');
    }
  }
}
