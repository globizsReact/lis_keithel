import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:lis_keithel_v1/utils/config.dart';
import 'package:lis_keithel_v1/utils/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

// Provider for SharedPreferences instance
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialize this provider at app startup');
});

class AuthState {
  final bool isLoggedIn;
  final bool isLoading;
  final String errorMessage;

  AuthState({
    required this.isLoggedIn,
    required this.isLoading,
    required this.errorMessage,
  });
}

class AuthNotifier extends StateNotifier<AuthState> {
  final String _apiUrl = '${Config.baseUrl}/clients/login';
  final SharedPreferences _preferences;

  // Add a stream controller
  final _authStateController = StreamController<AuthState>.broadcast();

  // Expose the stream
  Stream<AuthState> get stream => _authStateController.stream;

  AuthNotifier(this._preferences)
      : super(
            AuthState(isLoggedIn: false, isLoading: false, errorMessage: '')) {
    _loadLoginState();
  }

  void _loadLoginState() {
    final isLoggedIn = _preferences.getBool('isLoggedIn') ?? false;

    state =
        AuthState(isLoggedIn: isLoggedIn, isLoading: false, errorMessage: '');
  }

  @override
  set state(AuthState value) {
    super.state = value;
    // Emit the new state to the stream
    _authStateController.add(value);
  }

  // Make sure to close the controller when done
  void dispose() {
    _authStateController.close();
  }

  Future<void> login(
      BuildContext context, String username, String password) async {
    try {
      // Set loading state (optional)
      state = AuthState(isLoggedIn: false, isLoading: true, errorMessage: '');

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
          state =
              AuthState(isLoggedIn: true, isLoading: false, errorMessage: '');

          // Show success toast
          Fluttertoast.showToast(
            msg: 'Login successful! Welcome, $fullname',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            backgroundColor: AppTheme.orange,
            textColor: AppTheme.white,
          );

          if (context.mounted) {
            context.go('/');
          }
        } else {
          // Handle the specific failure response
          state = AuthState(
            isLoggedIn: false,
            isLoading: false,
            errorMessage: responseData['msg'],
          );

          // Show error toast for invalid credentials
          Fluttertoast.showToast(
            msg: responseData['msg'],
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            backgroundColor: AppTheme.red,
            textColor: AppTheme.white,
          );
        }
      } else {
        // Handle HTTP errors
        state = AuthState(
            isLoggedIn: false,
            isLoading: false,
            errorMessage: 'Server error: ${response.reasonPhrase}');
      }
    } catch (e) {
      // Handle exceptions (network issues, etc.)
      state = AuthState(
          isLoggedIn: false,
          isLoading: false,
          errorMessage: 'Connection error');
    }
  }

  Future<void> logout() async {
    await _preferences.setBool('isLoggedIn', false);
    await _preferences.remove('token');
    await _preferences.remove('fullname');

    state = AuthState(isLoggedIn: false, isLoading: false, errorMessage: '');
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final preferences = ref.watch(sharedPreferencesProvider);
  final notifier = AuthNotifier(preferences);

  ref.onDispose(() {
    notifier.dispose();
  });

  return notifier;
});
