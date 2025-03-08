// lib/widgets/quantity_selector.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lis_keithel_v1/utils/theme.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';

class QuantitySelector extends ConsumerStatefulWidget {
  final Product product;

  const QuantitySelector({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  ConsumerState<QuantitySelector> createState() => _QuantitySelectorState();
}

class _QuantitySelectorState extends ConsumerState<QuantitySelector> {
  int quantity = 1;
  final int minQuantity = 1;
  final int maxQuantity = 99;

  void _incrementQuantity() {
    if (quantity < maxQuantity) {
      setState(() {
        quantity++;
      });
    }
  }

  void _decrementQuantity() {
    if (quantity > minQuantity) {
      setState(() {
        quantity--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Add to cart',
                style: const TextStyle(
                  fontSize: 21,
                  color: AppTheme.black,
                  fontWeight: FontWeight.w900,
                ),
              ),
              IconButton(
                icon: Text(
                  'close',
                  style: TextStyle(
                    color: AppTheme.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                  13), // Adjust the radius value as needed
              color: AppTheme.lightOrange, // Optional: add background color
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    widget.product.imageUrl,
                    width: 70,
                    height: 75,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(
                  width: 15,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.product.name,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppTheme.black,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Rs. ${widget.product.price.toStringAsFixed(2)}/kg',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.orange,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Quantity',
                style: const TextStyle(
                  fontSize: 16,
                  color: AppTheme.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.orange),
                    borderRadius: BorderRadius.circular(8)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Minus button
                    _buildQuantityButton(
                      onPressed: _decrementQuantity,
                      icon: Icons.remove,
                      isEnabled: quantity > minQuantity,
                    ),

                    // Quantity display
                    Container(
                      width: 80,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: Text(
                        quantity.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppTheme.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // Plus button
                    _buildQuantityButton(
                      onPressed: _incrementQuantity,
                      icon: Icons.add,
                      isEnabled: quantity < maxQuantity,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
          // Subtotal display

          // Add to cart button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.orange,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () {
                // Add to cart
                ref
                    .read(cartProvider.notifier)
                    .addItem(widget.product, quantity);

                // Close bottom sheet and show confirmation
                Navigator.pop(context);

                // Show snackbar
                // ScaffoldMessenger.of(context).showSnackBar(
                //   SnackBar(
                //     content: Text(
                //         '${widget.product.name} (x$quantity) added to cart'),
                //     backgroundColor: Colors.green,
                //     duration: const Duration(seconds: 2),
                //   ),
                // );

                Fluttertoast.showToast(
                  msg:
                      '${widget.product.name} (x$quantity) added to cart', // Message to display
                  toastLength: Toast.LENGTH_SHORT, // Duration of the toast
                  gravity: ToastGravity.TOP, // Position the toast at the top
                  backgroundColor:
                      Colors.green, // Background color of the toast
                  textColor: Colors.white, // Text color
                  fontSize: 16.0, // Font size
                );
              },
              child: Text(
                'Add to Cart  Rs.${(widget.product.price * quantity).toStringAsFixed(2)}/-',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // Add padding for bottom safe area
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildQuantityButton({
    required VoidCallback onPressed,
    required IconData icon,
    required bool isEnabled,
  }) {
    return InkWell(
      onTap: isEnabled ? onPressed : null,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          border: Border(),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isEnabled ? Colors.black : Colors.grey,
        ),
      ),
    );
  }
}

// Helper method to show the quantity selector bottom sheet
Future<void> showQuantitySelector(BuildContext context, Product product) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => QuantitySelector(product: product),
  );
}
