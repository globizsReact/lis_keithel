import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lis_keithel/widgets/custom_toast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/config.dart';
import '../utils/theme.dart';

import '../services/location_service.dart';

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService(); // Instantiate the LocationService
});

final locationProvider =
    StateNotifierProvider<LocationNotifier, Map<String, double>?>((ref) {
  return LocationNotifier(ref.read(locationServiceProvider));
});

class LocationNotifier extends StateNotifier<Map<String, double>?> {
  final LocationService _locationService;

  LocationNotifier(this._locationService) : super(null);

  // Fetch and update the current location
  Future<void> fetchLocation() async {
    final location = await _locationService.getCurrentLocation();
    state = location; // Update the state with the new location
  }
}

Future<void> sendLocationToApi(
    BuildContext context, Map<String, double> location) async {
  final url = Uri.parse(
      '${Config.baseUrl}/clients/client_update_location'); // Replace with your API endpoint
  final body = jsonEncode({
    'Lat': location['latitude'],
    'Lan': location['longitude'],
  });

  try {
    // Access SharedPreferences instance
    final prefs = await SharedPreferences.getInstance();
    // Retrieve the token from SharedPreferences
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) {
      throw Exception('Token not found in SharedPreferences');
    }

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'token': token,
      },
      body: body,
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['type'] == 'success') {
        CustomToast.show(
          context: context,
          message: responseData['msg'],
          icon: Icons.check,
          backgroundColor: AppTheme.green,
          textColor: Colors.white,
          gravity: ToastGravity.CENTER,
          duration: Duration(seconds: 3),
        );
      } else {
        CustomToast.show(
          context: context,
          message: responseData['msg'],
          icon: Icons.check,
          backgroundColor: AppTheme.red,
          textColor: Colors.white,
          gravity: ToastGravity.CENTER,
          duration: Duration(seconds: 3),
        );
      }
    } else {
      debugPrint('Failed to send location: ${response.statusCode}');
    }
  } catch (e) {
    debugPrint('Error sending location: $e');
  }
}
