import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:location/location.dart';
import '../utils/responsive_sizing.dart';
import '../providers/auth_provider.dart';
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
      // Reset the form validation state
      _formKey.currentState?.reset();

      setState(() {
        _currentStep--;

        // Reset password validation when going back to details step
        _passwordController.clear();
        _confirmPasswordController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // provider
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;

    // Initialize responsive sizing
    ResponsiveSizing().init(context);
    final responsive = ResponsiveSizing();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: responsive.padding(30)),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: responsive.height(0.08),
                ),

                // Logo
                Image.asset(
                  'assets/images/logo.png',
                  width: responsive.width(0.4),
                ),

                SizedBox(
                  height: responsive.height(0.06),
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Register Title
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Register',
                        style: TextStyle(
                          fontSize: responsive.textSize(30),
                          fontWeight: FontWeight.bold,
                          color: AppTheme.black,
                        ),
                      ),
                    ),

                    // Subtitle
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'to get started',
                        style: TextStyle(
                          fontSize: responsive.textSize(14),
                          color: AppTheme.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: responsive.height(0.025),
                ),

                // Step Indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStepIndicator(0, 'Details'),
                    SizedBox(
                      width: responsive.width(0.55),
                      child: Divider(),
                    ),
                    _buildStepIndicator(1, 'Password'),
                  ],
                ),

                SizedBox(
                  height: responsive.height(0.01),
                ),

                // Conditional Rendering for Steps
                if (_currentStep == 0) ...[
                  // Step 1: Details Section
                  _buildDetailsSection(),
                ] else ...[
                  // Step 2: Password Section
                  _buildPasswordSection(),
                ],

                SizedBox(
                  height: responsive.height(0.015),
                ),

                // Navigation Buttons
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        width: double.infinity,
                        height: responsive.height(0.075),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isLoading ? AppTheme.grey : AppTheme.orange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(11),
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
                                    fontSize: responsive.textSize(16),
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
                            child: Text(
                              'Back',
                              style: TextStyle(
                                fontSize: responsive.textSize(16),
                                color: AppTheme.navy,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                SizedBox(
                  height: responsive.height(0.04),
                ),
                // Login now

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
                SizedBox(
                  height: responsive.height(0.02),
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
    // Initialize responsive sizing
    ResponsiveSizing().init(context);
    final responsive = ResponsiveSizing();
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
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  )
                : Text(
                    '${stepIndex + 1}',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        SizedBox(height: responsive.height(0.007)),
        Text(
          label,
          style: TextStyle(
            fontSize: responsive.textSize(12),
            color: AppTheme.black,
          ),
        ),
      ],
    );
  }

// Details
  Widget _buildDetailsSection() {
    // Initialize responsive sizing
    ResponsiveSizing().init(context);
    final responsive = ResponsiveSizing();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: responsive.height(0.007)),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Enter your details',
            style: TextStyle(
              fontSize: responsive.textSize(18),
              fontWeight: FontWeight.w600,
              color: AppTheme.black,
            ),
          ),
        ),
        SizedBox(height: responsive.height(0.015)),
        TextFormField(
          controller: _nameController,
          style: TextStyle(
            color: AppTheme.black,
          ),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(
              vertical: responsive.padding(20),
              horizontal: responsive.padding(20),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
              borderSide: const BorderSide(color: AppTheme.orange),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
              borderSide: const BorderSide(color: AppTheme.orange),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
              borderSide: const BorderSide(
                color: AppTheme.orange,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
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
        SizedBox(height: responsive.height(0.006)),
        TextFormField(
          controller: _mobileController,
          maxLength: 10,
          style: TextStyle(
            color: AppTheme.black,
          ),
          decoration: InputDecoration(
            counterText: '',
            contentPadding: EdgeInsets.symmetric(
              vertical: responsive.padding(20),
              horizontal: responsive.padding(20),
            ),
            hintText: 'Mobile number',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
              borderSide: const BorderSide(color: AppTheme.orange),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
              borderSide: const BorderSide(color: AppTheme.orange),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
              borderSide: const BorderSide(
                color: AppTheme.orange,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
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
        SizedBox(height: responsive.height(0.006)),
        TextFormField(
          controller: _addressController,
          style: TextStyle(
            color: AppTheme.black,
          ),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(
              vertical: responsive.padding(20),
              horizontal: responsive.padding(20),
            ),
            hintText: 'Address',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
              borderSide: const BorderSide(color: AppTheme.orange),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
              borderSide: const BorderSide(color: AppTheme.orange),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
              borderSide: const BorderSide(
                color: AppTheme.orange,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
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
    // Initialize responsive sizing
    ResponsiveSizing().init(context);
    final responsive = ResponsiveSizing();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: responsive.height(0.007)),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Set your password',
            style: TextStyle(
              fontSize: responsive.textSize(18),
              fontWeight: FontWeight.w600,
              color: AppTheme.black,
            ),
          ),
        ),
        SizedBox(height: responsive.height(0.015)),
        TextFormField(
          controller: _passwordController,
          obscureText: !_passwordVisible,
          style: TextStyle(
            color: AppTheme.black,
          ),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(
              vertical: responsive.padding(20),
              horizontal: responsive.padding(20),
            ),
            hintText: 'Password',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
              borderSide: const BorderSide(color: AppTheme.orange),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
              borderSide: const BorderSide(color: AppTheme.orange),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
              borderSide: const BorderSide(
                color: AppTheme.orange,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
              borderSide: const BorderSide(color: Colors.red),
            ),
            suffixIcon: IconButton(
              icon: Image.asset(
                _passwordVisible
                    ? 'assets/icons/eye_open.png'
                    : 'assets/icons/eye_close.png',
                width: responsive.width(0.05),
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
        SizedBox(height: responsive.height(0.006)),
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: true,
          style: TextStyle(
            color: AppTheme.black,
          ),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(
              vertical: responsive.padding(20),
              horizontal: responsive.padding(20),
            ),
            hintText: 'Confirm password',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
              borderSide: const BorderSide(color: AppTheme.orange),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
              borderSide: const BorderSide(color: AppTheme.orange),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
              borderSide: const BorderSide(
                color: AppTheme.orange,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
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
