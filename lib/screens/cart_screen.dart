// lib/screens/cart_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lis_keithel_v1/providers/selected_index_provider.dart';
import 'package:lis_keithel_v1/utils/theme.dart';
import 'package:lis_keithel_v1/widgets/gift_code_button.dart';
import '../providers/cart_provider.dart';

// Provider to hold the list of predefined delivery dates
final predefinedDatesProvider = Provider<List<String>>((ref) {
  return [
    '10th Mar 2025',
    '15th Mar 2025',
    '16th Mar 2025',
    '20th Mar 2025',
    '25th Mar 2025',
  ];
});

// StateProvider to manage the selected delivery date
final selectedDateProvider = StateProvider<String>((ref) {
  // Default selected date is the first item in the predefined list
  final predefinedDates = ref.watch(predefinedDatesProvider);
  return predefinedDates.first;
});

class CartScreen extends ConsumerWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final cartSummary = ref.watch(cartSummaryProvider);
    final totalAmount = cartSummary['totalAmount'] as double;

    // Access the predefined dates and selected date from providers
    final predefinedDates = ref.watch(predefinedDatesProvider);
    final selectedDate = ref.watch(selectedDateProvider);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: AppBar(
            backgroundColor: AppTheme.white,
            scrolledUnderElevation: 0,
            elevation: 0,
            automaticallyImplyLeading: false,
            title: const Text(
              'Cart',
              style: TextStyle(fontSize: 24),
            ),
            actions: [
              if (cartItems.isNotEmpty)
                IconButton(
                  icon: Text(
                    'Clear',
                    style: TextStyle(
                      color: AppTheme.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              16.0), // Set border radius here
                        ),
                        title: const Text(
                          'Clear Cart',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        content: const Text(
                            'Are you sure you want to remove all items from your cart?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              ref.read(cartProvider.notifier).clearCart();
                              Navigator.pop(context);
                            },
                            child: const Text('Clear',
                                style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
      body: cartItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/icons/empty.png',
                    width: 90,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Your cart is empty',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.orange,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    onPressed: () {
                      ref.read(selectedIndexProvider.notifier).state = 0;
                    },
                    child: const Text('Browse Products'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 25, vertical: 2),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return CartItemCard(
                        cartItem: item,
                        onRemove: () {
                          ref
                              .read(cartProvider.notifier)
                              .removeItem(item.product.id);
                        },
                        onQuantityChanged: (quantity) {
                          ref.read(cartProvider.notifier).updateQuantity(
                                item.product.id,
                                quantity,
                              );
                        },
                      );
                    },
                  ),
                ),
                // Cart summary
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Divider(
                        color: Colors.grey[300],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Subtotal',
                            style: TextStyle(
                              color: AppTheme.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Rs. ${totalAmount.toStringAsFixed(2)}/-',
                            style: TextStyle(
                              color: AppTheme.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Left Side: Text "Delivery"
                          Text(
                            'Delivery',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),

                          // Right Side: Dropdown with Arrow and Delivery Date
                          DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedDate, // Current selected date
                              items: predefinedDates.map((String date) {
                                return DropdownMenuItem<String>(
                                  value: date,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        date,
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                        ),
                                      ),
                                      SizedBox(
                                          width:
                                              8.0), // Space between text and arrow
                                      Image.asset(
                                        'assets/icons/drop.png',
                                        width: 10,
                                      )
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  // Update the selected date using Riverpod's state
                                  ref
                                      .read(selectedDateProvider.notifier)
                                      .state = newValue;
                                }
                              },
                              style: TextStyle(color: Colors.black),
                              iconSize: 0,
                              borderRadius: BorderRadius.circular(
                                  13), // Hide the default dropdown icon
                              dropdownColor: Colors
                                  .white, // Background color of the dropdown menu
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Divider(
                        color: Colors.grey[300],
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          width: double.infinity,
                          child: Text(
                            'Click to check for coupons!',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      GiftCodeField(),
                      SizedBox(
                        height: 30,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Grand Total',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.orange,
                              fontSize: 20,
                            ),
                          ),
                          Text(
                            'Rs. ${totalAmount.toStringAsFixed(1)} /-',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.orange,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.orange,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: () {
                            // Implement checkout logic
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Proceeding to checkout...'),
                              ),
                            );
                          },
                          child: const Text(
                            'Checkout',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class CartItemCard extends StatelessWidget {
  final CartItem cartItem;
  final VoidCallback onRemove;
  final Function(int) onQuantityChanged;

  const CartItemCard({
    Key? key,
    required this.cartItem,
    required this.onRemove,
    required this.onQuantityChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Product image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              cartItem.product.photo,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.image_not_supported),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          // Product details
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          cartItem.product.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.black,
                            fontSize: 16,
                          ),
                        ),
                        GestureDetector(
                          onTap: onRemove,
                          child: Image.asset(
                            'assets/icons/trash.png',
                            width: 18,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Rs. ${cartItem.product.price}/kg',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Rs. ${(cartItem.product.price * cartItem.quantity)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        // Decrement button
                        _buildQuantityButton(
                          icon: Icons.remove,
                          onPressed: () {
                            if (cartItem.quantity > 1) {
                              onQuantityChanged(cartItem.quantity - 1);
                            }
                          },
                        ),
                        // Quantity
                        Container(
                          width: 40,
                          alignment: Alignment.center,
                          child: Text(
                            '${cartItem.quantity}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        // Increment button
                        _buildQuantityButton(
                          icon: Icons.add,
                          onPressed: () {
                            onQuantityChanged(cartItem.quantity + 1);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.orange),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(
          icon,
          size: 16,
        ),
      ),
    );
  }
}
