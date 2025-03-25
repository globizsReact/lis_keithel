// order_service.dart
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../utils/config.dart';

import '../models/models.dart';

class OrderService {
  // Base URL for API
  final String baseUrl = Config.baseUrl;

  // Mock data for demo
  final List<Order> _mockOrders = [
    Order(
      id: '56ASDFH',
      date: DateTime(2025, 1, 29),
      status: OrderStatus.noPayment,
      items: [
        OrderItem(
          name: 'Khamdenu 10mm',
          pricePerKg: 64.60,
          quantity: 15,
          imageUrl: 'assets/images/khamdenu.png',
        ),
        OrderItem(
          name: 'Khamdenu 8mm',
          pricePerKg: 66.0,
          quantity: 50,
          imageUrl: 'assets/images/shyam.png',
        ),
      ],
      imageUrl: 'assets/images/dalmia.png',
    ),
    Order(
      id: '56ASDFH',
      date: DateTime(2025, 1, 29),
      status: OrderStatus.cancel,
      items: [
        OrderItem(
          name: 'Ultratech Cement',
          pricePerKg: 350.0,
          quantity: 10,
          imageUrl: 'assets/images/ultratech.png',
        ),
      ],
      imageUrl: 'assets/images/ultratech.png',
    ),
    Order(
      id: '56ASDFH',
      date: DateTime(2025, 1, 29),
      status: OrderStatus.newOrder,
      items: [
        OrderItem(
          name: 'Dalmia Cement',
          pricePerKg: 330.0,
          quantity: 15,
          imageUrl: 'assets/images/dalmia.png',
        ),
      ],
      imageUrl: 'assets/images/dalmia.png',
    ),
    Order(
      id: '56ASDFH',
      date: DateTime(2025, 1, 29),
      status: OrderStatus.paid,
      items: [
        OrderItem(
          name: 'AAC Blocks',
          pricePerKg: 45.0,
          quantity: 100,
          imageUrl: 'assets/images/acc.png',
        ),
      ],
      imageUrl: 'assets/images/acc.png',
    ),
    Order(
      id: '57TYUIO',
      date: DateTime(2025, 2, 15),
      status: OrderStatus.paid,
      items: [
        OrderItem(
          name: 'Khamdenu 12mm',
          pricePerKg: 68.50,
          quantity: 25,
          imageUrl: 'assets/images/xtech.png',
        ),
      ],
      imageUrl: 'assets/images/xtech.png',
    ),
    Order(
      id: '58QWERT',
      date: DateTime(2025, 3, 10),
      status: OrderStatus.noPayment,
      items: [
        OrderItem(
          name: 'PVC Pipes',
          pricePerKg: 120.0,
          quantity: 30,
          imageUrl: 'assets/images/tata.png',
        ),
      ],
      imageUrl: 'assets/images/tata.png',
    ),
  ];

  // Get all orders
  Future<List<Order>> getOrders() async {
    try {
      // For demo, return mock data
      // In real app, use HTTP call
      // final response = await http.get(Uri.parse('$baseUrl/orders'));

      // if (response.statusCode == 200) {
      //   final List<dynamic> data = json.decode(response.body);
      //   return data.map((json) => Order.fromJson(json)).toList();
      // } else {
      //   throw Exception('Failed to load orders');
      // }

      await Future.delayed(
          const Duration(milliseconds: 800)); // Simulate network delay
      return _mockOrders;
    } catch (e) {
      debugPrint('Error fetching orders: $e');
      return [];
    }
  }

  // Get orders filtered by date range
  Future<List<Order>> getOrdersByDateRange(DateTime start, DateTime end) async {
    try {
      // For demo, filter mock data
      // In real app, use HTTP call with query parameters
      // final response = await http.get(
      //   Uri.parse('$baseUrl/orders?start=${start.toIso8601String()}&end=${end.toIso8601String()}')
      // );

      await Future.delayed(
          const Duration(milliseconds: 800)); // Simulate network delay

      return _mockOrders.where((order) {
        return order.date.isAfter(start.subtract(const Duration(days: 1))) &&
            order.date.isBefore(end.add(const Duration(days: 1)));
      }).toList();
    } catch (e) {
      debugPrint('Error fetching orders by date range: $e');
      return [];
    }
  }

  // Get order details by ID
  Future<Order?> getOrderById(String id) async {
    try {
      // For demo, find in mock data
      // In real app, use HTTP call
      // final response = await http.get(Uri.parse('$baseUrl/orders/$id'));

      await Future.delayed(
          const Duration(milliseconds: 500)); // Simulate network delay

      return _mockOrders.firstWhere((order) => order.id == id);
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
