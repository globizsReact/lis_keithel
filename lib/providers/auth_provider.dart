import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import '../screens/screens.dart';
import '../utils/theme.dart';
import '../widgets/custom_toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import the new auth service
import '../services/auth_service.dart';

// Provider for SharedPreferences instance
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialize this provider at app startup');
});

// Provider for AuthService
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

class AuthState {
  final bool isLoggedIn;
  final bool isLoading;
  final String errorMessage;
  final String? otp;
  final String? phone;
  final bool isRegistered;

  AuthState({
    required this.isLoggedIn,
    required this.isLoading,
    required this.errorMessage,
    this.otp,
    this.phone,
    this.isRegistered = false,
  });

  AuthState copyWith({
    bool? isLoggedIn,
    bool? isLoading,
    String? errorMessage,
    String? otp,
    String? phone,
    bool? isRegistered,
  }) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      otp: otp ?? this.otp,
      phone: phone ?? this.phone,
      isRegistered: isRegistered ?? this.isRegistered,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  final SharedPreferences _preferences;

  // Add a stream controller
  final _authStateController = StreamController<AuthState>.broadcast();

  // Expose the stream
  Stream<AuthState> get stream => _authStateController.stream;

  AuthNotifier(this._preferences, this._authService)
      : super(
            AuthState(isLoggedIn: false, isLoading: false, errorMessage: '')) {
    _loadLoginState();
  }

  void _loadLoginState() {
    final isLoggedIn = _preferences.getBool('isLoggedIn') ?? false;
    final otp = _preferences.getString('otp');
    final phone = _preferences.getString('phone');
    final isRegistered = _preferences.getBool('isRegistered') ?? false;

    state = AuthState(
      isLoggedIn: isLoggedIn,
      isLoading: false,
      errorMessage: '',
      otp: otp,
      phone: phone,
      isRegistered: isRegistered,
    );
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
      // Set loading state
      state = state.copyWith(isLoading: true, errorMessage: '');

      // Use the service to make the API call
      final responseData = await _authService.login(username, password);

      if (responseData['type'] == 'success') {
        // Extract relevant data from the response
        final token = responseData['msg'];
        final fullname = responseData['fullname'];

        // Save the login state and user details
        await _preferences.setBool('isLoggedIn', true);
        await _preferences.setString('token', token);
        await _preferences.setString('fullname', fullname);

        // Update the application state
        state = state.copyWith(
            isLoggedIn: true, isLoading: false, errorMessage: '');

        // Show success toast

        CustomToast.show(
          context: context,
          message: 'Login successful! Welcome, $fullname',
          icon: Icons.check,
          backgroundColor: AppTheme.green,
          textColor: Colors.white,
          gravity: ToastGravity.CENTER,
          duration: Duration(seconds: 3),
        );

        if (context.mounted) {
          context.go('/');
        }
      } else {
        // Handle the specific failure response
        state = state.copyWith(
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
    } catch (e) {
      // Handle exceptions (network issues, etc.)
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Connection error',
      );

      Fluttertoast.showToast(
        msg: 'Connection error: ${e.toString()}',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: AppTheme.red,
        textColor: AppTheme.white,
      );
    }
  }

  Future<void> register({
    required BuildContext context,
    required String name,
    required String phone,
    required String password,
    required String address,
    required String lat,
    required String lan,
  }) async {
    try {
      // Set loading state
      state = state.copyWith(isLoading: true, errorMessage: '');

      // Use the service to make the API call
      final responseData = await _authService.register(
        name: name,
        phone: phone,
        password: password,
        address: address,
        lat: lat,
        lan: lan,
      );

      if (responseData['type'] == 'success') {
        // Extract relevant data from the response
        final token = responseData['msg'];
        final otp = responseData['otp'];

        // Save registration state and details
        await _preferences.setBool('isRegistered', true);
        await _preferences.setString('token', token);
        await _preferences.setString('otp', otp);
        await _preferences.setString('phone', phone);

        // Update the application state
        state = state.copyWith(
          isLoading: false,
          errorMessage: '',
          otp: otp,
          phone: phone,
          isRegistered: true,
        );

        print('OTP ${state.otp}');

        if (context.mounted) {
          context.go('/otp-verification', extra: {
            'type': OtpScreenType.registration,
            'phoneNumber': phone,
          });
        }
      } else {
        // Handle the specific failure response
        state = state.copyWith(
          isLoading: false,
          errorMessage: responseData['msg'],
        );

        // Show error toast
        Fluttertoast.showToast(
          msg: responseData['msg'],
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: AppTheme.red,
          textColor: AppTheme.white,
        );
      }
    } catch (e) {
      // Handle exceptions (network issues, etc.)
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Connection error',
      );

      Fluttertoast.showToast(
        msg: 'Connection error: ${e.toString()}',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: AppTheme.red,
        textColor: AppTheme.white,
      );
    }
  }

  bool verifyOtp(String enteredOtp) {
    // Check if the entered OTP matches the stored OTP
    return enteredOtp == state.otp;
  }

  // Verify OTP with backend (optional additional step)
  Future<void> verifyOtpWithBackend(
    BuildContext context,
    String enteredOtp,
  ) async {
    try {
      if (state.phone == null) {
        throw Exception("Phone number not found");
      }

      // Set loading state
      state = state.copyWith(isLoading: true, errorMessage: '');

      // Use the service to make the API call
      final responseData = await _authService.verifyOtp(
        state.phone!,
        enteredOtp,
      );

      if (responseData['type'] == 'success') {
        // OTP verification successful
        // Update the application state
        await _preferences.setBool('isLoggedIn', true);
        await _preferences.remove('otp'); // Clear OTP after verification

        state = state.copyWith(
          isLoggedIn: true,
          isLoading: false,
          errorMessage: '',
          otp: null, // Clear OTP in state
        );

        // Show success toast
        Fluttertoast.showToast(
          msg: 'OTP verification successful!',
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
        state = state.copyWith(
          isLoading: false,
          errorMessage: responseData['msg'],
        );

        // Show error toast
        Fluttertoast.showToast(
          msg: responseData['msg'],
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: AppTheme.red,
          textColor: AppTheme.white,
        );
      }
    } catch (e) {
      // Handle exceptions (network issues, etc.)
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Connection error: ${e.toString()}',
      );

      Fluttertoast.showToast(
        msg: 'Connection error: ${e.toString()}',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: AppTheme.red,
        textColor: AppTheme.white,
      );
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
  final authService = ref.watch(authServiceProvider);
  final notifier = AuthNotifier(preferences, authService);

  ref.onDispose(() {
    notifier.dispose();
  });

  return notifier;
});
