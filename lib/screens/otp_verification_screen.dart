import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../providers/auth_provider.dart';
import '../utils/responsive_sizing.dart';
import '../utils/theme.dart';
import '../widgets/custom_toast.dart';

enum OtpScreenType { registration, passwordChange }

class OtpVerificationScreen extends ConsumerStatefulWidget {
  final OtpScreenType type;
  final String phoneNumber;
  final Function(String, BuildContext) onVerificationSuccess;
  final Function() onResendOtp;

  const OtpVerificationScreen({
    Key? key,
    required this.type,
    required this.phoneNumber,
    required this.onVerificationSuccess,
    required this.onResendOtp,
  }) : super(key: key);

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  // Controllers for each text field
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());

  bool _isLoading = false;

  bool _isEmpty = false;

  // Focus nodes for each text field
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  // Timer for resend countdown
  Timer? _timer;
  int _secondsRemaining = 35;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _canResend = true;
          _timer?.cancel();
        }
      });
    });
  }

  void resetTimer() {
    setState(() {
      _secondsRemaining = 35;
      _canResend = false;
    });
    startTimer();
  }

  String getOtpString() {
    return _otpControllers.map((controller) => controller.text).join();
  }

  void verifyOtp() {
    final otp = getOtpString();
    if (otp.length == 6) {
      final authNotifier = ref.read(authProvider.notifier);
      final isValid = authNotifier.verifyOtp(otp);

      if (isValid) {
        // If local verification is successful, verify with backend too
        setState(() {
          _isLoading = true;
        });

        authNotifier.verifyOtp(
          otp,
        );

        CustomToast.show(
          context: context,
          message: getScreenTitle(),
          icon: Icons.check,
          backgroundColor: AppTheme.orange,
          textColor: Colors.white,
          fontSize: 16.0,
          gravity: ToastGravity.CENTER,
          duration: Duration(seconds: 3),
        );

        widget.onVerificationSuccess(otp, context);

        setState(() {
          _isLoading = false;
        });
      } else {
        Fluttertoast.showToast(
          msg: 'Invalid OTP. Please try again.',
          backgroundColor: AppTheme.red,
          textColor: AppTheme.white,
        );
      }
    } else {
      setState(() {
        _isEmpty = true;
      });

      Fluttertoast.showToast(
        msg: 'Please enter a valid 6-digit OTP',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.red,
        textColor: AppTheme.white,
      );
    }
  }

  String getScreenTitle() {
    return widget.type == OtpScreenType.registration
        ? "Registered successfully"
        : "Password change successfully";
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Initialize responsive sizing
    ResponsiveSizing().init(context);
    final responsive = ResponsiveSizing();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(responsive.padding(25)),
          child: Column(
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

              // Confirm text
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Confirm OTP',
                  style: TextStyle(
                    fontSize: responsive.textSize(30),
                    fontWeight: FontWeight.bold,
                    color: AppTheme.black,
                  ),
                ),
              ),

              // Instruction text
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '6 digits OTP have sent to your registered mobile number +91 ${widget.phoneNumber}',
                  style: TextStyle(
                    fontSize: responsive.textSize(14),
                    color: AppTheme.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(
                height: responsive.height(0.03),
              ),

              // OTP input fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: responsive.width(0.13),
                    child: TextField(
                      controller: _otpControllers[index],
                      focusNode: _focusNodes[index],
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          vertical: responsive.padding(19),
                          horizontal: responsive.padding(19),
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
                              color: AppTheme.orange, width: 2),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(1),
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      onChanged: (value) {
                        if (value.isNotEmpty && index < 5) {
                          _focusNodes[index + 1].requestFocus();
                        }

                        // Auto-verify when all fields are filled
                        if (index == 5 && value.isNotEmpty) {
                          verifyOtp();
                        }
                      },
                    ),
                  );
                }),
              ),
              SizedBox(
                height: responsive.height(0.015),
              ),

              // Verify button
              SizedBox(
                width: double.infinity,
                height: responsive.height(0.075),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _isLoading ? AppTheme.grey : AppTheme.orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : Text(
                          'Verify',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              SizedBox(
                height: responsive.height(0.01),
              ),

              // Resend timer
              TextButton(
                onPressed: _canResend
                    ? () {
                        widget.onResendOtp();
                        resetTimer();
                      }
                    : null,
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 14, fontFamily: 'Poppins'),
                    children: [
                      const TextSpan(
                        text: 'Resend ',
                        style: TextStyle(
                          color: AppTheme.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(
                        text: _canResend
                            ? ''
                            : 'in ${_secondsRemaining.toString().padLeft(2, '0')}:${0.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
