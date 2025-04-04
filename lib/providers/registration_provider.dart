import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';

// Define the registration state notifier
class RegistrationNotifier extends StateNotifier<RegistrationState> {
  RegistrationNotifier() : super(RegistrationState());

  // Set registration details
  void setRegistrationDetails({
    String? name,
    String? phone,
    String? address,
    String? password,
    String? latitude,
    String? longitude,
  }) {
    state = state.copyWith(
      name: name,
      phone: phone,
      address: address,
      password: password,
      latitude: latitude,
      longitude: longitude,
    );
  }

  // Set loading state
  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  // Set error message
  void setError(String message) {
    state = state.copyWith(errorMessage: message);
  }

  // Clear all registration data
  void clearRegistration() {
    state = RegistrationState();
  }
}

// Create a provider for the registration state
final registrationProvider =
    StateNotifierProvider<RegistrationNotifier, RegistrationState>((ref) {
  return RegistrationNotifier();
});
