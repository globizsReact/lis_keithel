import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:lis_keithel/providers/cart_provider.dart';
import 'package:lis_keithel/utils/config.dart';
import 'package:lis_keithel/utils/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GiftCodeField extends ConsumerStatefulWidget {
  const GiftCodeField({Key? key}) : super(key: key);

  @override
  _GiftCodeFieldState createState() => _GiftCodeFieldState();
}

class _GiftCodeFieldState extends ConsumerState<GiftCodeField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isLoading = false;

  String _appliedCouponCode = ''; // Stores the applied coupon code
  String _savedAmount = ''; // Stores the saved amount (e.g., ₹30)
  String _apiResponseMessage = '';

  // Check if the text field is empty
  bool get _isTextFieldEmpty => _controller.text.trim().isEmpty;

  // Function to call the API
  Future<void> _callApi(String couponCode) async {
    final cartItems = ref.watch(cartProvider);

    final loadItems = cartItems.map((item) {
      final quantity = item.product.productTypeId == '2'
          ? item.quantityKg.round() // round to nearest int
          : item.quantityPcs; // already an int

      return {
        "prod_id": int.parse(item.product.id),
        "quantity": quantity,
        "rate": item.product.price.round(), // round price to int if needed
      };
    }).toList();
    setState(() {
      _isLoading = true; // Start loading
      _apiResponseMessage = ''; // Clear previous message
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      throw Exception('Token not found in SharedPreferences');
    }

    try {
      // Define the API endpoint
      const url = '${Config.baseUrl}/salesorders/apply_promo_code';

      // Define the request body
      final Map<String, dynamic> requestBody = {
        "coupon": couponCode,
        "delivery_date": "",
        "load": loadItems,
      };

      // Make the POST request
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'token': token,
        },
        body: jsonEncode(requestBody),
      );

      // Parse the response
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['type'] == 'success') {
          _appliedCouponCode = couponCode;
          _savedAmount = responseData['msg'];
          debugPrint('Save Amount $_savedAmount');
        } else if (responseData['type'] == 'fail') {
          setState(() {
            _apiResponseMessage = 'Error: ${responseData['msg']}';
          });

          Fluttertoast.showToast(
            msg: 'Invalid code',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            backgroundColor: AppTheme.red,
            textColor: AppTheme.white,
          );
        }
      } else {
        Fluttertoast.showToast(
          msg: 'Failed to connect to the server.',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: AppTheme.red,
          textColor: AppTheme.white,
        );
      }
    } catch (e) {
      setState(() {
        _apiResponseMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false; // Stop loading
      });
    }
  }

  // Function to handle the apply button press
  void _onApplyPressed() async {
    if (_isTextFieldEmpty) return;

    await _callApi(_controller.text.trim());
    _focusNode.unfocus();

    ref
        .read(cartProvider.notifier)
        .applyCoupon(double.parse(_savedAmount), _appliedCouponCode);
  }

  // Function to remove the applied coupon
  void _onRemovePressed() {
    setState(() {
      _appliedCouponCode = '';
      _savedAmount = '';
      _controller.clear(); // Clear the input field
    });

    ref.read(cartProvider.notifier).removeCoupon();
  }

  @override
  Widget build(BuildContext context) {
    final cartSummary = ref.watch(cartSummaryProvider);
    final isCouponApplied = cartSummary['isCouponApplied'] as bool;
    return Column(
      children: [
        if (!isCouponApplied)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 2),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(13.0),
            ),
            child: Row(
              children: [
                // Text field takes most of the space
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.black,
                    ),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 14.0),
                      hintText: 'Enter gift card code here',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      hintStyle: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                    onChanged: (_) => setState(() {}), // Update button state
                  ),
                ),

                // Divider line
                Container(
                  width: 1.0,
                  height: 30.0,
                  color: Colors.grey.shade300,
                ),

                // Apply button or loading indicator
                _isLoading
                    ? const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: SizedBox(
                          width: 24.0,
                          height: 24.0,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.orange),
                          ),
                        ),
                      )
                    : TextButton(
                        onPressed: _isTextFieldEmpty ? null : _onApplyPressed,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          minimumSize: const Size(80, 48),
                          foregroundColor: AppTheme.orange,
                        ),
                        child: const Text(
                          'Apply',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
              ],
            ),
          )
        else
          // Display applied coupon message and Remove button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Image.asset(
                    'assets/icons/gift.png',
                    width: 40,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            _appliedCouponCode.toUpperCase(),
                            style: const TextStyle(
                              color: AppTheme.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                          Text(
                            ' Applied',
                            style: const TextStyle(
                              color: AppTheme.black,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'You saved ₹$_savedAmount',
                        style: TextStyle(
                          color: AppTheme.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                onPressed: _onRemovePressed,
                icon: const Icon(
                  Icons.close,
                  color: AppTheme.red,
                ),
              )
            ],
          ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // Clean up the controller
    super.dispose();
  }
}
