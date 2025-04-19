import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:lis_keithel/providers/providers.dart';
import 'package:lis_keithel/utils/config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../utils/responsive_sizing.dart';
import '../utils/theme.dart';
import '../widgets/widgets.dart';

class UpdateAddressScreen extends ConsumerStatefulWidget {
  const UpdateAddressScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<UpdateAddressScreen> createState() =>
      UpdateAddressScreenState();
}

class UpdateAddressScreenState extends ConsumerState<UpdateAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  bool _isLoading = false;
  bool _isAddressChanged = false;
  String _originalAddress = '';

  @override
  void initState() {
    super.initState();
    _loadSavedAddress();
    _addressController.addListener(_checkAddressChange);
  }

  @override
  void dispose() {
    _addressController.dispose();
    _addressController.removeListener(_checkAddressChange);
    super.dispose();
  }

  // Load the saved address from shared preferences
  Future<void> _loadSavedAddress() async {
    final prefs = await SharedPreferences.getInstance();
    final savedAddress = prefs.getString('address') ?? '';

    setState(() {
      _addressController.text = savedAddress;
      _originalAddress = savedAddress.trim();
      _isAddressChanged = false;
    });
  }

  // Check if the address has changed
  void _checkAddressChange() {
    final currentAddress = _addressController.text.trim();
    setState(() {
      _isAddressChanged = currentAddress != _originalAddress;
    });
  }

  // Save the updated address to shared preferences
  Future<void> _saveAddress(String address) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('address', address);
  }

  // Call the API to update the address
  Future<bool> _updateAddressAPI(String address) async {
    final url = Uri.parse('${Config.baseUrl}/clients/client_update_address');
    final body = {'Address': address};

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        throw Exception('Token not found in SharedPreferences');
      }

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'token': token,
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['type'] == 'success') {
          return true;
        } else {
          CustomToast.show(
            context: context,
            message: 'Error: ${responseData['msg']}',
            icon: Icons.error,
            backgroundColor: AppTheme.red,
            textColor: Colors.white,
            gravity: ToastGravity.CENTER,
            duration: Duration(seconds: 3),
          );
        }
      } else {
        CustomToast.show(
          context: context,
          message: 'Failed to update address. Try again.',
          icon: Icons.error,
          backgroundColor: AppTheme.red,
          textColor: Colors.white,
          gravity: ToastGravity.CENTER,
          duration: Duration(seconds: 3),
        );
      }
    } catch (e) {
      CustomToast.show(
        context: context,
        message: 'Connections error',
        icon: Icons.signal_wifi_statusbar_connected_no_internet_4,
        backgroundColor: AppTheme.grey,
        textColor: Colors.white,
        gravity: ToastGravity.CENTER,
        duration: Duration(seconds: 3),
      );
    }
    return false;
  }

  // Handle the update process
  Future<void> _updateAddress() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Show loading indicator
      });

      final updatedAddress = _addressController.text.trim();

      // Call the API to update the address
      final success = await _updateAddressAPI(updatedAddress);

      if (success) {
        ref.read(selectedIndexProvider.notifier).state = 0;

        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('address');
        // Save the updated address to shared preferences
        await _saveAddress(updatedAddress);

        CustomToast.show(
          context: context,
          message: 'Address update successfully',
          icon: Icons.check,
          backgroundColor: AppTheme.green,
          textColor: Colors.white,
          gravity: ToastGravity.CENTER,
          duration: Duration(seconds: 3),
        );
        context.pop();
        ref.read(selectedIndexProvider.notifier).state = 3;
      }

      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Initialize responsive sizing
    ResponsiveSizing().init(context);
    final responsive = ResponsiveSizing();

    return Scaffold(
      appBar: SimpleAppBar(title: 'Update Address'),
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
                          'Enter your new address',
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
                      // Address TextField
                      TextFormField(
                        controller: _addressController,
                        maxLines: 3,
                        style: TextStyle(
                          color: AppTheme.black,
                        ),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            vertical: responsive.padding(20),
                            horizontal: responsive.padding(20),
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
                  height: responsive.height(0.07),
                  child: ElevatedButton(
                    onPressed: !_isAddressChanged ? null : _updateAddress,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _isLoading ? AppTheme.grey : AppTheme.orange,
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
                        : Text(
                            'Update',
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
