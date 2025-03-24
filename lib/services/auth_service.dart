import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lis_keithel_v1/utils/config.dart';

class AuthService {
  final String baseUrl = Config.baseUrl;

  // Login API call
  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/clients/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "Username": username,
        "Password": password,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Server error: ${response.reasonPhrase}');
    }
  }

  // Register API call
  Future<Map<String, dynamic>> register({
    required String name,
    required String phone,
    required String password,
    required String address,
    required String lat,
    required String lan,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/clients/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "Name": name,
        "Phone": phone,
        "Password": password,
        "Address": address,
        "Lat": lat,
        "Lan": lan,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Server error: ${response.reasonPhrase}');
    }
  }

  // Verify OTP API call
  Future<Map<String, dynamic>> verifyOtp(String phone, String otp) async {
    final response = await http.post(
      Uri.parse('$baseUrl/clients/verify-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "Phone": phone,
        "OTP": otp,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Server error: ${response.reasonPhrase}');
    }
  }
}
