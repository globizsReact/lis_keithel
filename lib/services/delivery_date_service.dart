import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lis_keithel/models/models.dart';
import 'package:lis_keithel/utils/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<List<DeliveryDate>> fetchDeliveryDates(
    List<Map<String, dynamic>> loadItems) async {
  const url =
      '${Config.baseUrl}/salesorders/advancediscount'; // Replace with your actual API URL

  try {
    final prefs = await SharedPreferences.getInstance();
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
      body: jsonEncode({
        "delivery_date": "",
        "load": loadItems,
      }),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);

      return parseDeliveryDates(jsonResponse);
    } else {
      throw Exception('Failed to load delivery dates');
    }
  } catch (e) {
    throw Exception('Error fetching delivery dates: $e');
  }
}
