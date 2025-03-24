import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import 'package:location/location.dart';
import '../utils/theme.dart';

class MultiRegisterScreen extends ConsumerStatefulWidget {
  const MultiRegisterScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MultiRegisterScreen> createState() =>
      _MultiRegisterScreenState();
}

class _MultiRegisterScreenState extends ConsumerState<MultiRegisterScreen> {
// Lat Long
  LocationData? _currentLocation;
  final Location _locationService = Location();

  @override
  void initState() {
    super.initState();
    _getLocationOnStartup();
  }

  Future<void> _getLocationOnStartup() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    // Check if location services are enabled
    serviceEnabled = await _locationService.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _locationService.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    // Check for location permissions
    permissionGranted = await _locationService.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _locationService.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    // Fetch the current location
    final locationData = await _locationService.getLocation();
    setState(() {
      _currentLocation = locationData;
    });
  }

  // Form
  final _formKey = GlobalKey<FormState>();

  // Step 1 Controllers
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _addressController = TextEditingController();

  // Step 2 Controllers
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _passwordVisible = false;

  int _currentStep = 0; // Tracks the current step (0 = Details, 1 = Password)

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (_formKey.currentState!.validate()) {
        setState(() {
          _currentStep++;
        });
      }
    } else {
      if (_formKey.currentState!.validate()) {
        final authNotifier = ref.read(authProvider.notifier);

        authNotifier.register(
          context: context,
          name: _nameController.text.trim(),
          phone: _mobileController.text.trim(),
          password: _passwordController.text,
          address: _addressController.text.trim(),
          lat: _currentLocation!.latitude.toString(),
          lan: _currentLocation!.longitude.toString(),
        );
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                // Logo
                Image.asset(
                  'assets/images/logo.png', // You'll need to add this asset
                  height: 120,
                ),

                const SizedBox(height: 20),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Register Title
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Register',
                        style: TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.black,
                        ),
                      ),
                    ),

                    // Subtitle
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'to get started',
                        style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.grey,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Step Indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStepIndicator(0, 'Details'),
                    SizedBox(
                      width: 180,
                      child: Divider(),
                    ),
                    _buildStepIndicator(1, 'Password'),
                  ],
                ),

                const SizedBox(height: 10),

                // Conditional Rendering for Steps
                if (_currentStep == 0) ...[
                  // Step 1: Details Section
                  _buildDetailsSection(),
                ] else ...[
                  // Step 2: Password Section
                  _buildPasswordSection(),
                ],

                const SizedBox(height: 20),

                // Navigation Buttons
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isLoading ? AppTheme.grey : AppTheme.orange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: _nextStep,
                          child: isLoading
                              ? SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 3,
                                  ),
                                )
                              : Text(
                                  _currentStep == 0 ? 'Next' : 'Register',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: _currentStep == 0 ? 0 : 10),
                // Row
                Row(
                  children: [
                    if (_currentStep > 0)
                      Expanded(
                        child: SizedBox(
                          child: TextButton(
                            onPressed: _previousStep,
                            child: const Text(
                              'Back',
                              style: TextStyle(
                                fontSize: 18,
                                color: AppTheme.navy,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                // Login now
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account? ",
                      style: TextStyle(
                        color: AppTheme.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        context.go('/login');
                      },
                      child: Text(
                        'Login now',
                        style: TextStyle(
                          color: AppTheme.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

// stepper
  Widget _buildStepIndicator(int stepIndex, String label) {
    return Column(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentStep == stepIndex
                ? AppTheme.orange // Active step
                : _currentStep > stepIndex
                    ? AppTheme.orange // Completed step
                    : AppTheme.grey,
          ),
          child: Center(
            child: _currentStep > stepIndex
                ? Icon(
                    Icons.check, // Checkmark icon for completed steps
                    color: Colors.white,
                    size: 16,
                  )
                : Text(
                    '${stepIndex + 1}', // Step number for active/incomplete steps
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.black,
          ),
        ),
      ],
    );
  }

// Details
  Widget _buildDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Enter your details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.black,
            ),
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              vertical: 20,
              horizontal: 20,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.orange),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.orange),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppTheme.orange,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red),
            ),
            hintText: 'Name',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your name';
            }
            return null;
          },
        ),
        const SizedBox(height: 5),
        TextFormField(
          controller: _mobileController,
          maxLength: 10,
          decoration: InputDecoration(
            counterText: '',
            contentPadding: const EdgeInsets.symmetric(
              vertical: 20,
              horizontal: 20,
            ),
            hintText: 'Mobile number',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.orange),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.orange),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppTheme.orange,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your mobile number';
            }
            // Simple regex for 10-digit mobile number
            if (!RegExp(r'^\d{10}$').hasMatch(value)) {
              return 'Please enter a valid 10-digit mobile number';
            }
            return null;
          },
        ),
        const SizedBox(height: 5),
        TextFormField(
          controller: _addressController,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              vertical: 20,
              horizontal: 20,
            ),
            hintText: 'Address',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.orange),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.orange),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppTheme.orange,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your address';
            }
            return null;
          },
        ),
      ],
    );
  }

// password
  Widget _buildPasswordSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 20,
        ),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Set your password',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.black,
            ),
          ),
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _passwordController,
          obscureText: !_passwordVisible,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              vertical: 20,
              horizontal: 20,
            ),
            hintText: 'Password',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.orange),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.orange),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppTheme.orange,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red),
            ),
            suffixIcon: IconButton(
              icon: Image.asset(
                _passwordVisible
                    ? 'assets/icons/eye_close.png'
                    : 'assets/icons/eye_open.png',
                width: 20,
              ),
              onPressed: () {
                setState(() {
                  _passwordVisible = !_passwordVisible;
                });
              },
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a password';
            }
            if (value.length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
        ),
        const SizedBox(height: 5),
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: true,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              vertical: 20,
              horizontal: 20,
            ),
            hintText: 'Confirm password',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.orange),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.orange),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppTheme.orange,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please confirm your password';
            }
            if (value != _passwordController.text) {
              return 'Passwords do not match';
            }
            return null;
          },
        ),
      ],
    );
  }
}
