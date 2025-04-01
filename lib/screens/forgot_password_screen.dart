import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:lis_keithel/providers/auth_provider.dart';
import '../utils/responsive_sizing.dart';
import '../utils/theme.dart';
import '../widgets/widgets.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mobileController = TextEditingController();
  final _otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _mobileController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _forgotPassword() {
    if (_formKey.currentState!.validate()) {
      final authNotifier = ref.read(authProvider.notifier);

      authNotifier.forgotPassword(
        context,
        _mobileController.text.trim(),
      );
    }
  }

  void _verifyOTP() {
    final otp = _otpController.text.trim();

    if (otp.length == 6) {
      final authNotifier = ref.read(authProvider.notifier);
      final isValid = authNotifier.verifyOtp(otp);

      if (isValid) {
        GoRouter.of(context).push('/reset-password');
      } else {
        Fluttertoast.showToast(
          msg: 'Invalid OTP. Please try again.',
          backgroundColor: AppTheme.red,
          textColor: AppTheme.white,
          gravity: ToastGravity.CENTER,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Initialize responsive sizing
    ResponsiveSizing().init(context);
    final responsive = ResponsiveSizing();
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: SimpleAppBar(title: 'Forgot Password'),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: responsive.padding(23),
            right: responsive.padding(23),
            bottom: responsive.padding(24),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Enter your register mobile number to change your password',
                          style: TextStyle(
                            fontSize: responsive.textSize(14),
                            color: AppTheme.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: responsive.height(0.012),
                      ),
                      // Mobile TextField
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
                            borderSide:
                                const BorderSide(color: AppTheme.orange),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(11),
                            borderSide:
                                const BorderSide(color: AppTheme.orange),
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

                      if (authState.isOtpSent) ...[
                        SizedBox(
                          height: responsive.height(0.01),
                        ),
                        // OTP TextField
                        TextFormField(
                          controller: _otpController,
                          maxLength: 6,
                          style: TextStyle(
                            color: AppTheme.black,
                          ),
                          decoration: InputDecoration(
                            counterText: '',
                            contentPadding: EdgeInsets.symmetric(
                              vertical: responsive.padding(20),
                              horizontal: responsive.padding(20),
                            ),
                            hintText: 'Enter OTP',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(11),
                              borderSide:
                                  const BorderSide(color: AppTheme.orange),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(11),
                              borderSide:
                                  const BorderSide(color: AppTheme.orange),
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
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the OTP';
                            }
                            if (!RegExp(r'^\d{6}$').hasMatch(value)) {
                              return 'Please enter a valid 6-digit OTP';
                            }
                            return null;
                          },
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  height: responsive.height(0.075),
                  child: ElevatedButton(
                    onPressed:
                        authState.isOtpSent ? _verifyOTP : _forgotPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          authState.isLoading ? AppTheme.grey : AppTheme.orange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: authState.isLoading
                        ? SizedBox(
                            height: 25,
                            width: 25,
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            authState.isOtpSent ? 'Verify OTP' : 'Send OTP',
                            style: TextStyle(
                              fontSize: responsive.textSize(17),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
