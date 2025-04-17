import 'package:flutter/material.dart';
import 'package:lis_keithel/utils/responsive_sizing.dart';
import 'package:lis_keithel/widgets/simple_app_bar.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:lis_keithel/utils/theme.dart';

class PaymentScreen extends StatefulWidget {
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
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
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
      'timeout': 60,
      'order_id': widget.razorpayId,
      'description': 'Order #${widget.orderId}',
      'prefill': {'contact': '', 'email': ''}
    };

    try {
      _razorpay!.open(options);
    } catch (e) {
      _showToast('Error: ${e.toString()}', AppTheme.red);
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    _showToast('Payment Successful', AppTheme.green);
    // Navigate to order confirmation screen
    context.go('/order-confirmation/${widget.orderId}');
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    _showToast('Payment Failed: ${response.message}', AppTheme.red);
    setState(() {
      _isProcessing = false;
    });
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    _showToast(
        'External Wallet Selected: ${response.walletName}', AppTheme.navy);
    setState(() {
      _isProcessing = false;
    });
  }

  void _showToast(String message, Color backgroundColor) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      backgroundColor: backgroundColor,
      textColor: AppTheme.white,
    );
  }

  @override
  Widget build(BuildContext context) {
// Initialize responsive sizing
    ResponsiveSizing().init(context);
    final responsive = ResponsiveSizing();

    return Scaffold(
      appBar: SimpleAppBar(title: 'Payment'),
      body: Column(
        // mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: responsive.height(0.1)),
          Image.asset(
            'assets/icons/pay.png',
            width: responsive.width(0.5),
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
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.padding(23),
                  vertical: responsive.padding(11),
                ),
              ),
              onPressed: _isProcessing ? null : _startPayment,
              child: _isProcessing
                  ? SizedBox(
                      height: 24,
                      width: 24,
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
