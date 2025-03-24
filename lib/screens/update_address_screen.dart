// Example of using the OTP screen from a forgot password screen
import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../widgets/widgets.dart';

class UpdateAddressScreen extends StatefulWidget {
  const UpdateAddressScreen({Key? key}) : super(key: key);

  @override
  State<UpdateAddressScreen> createState() => UpdateAddressScreenState();
}

class UpdateAddressScreenState extends State<UpdateAddressScreen> {
  final _formKey = GlobalKey<FormState>();

  final _addressController = TextEditingController();

  // phone number from login detaisl
  String phoneNumber = '961562469';

  @override
  void dispose() {
    _addressController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SimpleAppBar(title: 'Update Address'),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(left: 24, right: 24, bottom: 25),
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
                          'Enter your new address',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      // Password TextField
                      TextFormField(
                        controller: _addressController,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 20,
                            horizontal: 20,
                          ),
                          hintText: 'Enter address',
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
                            return 'Please enter your new address';
                          }

                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {}
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.orange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Update',
                        style: TextStyle(
                          fontSize: 18,
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
