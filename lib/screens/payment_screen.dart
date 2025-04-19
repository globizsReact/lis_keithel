import 'dart:convert';

import 'package:drop_shadow/drop_shadow.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import '../utils/config.dart';
import '../utils/responsive_sizing.dart';
import '../widgets/widgets.dart';
import '../utils/theme.dart';
import '../providers/providers.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  final String orderId;
  final String razorpayId;
  final String amount;
  final String razorpayKey;
  final String text;

  const PaymentScreen({
    Key? key,
    required this.orderId,
    required this.razorpayId,
    required this.amount,
    required this.razorpayKey,
    required this.text,
  }) : super(key: key);

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  // Razorpay? _razorpay;
  Razorpay _razorpay = Razorpay();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    // // Start payment process after a short delay
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _startPayment();
    // });
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _startPayment() {
    setState(() {
      _isProcessing = true;
    });

    var options = {
      'key': widget.razorpayKey,
      'amount': widget.amount * 100, // Convert to paise
      'name': 'Lis Keithel',
      'timeout': 60 * 5,
      'order_id': widget.razorpayId,
      'description': 'Order #${widget.orderId}',
      'prefill': {'contact': '', 'email': ''}
    };

    try {
      _razorpay!.open(options);
    } catch (e) {
      CustomToast.show(
        context: context,
        message: 'Error: ${e.toString()}',
        icon: Icons.check,
        backgroundColor: AppTheme.red,
        textColor: Colors.white,
        fontSize: 16.0,
        gravity: ToastGravity.CENTER,
        duration: Duration(seconds: 2),
      );

      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _handlePaymentSuccess(
    PaymentSuccessResponse response,
  ) async {
    // Show success toast
    CustomToast.show(
      context: context,
      message: 'Payment Successful',
      icon: Icons.check,
      backgroundColor: AppTheme.green,
      textColor: Colors.white,
      fontSize: 16.0,
      gravity: ToastGravity.CENTER,
      duration: Duration(seconds: 2),
    );

    // Prepare the API request body
    final Map<String, dynamic> requestBody = {
      "razor_order_id": response.orderId,
      "razor_payment_id": response.paymentId,
      "razor_signature": response.signature,
      "payment_status": 1, // Assuming 1 means success
    };

    try {
      // Make the POST request to your API endpoint
      final baseUrl = Config.baseUrl;

      final url = Uri.parse('$baseUrl/onlinepayments/updateonlinepayment');

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        throw Exception('Token not found in SharedPreferences');
      }

      final apiResponse = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'token': token,
        },
        body: jsonEncode(requestBody),
      );

      // Check if the API call was successful
      if (apiResponse.statusCode == 200) {
        final responseBody = jsonDecode(apiResponse.body);

        // Verify the response from the server
        if (responseBody['reply'] == 'Saved') {
          // Navigate to the order confirmation screen
          context.go('/');
          ref.read(selectedIndexProvider.notifier).state = 2;
          context.push('/order-details/${widget.orderId}');
        } else {
          CustomToast.show(
            context: context,
            message: 'Failed to save payment details.',
            icon: Icons.error,
            backgroundColor: AppTheme.red,
            textColor: Colors.white,
            fontSize: 16.0,
            gravity: ToastGravity.CENTER,
            duration: Duration(seconds: 2),
          );
        }
      } else {
        CustomToast.show(
          context: context,
          message: 'Failed to save payment details. Please try again.',
          icon: Icons.error,
          backgroundColor: AppTheme.red,
          textColor: Colors.white,
          fontSize: 16.0,
          gravity: ToastGravity.CENTER,
          duration: Duration(seconds: 2),
        );
      }
    } catch (e) {
      // Handle any errors during the API call
      debugPrint('Error while saving payment details: $e');
      CustomToast.show(
        context: context,
        message: 'An error occurred. Please try again.',
        icon: Icons.error,
        backgroundColor: AppTheme.red,
        textColor: Colors.white,
        fontSize: 16.0,
        gravity: ToastGravity.CENTER,
        duration: Duration(seconds: 2),
      );
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    CustomToast.show(
      context: context,
      message: 'Payment Failed: ${response.message}',
      icon: Icons.error,
      backgroundColor: AppTheme.red,
      textColor: Colors.white,
      fontSize: 16.0,
      gravity: ToastGravity.CENTER,
      duration: Duration(seconds: 2),
    );

    setState(() {
      _isProcessing = false;
    });
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    CustomToast.show(
      context: context,
      message: 'External Wallet Selected: ${response.walletName}',
      icon: Icons.error,
      backgroundColor: AppTheme.navy,
      textColor: Colors.white,
      fontSize: 16.0,
      gravity: ToastGravity.CENTER,
      duration: Duration(seconds: 2),
    );

    setState(() {
      _isProcessing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
// Initialize responsive sizing
    ResponsiveSizing().init(context);
    final responsive = ResponsiveSizing();

    return Scaffold(
      appBar: SimpleAppBar(title: 'Payment'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: responsive.height(0.05)),
          Text(
            'Order #${widget.orderId} \nCreated Successfully',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.green,
              fontSize: 28,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
          SizedBox(height: responsive.height(0.02)),
          DropShadow(
            blurRadius: 10,
            offset: const Offset(5, 5),
            color: Colors.black.withOpacity(0.5),
            child: Image.asset(
              'assets/icons/pay.png',
              width: responsive.width(0.5),
            ),
          ),
          SizedBox(height: responsive.height(0.025)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '₹',
                style: TextStyle(
                  color: AppTheme.orange,
                  fontSize: 60,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 6),
              Text(
                widget.amount,
                style: TextStyle(
                  color: AppTheme.orange,
                  fontSize: 60,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Text(
              widget.text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: responsive.textSize(14),
                color: AppTheme.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: responsive.height(0.025)),
          SizedBox(
            width: 170,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.green,
                disabledBackgroundColor: AppTheme.grey,
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.padding(23),
                  vertical: responsive.padding(11),
                ),
              ),
              onPressed: _isProcessing ? null : _startPayment,
              child: _isProcessing
                  ? SizedBox(
                      height: 23,
                      width: 23,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                  : Text('Make payment'),
            ),
          ),
        ],
      ),
      // child: Column(
      //   mainAxisAlignment: MainAxisAlignment.center,
      //   children: [
      //     if (_isProcessing) const CircularProgressIndicator(),
      //     const SizedBox(height: 20),
      //     Text(
      //       _isProcessing
      //           ? 'Processing payment...'
      //           : 'Payment gateway initialization failed',
      //       style: const TextStyle(fontSize: 18),
      //     ),
      //     const SizedBox(height: 20),
      //     if (!_isProcessing)
      //       ElevatedButton(
      //         onPressed: _startPayment,
      //         child: const Text('Retry Payment'),
      //       ),
      //   ],
      // ),
    );
  }
}

// Then add the order confirmation screen too
// class OrderConfirmationScreen extends StatelessWidget {
//   final String orderId;

//   const OrderConfirmationScreen({
//     Key? key,
//     required this.orderId,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Order Confirmed'),
//         automaticallyImplyLeading: false,
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(
//               Icons.check_circle_outline,
//               color: AppTheme.green,
//               size: 100,
//             ),
//             const SizedBox(height: 20),
//             const Text(
//               'Thank You!',
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 10),
//             Text(
//               'Your order #$orderId has been placed successfully.',
//               textAlign: TextAlign.center,
//               style: const TextStyle(fontSize: 16),
//             ),
//             const SizedBox(height: 40),
//             ElevatedButton(
//               onPressed: () => context.go('/orders'),
//               child: const Text('View My Orders'),
//             ),
//             const SizedBox(height: 15),
//             TextButton(
//               onPressed: () => context.go('/'),
//               child: const Text('Continue Shopping'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
