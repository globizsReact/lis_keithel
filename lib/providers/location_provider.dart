import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lis_keithel_v1/utils/config.dart';
import 'package:lis_keithel_v1/utils/theme.dart';
import 'package:lis_keithel_v1/widgets/custom_toast.dart';
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

Future<void> sendLocationToApi(Map<String, double> location) async {
  final url =
      Uri.parse('${Config.baseUrl}/location'); // Replace with your API endpoint
  final body = jsonEncode({
    'latitude': location['latitude'],
    'longitude': location['longitude'],
  });

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      print('Location sent successfully');
      // Show success toast
      Fluttertoast.showToast(
        msg: 'Location update successfully',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: AppTheme.orange,
        textColor: AppTheme.white,
      );
    } else {
      print('Failed to send location: ${response.statusCode}');
    }
  } catch (e) {
    print('Error sending location: $e');
  }
}
