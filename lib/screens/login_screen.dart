import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/providers.dart';
import '../utils/responsive_sizing.dart';
import '../utils/theme.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _mobileController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // Initialize responsive sizing
    ResponsiveSizing().init(context);
    final responsive = ResponsiveSizing();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: responsive.padding(30),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: responsive.height(0.08),
                ),
                // Logo
                Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: responsive.width(0.4),
                  ),
                ),
                SizedBox(
                  height: responsive.height(0.06),
                ),
                // Login Title
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Login',
                    style: TextStyle(
                      fontSize: responsive.textSize(30),
                      fontWeight: FontWeight.bold,
                      color: AppTheme.black,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'to start shopping',
                    style: TextStyle(
                      fontSize: responsive.textSize(14),
                      color: AppTheme.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(
                  height: responsive.height(0.025),
                ),
                // Mobile Number Field
                TextFormField(
                  controller: _mobileController,
                  maxLength: 10,
                  keyboardType: TextInputType.phone,
                  style: TextStyle(
                    color: AppTheme.black,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    contentPadding: EdgeInsets.symmetric(
                      vertical: responsive.padding(20),
                      horizontal: responsive.padding(20),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(11),
                      borderSide: const BorderSide(
                        color: AppTheme.orange,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(11),
                      borderSide: const BorderSide(
                        color: AppTheme.orange,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(11),
                      borderSide: BorderSide(
                        color: AppTheme.orange,
                        width: 2,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(11),
                      borderSide: const BorderSide(
                        color: Colors.red,
                      ),
                    ),
                    prefixIcon: SizedBox(
                      width: responsive.width(0.05),
                      child: Center(
                        child: Image.asset(
                          'assets/icons/phone_login.png',
                          scale: 1.7,
                        ),
                      ),
                    ),
                    hintText: 'Mobile number',
                  ),
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

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
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
                      borderSide: const BorderSide(
                        color: AppTheme.orange,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(11),
                      borderSide: const BorderSide(
                        color: AppTheme.orange,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(11),
                      borderSide: BorderSide(
                        color: AppTheme.orange,
                        width: 2,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(11),
                      borderSide: const BorderSide(color: Colors.red),
                    ),
                    prefixIcon: SizedBox(
                      width: responsive.width(0.05),
                      child: Center(
                        child: Image.asset(
                          'assets/icons/lock_login.png',
                          scale: 1.7,
                        ),
                      ),
                    ),
                    suffixIcon: IconButton(
                      icon: Image.asset(
                        _obscurePassword
                            ? 'assets/icons/eye_close.png'
                            : 'assets/icons/eye_open.png',
                        width: responsive.width(0.05),
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    hintText: 'Password',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters long';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      context.push('/forgot-password');
                    },
                    child: Text(
                      'Forgot password?',
                      style: TextStyle(
                        color: AppTheme.orange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: responsive.height(0.075),
                  child: ElevatedButton(
                    onPressed: authState.isLoading
                        ? null
                        : () async {
                            if (_formKey.currentState!.validate()) {
                              // Handle login logic here
                              final authNotifier =
                                  ref.read(authProvider.notifier);

                              await authNotifier.login(
                                context,
                                _mobileController.text,
                                _passwordController.text,
                              );

                              ref.read(selectedIndexProvider.notifier).state =
                                  0;
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          authState.isLoading ? AppTheme.grey : AppTheme.orange,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppTheme.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11),
                      ),
                    ),
                    child: authState.isLoading
                        ? SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                SizedBox(
                  height: responsive.height(0.04),
                ),
                // Register Now
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account? ",
                      style: TextStyle(
                        color: AppTheme.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        context.push('/register');
                      },
                      child: Text(
                        'Register Now',
                        style: TextStyle(
                          color: AppTheme.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 150,
                ),
                GestureDetector(
                  onTap: () {
                    context.go('/');
                  },
                  child: Text(
                    'Return to Home',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.orange,
                    ),
                  ),
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
}
