// Example of using the OTP screen from a forgot password screen
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lis_keithel_v1/screens/screens.dart';
import 'package:lis_keithel_v1/utils/theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isButtonEnabled = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _phoneController.addListener(_validateInput);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  // Validate input and enable/disable the button
  void _validateInput() {
    final phoneNumber = _phoneController.text.trim();
    setState(() {
      // Enable button only if the phone number is exactly 10 digits
      _isButtonEnabled = phoneNumber.length == 10 && isNumeric(phoneNumber);
    });
  }

  // Helper function to check if the input is numeric
  bool isNumeric(String str) {
    // Check if the string contains only numeric characters
    return RegExp(r'^\d+$').hasMatch(str);
  }

  void _resetPassword() {
    // Validate inputs and submit password reset request
    final phoneNumber = _phoneController.text.trim();

    if (phoneNumber.length == 10 && isNumeric(phoneNumber)) {
      // Navigate to OTP screen for verification
      context.go('/otp-verification', extra: {
        'type': OtpScreenType.passwordChange,
        'phoneNumber': phoneNumber,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'),
        titleSpacing: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Expanded(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Enter your register mobile number to change your password',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(
                  counterText: '',
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 20,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: AppTheme.orange,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: AppTheme.orange,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: AppTheme.orange,
                      width: 2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                  hintText: 'Phone number',
                ),
                keyboardType: TextInputType.phone,
                maxLength: 10,
              ),
              Spacer(),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _isButtonEnabled ? _resetPassword : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _isButtonEnabled ? AppTheme.orange : AppTheme.grey,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Send OTP',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      )),
                ),
              ),
              SizedBox(
                height: 30,
              )
            ],
          ),
        ),
      ),
    );
  }
}
