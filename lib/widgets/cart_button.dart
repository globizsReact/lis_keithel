// lib/widgets/cart_button.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/cart_provider.dart';

class CartSummary extends ConsumerWidget {
  const CartSummary({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartSummary = ref.watch(cartSummaryProvider);
    final itemCount = cartSummary['itemCount'] as int;
    final totalAmount = cartSummary['totalAmount'] as double;

    if (itemCount == 0) {
      return const SizedBox.shrink(); // Hide the cart summary if cart is empty
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.orange,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Proceed',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Row(
            children: [
              Text(
                '$itemCount ${itemCount == 1 ? 'item' : 'items'}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Rs. ${totalAmount.toStringAsFixed(2)}/-',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward,
                color: Colors.white,
                size: 18,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
