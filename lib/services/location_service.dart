import 'package:flutter/material.dart';
import 'package:location/location.dart';

class LocationService {
  final Location _location = Location();

  // Check if location services are enabled and request permissions
  Future<bool> _checkLocationServices() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        return false;
      }
    }

    PermissionStatus permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return false;
      }
    }

    return true;
  }

  // Get the current location
  Future<Map<String, double>?> getCurrentLocation() async {
    if (!await _checkLocationServices()) {
      return null; // Return null if location services are not available
    }

    try {
      LocationData locationData = await _location.getLocation();
      return {
        'latitude': locationData.latitude!,
        'longitude': locationData.longitude!,
      };
    } catch (e) {
      debugPrint('Error fetching location: $e');
      return null;
    }
  }
}
