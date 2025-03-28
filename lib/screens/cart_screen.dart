// lib/screens/cart_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/selected_index_provider.dart';
import '../utils/responsive_sizing.dart';
import '../utils/theme.dart';
import '../widgets/widgets.dart';
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

    // Initialize responsive sizing
    ResponsiveSizing().init(context);
    final responsive = ResponsiveSizing();

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(responsive.appBarHeight(65)),
        child: Padding(
          padding: EdgeInsets.all(responsive.padding(7)),
          child: AppBar(
            backgroundColor: AppTheme.white,
            scrolledUnderElevation: 0,
            elevation: 0,
            automaticallyImplyLeading: false,
            title: Text(
              'Cart',
              style: TextStyle(
                fontSize: responsive.textSize(23),
              ),
            ),
            actions: [
              if (cartItems.isNotEmpty)
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: AppTheme.red,
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        title: const Text(
                          'Clear Cart',
                          style: TextStyle(
                            color: AppTheme.black,
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
                            child: const Text(
                              'Clear',
                              style: TextStyle(color: Colors.red),
                            ),
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
                    width: responsive.width(0.2),
                  ),
                  SizedBox(height: responsive.height(0.02)),
                  Text(
                    'Your cart is empty',
                    style: TextStyle(
                      fontSize: responsive.textSize(12),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: responsive.height(0.025)),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.orange,
                      padding: EdgeInsets.symmetric(
                        horizontal: responsive.padding(23),
                        vertical: responsive.padding(11),
                      ),
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
                    padding: EdgeInsets.symmetric(
                        horizontal: responsive.padding(22),
                        vertical: responsive.padding(2)),
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
                  padding: EdgeInsets.symmetric(
                    horizontal: responsive.padding(23),
                    vertical: responsive.padding(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Divider(
                        color: Colors.grey[300],
                      ),
                      SizedBox(
                        height: responsive.height(0.02),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Subtotal',
                            style: TextStyle(
                              color: AppTheme.black,
                              fontSize: responsive.textSize(16),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Rs. ${totalAmount.toStringAsFixed(2)}/-',
                            style: TextStyle(
                              color: AppTheme.black,
                              fontSize: responsive.textSize(16),
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
                              fontSize: responsive.textSize(15),
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
                                          fontSize: responsive.textSize(14),
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                        ),
                                      ),
                                      SizedBox(
                                        width: responsive.width(0.02),
                                      ),
                                      Image.asset(
                                        'assets/icons/drop.png',
                                        width: responsive.width(0.025),
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
                        height: responsive.height(0.01),
                      ),
                      Divider(
                        color: Colors.grey[300],
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: responsive.padding(19)),
                          width: double.infinity,
                          child: Text(
                            'Click to check for coupons!',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      GiftCodeField(),
                      SizedBox(
                        height: responsive.height(0.025),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Grand Total',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.orange,
                              fontSize: responsive.textSize(18),
                            ),
                          ),
                          Text(
                            'Rs. ${totalAmount.toStringAsFixed(1)} /-',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.orange,
                              fontSize: responsive.textSize(18),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: responsive.height(0.02),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.orange,
                            padding: EdgeInsets.symmetric(
                              vertical: responsive.padding(15),
                            ),
                          ),
                          onPressed: () {
                            // Implement checkout logic
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Proceeding to checkout...'),
                              ),
                            );
                          },
                          child: Text(
                            'Checkout',
                            style: TextStyle(
                              fontSize: responsive.textSize(15),
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
    // Initialize responsive sizing
    ResponsiveSizing().init(context);
    final responsive = ResponsiveSizing();

    return Padding(
      padding: EdgeInsets.only(bottom: responsive.padding(11)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Product image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              cartItem.product.photo!,
              width: responsive.width(0.25),
              height: responsive.height(0.11),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: responsive.width(0.2),
                  height: responsive.height(0.1),
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.image_not_supported),
                );
              },
            ),
          ),
          SizedBox(width: responsive.width(0.04)),
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
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.black,
                            fontSize: responsive.textSize(15),
                          ),
                        ),
                        GestureDetector(
                          onTap: onRemove,
                          child: Image.asset(
                            'assets/icons/trash.png',
                            width: responsive.width(0.05),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Rs. ${cartItem.product.price}/kg',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: responsive.textSize(11),
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: responsive.height(0.02)),
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
                          width: responsive.width(0.1),
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
