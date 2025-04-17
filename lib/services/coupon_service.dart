import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/config.dart';
import '../models/models.dart';

class CouponsService {
  Future<CouponResponse> getCoupons(
      List<Map<String, dynamic>> loadItems) async {
    const url = '${Config.baseUrl}/salesorders/couponslist';

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

        return CouponResponse.fromJson(jsonResponse); // Parse using the model
      } else {
        throw Exception("Failed to load coupons");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }
}
