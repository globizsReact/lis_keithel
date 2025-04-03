import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class RewardService {
  final String baseUrl;

  RewardService({required this.baseUrl});

  Future<RewardModel> fetchRewards() async {
    final url = '$baseUrl/products/rewardpoint';

    try {
      // Access SharedPreferences instance
      final prefs = await SharedPreferences.getInstance();

      // Retrieve the token from SharedPreferences
      final token = prefs.getString('token');
      if (token == null || token.isEmpty) {
        throw Exception('Token not found in SharedPreferences');
      }

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'token': token,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return RewardModel.fromJson(jsonData);
      } else {
        throw Exception('Failed to load rewards');
      }
    } catch (e) {
      throw Exception('Error fetching rewards: $e');
    }
  }
}
