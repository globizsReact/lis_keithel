import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/config.dart';
import '../models/models.dart';

class OrderService {
  // Base URL for API
  final String baseUrl = Config.baseUrl;

  // Get all orders
  Future<List<Order>> getOrders() async {
    final url = '$baseUrl/salesorders/clientorderlist';
    try {
      // Access SharedPreferences instance
      final prefs = await SharedPreferences.getInstance();

      // Retrieve the token from SharedPreferences
      final token = prefs.getString('token');
      if (token == null || token.isEmpty) {
        throw Exception('Token not found in SharedPreferences');
      }

      // Make HTTP call
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'token': token,
        },
        body: jsonEncode(
          {},
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Order.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load orders: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching orders: $e');
      return [];
    }
  }

  // Get order details by ID
  Future<OrderDetail?> getOrderById(String id) async {
    final url = '$baseUrl/salesorders/clientorderview';

    try {
      // Access SharedPreferences instance if you need the token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        throw Exception('Token not found in SharedPreferences');
      }

      // Make HTTP call
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'token': token
          // Add any other required headers
        },
        body: jsonEncode(
          {
            "id": id,
          },
        ),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return OrderDetail.fromJson(data);
      } else {
        debugPrint('Failed to load order: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching order details: $e');
      return null;
    }
  }

  // Cancel order
// Cancel order
  Future<bool> cancelOrder(String id, String status) async {
    try {
      // Define the API endpoint
      final url = Uri.parse('$baseUrl/salesorders/client_order_cancel');

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        throw Exception('Token not found in SharedPreferences');
      }

      // Define the request body
      final requestBody = {
        "Id": int.parse(id), // Convert the ID to an integer
        "Status": status, // Use the provided status
      };

      // Make the HTTP POST request
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'token': token,
        },
        body: jsonEncode(requestBody),
      );

      // Simulate network delay (optional, can be removed in production)
      await Future.delayed(const Duration(seconds: 1));

      // Check if the response is successful
      if (response.statusCode == 200) {
        // Parse the response body
        final responseBody = jsonDecode(response.body);

        // Check the response type
        if (responseBody['type'] == 'success') {
          debugPrint('Order cancellation successful: ${responseBody['msg']}');
          return true;
        } else {
          debugPrint('Order cancellation failed: ${responseBody['msg']}');
          return false;
        }
      } else {
        debugPrint('Error cancelling order: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Error cancelling order: $e');
      return false;
    }
  }
}
