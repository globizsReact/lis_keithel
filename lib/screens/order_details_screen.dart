// screens/order_details_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lis_keithel_v1/utils/theme.dart';
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

    return Scaffold(
      appBar: SimpleAppBar(title: 'Order Details'),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(left: 24, right: 24, bottom: 24),
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
                                  fontSize: 20,
                                ),
                              ),
                              Text(
                                '#${order.id}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.black,
                                  fontSize: 20,
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
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                order.status.displayName,
                                style: TextStyle(
                                  color: order.status.color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),
                          const Text(
                            'Items',
                            style: TextStyle(
                              color: AppTheme.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Item list
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: order.items.length,
                            itemBuilder: (context, index) {
                              final item = order.items[index];
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5.0),
                                child: Row(
                                  children: [
                                    // Item image
                                    Container(
                                      width: 70,
                                      height: 70,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        image: DecorationImage(
                                          image: AssetImage(item.imageUrl),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),

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
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
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
                                            height: 10,
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

                          const SizedBox(height: 16),
                          const Divider(
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),

                          // Subtotal
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Sub Total',
                                style: TextStyle(
                                  color: AppTheme.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                              Text(
                                '${currencyFormat.format(order.subTotal)}/-',
                                style: const TextStyle(
                                  color: AppTheme.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
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
                      height: 60,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () =>
                            _confirmCancelOrder(context, ref, orderId),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Cancel order',
                          style: TextStyle(
                            fontSize: 16,
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

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0), // Set border radius here
        ),
        title: const Text(
          'Please enter a reason to initiate cancellation of this order',
          style: TextStyle(
            color: AppTheme.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Form(
          key: _formKey, // Attach the form key
          child: TextFormField(
            decoration: InputDecoration(
              hintStyle: TextStyle(
                fontSize: 15,
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
