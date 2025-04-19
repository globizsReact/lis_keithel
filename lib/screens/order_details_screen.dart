// screens/order_details_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../providers/providers.dart';
import '../utils/responsive_sizing.dart';
import '../utils/theme.dart';
import '../widgets/widgets.dart';

class OrderDetailsScreen extends ConsumerStatefulWidget {
  final String orderId;

  const OrderDetailsScreen({
    Key? key,
    required this.orderId,
  }) : super(key: key);

  @override
  _OrderDetailsScreenState createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends ConsumerState<OrderDetailsScreen> {
  bool _isLoading = false;

  @override
  Widget build(
    BuildContext context,
  ) {
    final orderAsyncValue = ref.watch(orderDetailsProvider(widget.orderId));
    final dateFormat = DateFormat('dd MMM yyyy');

    // Initialize responsive sizing
    ResponsiveSizing().init(context);
    final responsive = ResponsiveSizing();

    return Scaffold(
      appBar: SimpleAppBar(title: 'Order Details'),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                left: 25,
                right: 25,
                bottom: 25,
              ),
              child: orderAsyncValue.when(
                loading: () => OrderDetailsShimmer(),
                error: (error, stack) => Center(child: Text('Error: $error')),
                data: (order) {
                  if (order == null) {
                    return Center(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/icons/orderE.png',
                          width: responsive.width(0.2),
                          gaplessPlayback: true,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          'Order not found',
                          style: TextStyle(
                            fontSize: responsive.textSize(12),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                      ],
                    ));
                  }

                  return Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    '#${widget.orderId}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.orange,
                                      fontSize: responsive.textSize(19),
                                    ),
                                  ),
                                  SizedBox(width: 15),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: order.statusColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(
                                        15,
                                      ),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 2,
                                    ),
                                    child: Text(
                                      order.status.toUpperCase(),
                                      style: TextStyle(
                                        color: order.statusColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                order.date,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: responsive.textSize(13),
                                ),
                              ),

                              SizedBox(
                                height: 17,
                              ),

                              // Payment info
                              Row(
                                children: [
                                  Image.asset(
                                    'assets/icons/payment.png',
                                    width: responsive.width(0.035),
                                    gaplessPlayback: true,
                                  ),
                                  SizedBox(
                                    width: responsive.width(0.015),
                                  ),
                                  Text(
                                    'Payment info',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: responsive.textSize(13),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 2,
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Mode: ',
                                    style: TextStyle(
                                      color: AppTheme.black,
                                      fontWeight: FontWeight.w500,
                                      fontSize: responsive.textSize(16),
                                    ),
                                  ),
                                  Text(
                                    order.paymentMode.toUpperCase(),
                                    style: TextStyle(
                                      color: AppTheme.green,
                                      fontWeight: FontWeight.w700,
                                      fontSize: responsive.textSize(16),
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(
                                height: 17,
                              ),

                              // Delivery Info
                              Row(
                                children: [
                                  Image.asset(
                                    'assets/icons/truck.png',
                                    width: responsive.width(0.045),
                                    gaplessPlayback: true,
                                  ),
                                  SizedBox(
                                    width: responsive.width(0.015),
                                  ),
                                  Text(
                                    'Delivery Info',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: responsive.textSize(13),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 2,
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Date: ',
                                    style: TextStyle(
                                      color: AppTheme.black,
                                      fontWeight: FontWeight.w500,
                                      fontSize: responsive.textSize(16),
                                    ),
                                  ),
                                  Text(
                                    dateFormat.format(order.delDate),
                                    style: TextStyle(
                                      color: AppTheme.black,
                                      fontWeight: FontWeight.w700,
                                      fontSize: responsive.textSize(16),
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(
                                height: 22,
                              ),
                              Text(
                                'Item Details (${order.items.length} ${order.items.length > 1 ? 'items' : 'item'})',
                                style: TextStyle(
                                  color: AppTheme.grey,
                                  fontWeight: FontWeight.w600,
                                  fontSize: responsive.textSize(16),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),

                              // Item list
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: order.items.length,
                                itemBuilder: (context, index) {
                                  final item = order.items[index];
                                  return Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: responsive.padding(5.0)),
                                    child: Row(
                                      children: [
                                        // Item image
                                        Container(
                                          width: responsive.width(0.2),
                                          height: 70,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            image: DecorationImage(
                                              image: AssetImage(
                                                  'assets/images/placeholder.png'),
                                              fit: BoxFit.cover,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color:
                                                    Colors.black.withAlpha(20),
                                                blurRadius: 5.0,
                                                offset: const Offset(0, 5),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          width: responsive.width(0.03),
                                        ),

                                        // Item details
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    item.product,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: responsive
                                                          .textSize(15),
                                                      color: AppTheme.black,
                                                    ),
                                                  ),
                                                  Text(
                                                    'Rs. ${item.amount}/kg',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: AppTheme.grey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 12,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    'Rs. ${(double.parse(item.amount) * double.parse(item.quantity)).toStringAsFixed(2)}/-',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: AppTheme.orange,
                                                    ),
                                                  ),
                                                  Text(
                                                    'Qty: ${item.quantity}',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: AppTheme.grey,
                                                    ),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),

                              SizedBox(
                                height: 16,
                              ),
                              const Divider(
                                color: Colors.grey,
                              ),
                              SizedBox(
                                height: 16,
                              ),

                              // Subtotal
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Sub Total',
                                    style: TextStyle(
                                      color: AppTheme.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: responsive.textSize(20),
                                    ),
                                  ),
                                  Text(
                                    'Rs. ${order.formattedTotalAmount}/-',
                                    style: TextStyle(
                                      color: AppTheme.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: responsive.textSize(20),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 18,
                              ),
                              if (order.status == 'Cancel')
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Cancel Remark',
                                      style: TextStyle(
                                        color: AppTheme.red,
                                        fontWeight: FontWeight.w600,
                                        fontSize: responsive.textSize(16),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      order.cancelRemark,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: responsive.textSize(14),
                                      ),
                                    )
                                  ],
                                )
                            ],
                          ),
                        ),
                      ),

                      // Bottom action buttons
                      if (order.status != 'Cancel')
                        SizedBox(
                          height: 60,
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _confirmCancelOrder(
                                context, ref, widget.orderId, order.canCancel),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.orange,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Cancel order',
                              style: TextStyle(
                                fontSize: responsive.textSize(16),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
          // Global loading indicator
          if (_isLoading)
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey
                          .withOpacity(0.5), // Shadow color with opacity
                      spreadRadius:
                          5, // Spread radius (how far the shadow spreads)
                      blurRadius: 7, // Blur radius (how blurry the shadow is)
                      offset: Offset(0, 3), // Offset in x and y direction
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Cancelling orders...',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            )
        ],
      ),
    );
  }

  void _confirmCancelOrder(
    BuildContext context,
    WidgetRef ref,
    String orderId,
    String canCancel,
  ) {
    final _formKey = GlobalKey<FormState>();
    String? _cancelReason;

    // Initialize responsive sizing
    ResponsiveSizing().init(context);
    final responsive = ResponsiveSizing();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0), // Set border radius here
        ),
        title: Text(
          'Please provide a reason to cancel this order.',
          style: TextStyle(
            color: AppTheme.black,
            fontSize: responsive.textSize(18),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Form(
          key: _formKey, // Attach the form key
          child: TextFormField(
            style: TextStyle(
              color: AppTheme.black,
            ),
            decoration: InputDecoration(
              hintStyle: TextStyle(
                fontSize: responsive.textSize(15),
                color: AppTheme.grey,
              ),
              hintText: 'Type something...',
              // alignLabelWithHint: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.orange),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.orange),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppTheme.orange,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.red),
              ),
            ),
            textAlign: TextAlign.start,
            maxLines: 4, // Make it a multi-line text area
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'This field is required';
              }
              return null; // Validation passes
            },
            onSaved: (value) {
              _cancelReason = value; // Save the user input
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (_formKey.currentState!.validate() && canCancel == '1') {
                _formKey.currentState!.save();
                debugPrint('User Input: $_cancelReason');

                context.pop();

                // Show global loading indicator
                setState(() {
                  _isLoading = true;
                });

                // Cancel order
                final result = await ref.read(cancelOrderProvider((
                  orderId: orderId,
                  status: _cancelReason!,
                )).future);

                // Hide global loading indicator
                setState(() {
                  _isLoading = false;
                });

                if (result) {
                  // Refresh order details data after successful cancellation
                  ref.refresh(orderDetailsProvider(widget.orderId));

                  // Optional: Show toast message
                  Fluttertoast.showToast(
                    msg: 'Order cancelled successfully',
                    backgroundColor: AppTheme.green,
                    textColor: AppTheme.white,
                    gravity: ToastGravity.CENTER,
                  );
                } else {
                  Fluttertoast.showToast(
                    msg: 'Failed to cancel order',
                    backgroundColor: AppTheme.red,
                    textColor: AppTheme.white,
                    gravity: ToastGravity.CENTER,
                  );
                }
              }
            },
            child: const Text(
              'Confirm',
              style: TextStyle(
                color: AppTheme.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
