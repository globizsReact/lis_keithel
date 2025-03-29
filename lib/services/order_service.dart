// order_service.dart
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
  // Get orders filtered by date range
  // Future<List<Order>> getOrdersByDateRange(DateTime start, DateTime end) async {
  //   try {
  //     // For demo, filter mock data
  //     // In real app, use HTTP call with query parameters
  //     // final response = await http.get(
  //     //   Uri.parse('$baseUrl/orders?start=${start.toIso8601String()}&end=${end.toIso8601String()}')
  //     // );

  //     await Future.delayed(
  //         const Duration(milliseconds: 800)); // Simulate network delay

  //     return _mockOrders.where((order) {
  //       return order.date.isAfter(start.subtract(const Duration(days: 1))) &&
  //           order.date.isBefore(end.add(const Duration(days: 1)));
  //     }).toList();
  //   } catch (e) {
  //     debugPrint('Error fetching orders by date range: $e');
  //     return [];
  //   }
  // }

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
  Future<bool> cancelOrder(String id) async {
    try {
      // For demo, return success
      // In real app, use HTTP call
      // final response = await http.post(
      //   Uri.parse('$baseUrl/orders/$id/cancel'),
      //   headers: {'Content-Type': 'application/json'},
      // );

      await Future.delayed(
          const Duration(seconds: 1)); // Simulate network delay

      return true;
    } catch (e) {
      debugPrint('Error cancelling order: $e');
      return false;
    }
  }
}
