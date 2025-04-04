// Define a class to hold all registration data
class RegistrationState {
  final String? name;
  final String? phone;
  final String? address;
  final String? password;
  final String? latitude;
  final String? longitude;
  final bool isLoading;
  final String? errorMessage;

  RegistrationState({
    this.name,
    this.phone,
    this.address,
    this.password,
    this.latitude,
    this.longitude,
    this.isLoading = false,
    this.errorMessage,
  });

  // Create a copy of this state with some updated fields
  RegistrationState copyWith({
    String? name,
    String? phone,
    String? address,
    String? password,
    String? latitude,
    String? longitude,
    bool? isLoading,
    String? errorMessage,
  }) {
    return RegistrationState(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      password: password ?? this.password,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
