import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:lis_keithel/utils/config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/responsive_sizing.dart';
import '../utils/theme.dart';
import '../widgets/widgets.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _passwordVisible = false;

  // Loading state for the button
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _updatePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true; // Show loading state
    });

    final url = Uri.parse('${Config.baseUrl}/clients/client_update_pass');

    // Create the request body
    final requestBody = {
      "Password": _passwordController.text,
    };

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      // Send the POST request
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'token': token!,
        },
        body: jsonEncode(requestBody),
      );

      // Parse the response
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['type'] == 'success') {
          CustomToast.show(
            context: context,
            message: 'Password changed successfully',
            icon: Icons.check,
            backgroundColor: AppTheme.green,
            textColor: Colors.white,
            gravity: ToastGravity.CENTER,
            duration: Duration(seconds: 3),
          );
          context.pop();
        } else {
          // Handle error from API
          Fluttertoast.showToast(
            msg: 'Error: ${responseData['msg']}',
            backgroundColor: AppTheme.red,
            textColor: AppTheme.white,
            gravity: ToastGravity.CENTER,
          );
        }
      } else {
        // Handle HTTP errors
        Fluttertoast.showToast(
          msg: 'Failed to update password. Status code: ${response.statusCode}',
          backgroundColor: AppTheme.red,
          textColor: AppTheme.white,
          gravity: ToastGravity.CENTER,
        );
      }
    } catch (e) {
      // Handle exceptions (e.g., network issues
      Fluttertoast.showToast(
        msg: 'An error occurred: $e',
        backgroundColor: AppTheme.red,
        textColor: AppTheme.white,
        gravity: ToastGravity.CENTER,
      );
    } finally {
      setState(() {
        _isLoading = false; // Hide loading state
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Initialize responsive sizing
    ResponsiveSizing().init(context);
    final responsive = ResponsiveSizing();

    return Scaffold(
      appBar: SimpleAppBar(title: 'Change Password'),
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
                          'Enter your new password',
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
                      // Password TextField
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
                            return 'Please enter a new password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),

                      SizedBox(
                        height: responsive.height(0.01),
                      ),
                      // Confirm Password TextField
                      TextFormField(
                        controller: _confirmPasswordController,
                        style: TextStyle(
                          color: AppTheme.black,
                        ),
                        obscureText: true,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            vertical: responsive.padding(20),
                            horizontal: responsive.padding(20),
                          ),
                          hintText: 'Confirm password',
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
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your new password';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  height: responsive.height(0.07),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _updatePassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _isLoading ? AppTheme.grey : AppTheme.orange,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppTheme.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            height: 25,
                            width: 25,
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                        : Text('Update',
                            style: TextStyle(
                              fontSize: responsive.textSize(17),
                              fontWeight: FontWeight.w600,
                            )),
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
