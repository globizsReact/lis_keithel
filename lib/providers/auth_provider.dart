import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Provider for SharedPreferences instance
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialize this provider at app startup');
});

class AuthState {
  final bool isLoggedIn;

  AuthState({required this.isLoggedIn});
}

class AuthNotifier extends StateNotifier<AuthState> {
  final SharedPreferences _preferences;

  AuthNotifier(this._preferences) : super(AuthState(isLoggedIn: false)) {
    _loadLoginState();
  }

  void _loadLoginState() {
    final isLoggedIn = _preferences.getBool('isLoggedIn') ?? false;
    state = AuthState(isLoggedIn: isLoggedIn);
  }

  Future<void> login() async {
    await _preferences.setBool('isLoggedIn', true);
    state = AuthState(isLoggedIn: true);
  }

  Future<void> logout() async {
    await _preferences.setBool('isLoggedIn', false);
    state = AuthState(isLoggedIn: false);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final preferences = ref.watch(sharedPreferencesProvider);
  return AuthNotifier(preferences);
});
