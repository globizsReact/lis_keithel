import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

// Provider for SharedPreferences instance
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialize this provider at app startup');
});

class AuthState {
  final bool isLoggedIn;
  final bool isLoading;

  AuthState({
    required this.isLoggedIn,
    required this.isLoading,
  });
}

class AuthNotifier extends StateNotifier<AuthState> {
  final String _apiUrl =
      'https://liandsons.com/staging/api/web/v1/clients/login';
  final SharedPreferences _preferences;

  AuthNotifier(this._preferences)
      : super(AuthState(
          isLoggedIn: false,
          isLoading: false,
        )) {
    _loadLoginState();
  }

  void _loadLoginState() {
    final isLoggedIn = _preferences.getBool('isLoggedIn') ?? false;
    state = AuthState(isLoggedIn: isLoggedIn, isLoading: isLoggedIn);
  }

  Future<void> login(String username, String password) async {
    try {
      // Set loading state (optional)
      state = AuthState(isLoggedIn: false, isLoading: true);
      // Step 1: Make an HTTP POST request to the API
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "Username": username,
          "Password": password,
        }),
      );

      // Step 2: Parse the API response
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['type'] == 'success') {
          // Extract relevant data from the response
          final token = responseData['msg'];
          final fullname = responseData['fullname'];

          // Save the login state and user details
          await _preferences.setBool('isLoggedIn', true);
          await _preferences.setString('token', token);
          await _preferences.setString('fullname', fullname);

          // Update the application state
          state = AuthState(isLoggedIn: true, isLoading: true);

          print('Login successful! Welcome, $fullname');
        } else {
          throw Exception('Login failed: ${responseData['msg']}');
        }
      } else {
        throw Exception('Failed to login: ${response.reasonPhrase}');
      }
    } catch (e) {
      // Handle errors (e.g., network issues, invalid credentials)
      print('Error during login: $e');
    }
  }

  // Future<void> login() async {
  //   await _preferences.setBool('isLoggedIn', true);
  //   state = AuthState(isLoggedIn: true);
  // }

  Future<void> logout() async {
    await _preferences.setBool('isLoggedIn', false);
    await _preferences.remove('token');
    await _preferences.remove('fullname');
    await _preferences.setBool('isLoggedIn', false);
    state = AuthState(isLoggedIn: false, isLoading: false);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final preferences = ref.watch(sharedPreferencesProvider);
  return AuthNotifier(preferences);
});
