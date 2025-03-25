// screens/order_details_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../utils/responsive_sizing.dart';
import '../utils/theme.dart';
import '../widgets/widgets.dart';
import '../models/order_model.dart';
import '../providers/providers.dart';

class OrderDetailsScreen extends ConsumerWidget {
  final String orderId;

  const OrderDetailsScreen({
    Key? key,
    required this.orderId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsyncValue = ref.watch(orderDetailsProvider(orderId));
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);
    final dateFormat = DateFormat('dd MMM yyyy');

    // Initialize responsive sizing
    ResponsiveSizing().init(context);
    final responsive = ResponsiveSizing();

    return Scaffold(
      appBar: SimpleAppBar(title: 'Order Details'),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: responsive.padding(23),
            right: responsive.padding(23),
            bottom: responsive.padding(23),
          ),
          child: orderAsyncValue.when(
            loading: () => OrderDetailsShimmer(),
            error: (error, stack) => Center(child: Text('Error: $error')),
            data: (order) {
              if (order == null) {
                return const Center(child: Text('Order not found'));
              }

              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Order ID and Status
                          Row(
                            children: [
                              Text(
                                'Order Id: ',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w600,
                                  fontSize: responsive.textSize(19),
                                ),
                              ),
                              Text(
                                '#${order.id}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.black,
                                  fontSize: responsive.textSize(19),
                                ),
                              ),
                            ],
                          ),

                          Row(
                            children: [
                              Text(
                                'Status: ',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w600,
                                  fontSize: responsive.textSize(15),
                                ),
                              ),
                              SizedBox(
                                height: responsive.height(0.023),
                              ),
                              Text(
                                order.status.displayName,
                                style: TextStyle(
                                  color: order.status.color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: responsive.textSize(15),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(
                            height: responsive.height(0.025),
                          ),
                          Text(
                            'Items',
                            style: TextStyle(
                              color: AppTheme.black,
                              fontWeight: FontWeight.bold,
                              fontSize: responsive.textSize(20),
                            ),
                          ),
                          SizedBox(height: responsive.height(0.01)),

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
                                      height: responsive.height(0.08),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        image: DecorationImage(
                                          image: AssetImage(item.imageUrl),
                                          fit: BoxFit.cover,
                                        ),
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
                                                item.name,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize:
                                                      responsive.textSize(15),
                                                  color: AppTheme.black,
                                                ),
                                              ),
                                              Text(
                                                'Rs. ${item.pricePerKg}/kg',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  color: AppTheme.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: responsive.height(0.012),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                currencyFormat
                                                    .format(item.total),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: AppTheme.orange,
                                                ),
                                              ),
                                              Text(
                                                'Qty: ${item.quantity}',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w700,
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
                            height: responsive.height(0.016),
                          ),
                          const Divider(
                            color: Colors.grey,
                          ),
                          SizedBox(
                            height: responsive.height(0.016),
                          ),

                          // Subtotal
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                '${currencyFormat.format(order.subTotal)}/-',
                                style: TextStyle(
                                  color: AppTheme.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: responsive.textSize(20),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom action buttons
                  if (order.status != OrderStatus.cancel &&
                      order.status != OrderStatus.paid)
                    SizedBox(
                      height: responsive.height(0.08),
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () =>
                            _confirmCancelOrder(context, ref, orderId),
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
    );
  }

  void _confirmCancelOrder(
      BuildContext context, WidgetRef ref, String orderId) {
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
            decoration: InputDecoration(
              hintStyle: TextStyle(
                fontSize: responsive.textSize(15),
              ),
              hintText: 'Type something...',
              alignLabelWithHint: true,
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
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                print('User Input: $_cancelReason');

                Navigator.pop(context);

                // Cancel order
                final result =
                    await ref.read(cancelOrderProvider(orderId).future);

                // Show result
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      result
                          ? 'Order cancelled successfully'
                          : 'Failed to cancel order',
                    ),
                    backgroundColor: result ? Colors.green : Colors.red,
                  ),
                );

                // Navigate back to orders list if successful
                if (result) {
                  context.go('/');
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
