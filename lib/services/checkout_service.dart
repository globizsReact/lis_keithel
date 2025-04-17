import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lis_keithel/utils/config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../providers/providers.dart';

// Enum for payment modes
enum PaymentMode {
  online,
  cod;

  String get value {
    switch (this) {
      case PaymentMode.online:
        return 'online';
      case PaymentMode.cod:
        return 'cod';
    }
  }
}

// Order Service
class CheckoutService {
  // Base URL from config
  final String baseUrl = Config.baseUrl;

  // Method to place an order
  Future<OrderResponse> placeOrder({
    required List<Map<String, dynamic>> loadItems,
    required String deliveryDate,
    String? couponCode,
  }) async {
    // Get token from shared preferences
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      throw Exception('Authentication token not found');
    }

    // Prepare request body
    final Map<String, dynamic> requestBody = {
      "mode": 'online',
      "delivery_date": deliveryDate,
      "load": loadItems,
      "coupon": couponCode,
    };

    try {
      // Place order API endpoint
      final Uri url = Uri.parse('$baseUrl/salesorders/clientordercreate');

      // Make the POST request
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'token': token,
        },
        body: jsonEncode(requestBody),
      );

      // Check if request was successful
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        debugPrint('$responseData');
        return OrderResponse.fromJson(responseData);
      } else {
        throw Exception(
            'Failed to place order. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error placing order: $e');
    }
  }
}

// Provider for Riverpod
final checkoutServiceProvider =
    Provider<CheckoutService>((ref) => CheckoutService());
