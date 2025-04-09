// lib/screens/cart_screen.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../utils/responsive_sizing.dart';
import '../utils/theme.dart';
import '../widgets/widgets.dart';

import 'package:shimmer/shimmer.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final cartSummary = ref.watch(cartSummaryProvider);
    final totalAmount = cartSummary['subtotalAmount'] as double;
    final grandTotal = cartSummary['grandTotal'] as double;

    final deliveryDatesAsync = ref.watch(deliveryDatesProvider);

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
            title: Row(
              children: [
                Text(
                  'Cart ',
                  style: TextStyle(
                    fontSize: responsive.textSize(23),
                  ),
                ),
                if (cartItems.isNotEmpty)
                  Text(
                    '(${cartItems.length} ${cartItems.length > 1 ? 'Items' : 'Item'})',
                    style: TextStyle(
                        fontSize: responsive.textSize(23),
                        color: AppTheme.grey,
                        fontWeight: FontWeight.w600),
                  )
              ],
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
                    physics: BouncingScrollPhysics(),
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
                                quantityPcs: quantity,
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
                      SizedBox(
                        height: responsive.height(0.01),
                      ),

                      // Left Side: Text "Delivery"
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Delivery',
                            style: TextStyle(
                              fontSize: responsive.textSize(15),
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          deliveryDatesAsync.when(
                            loading: () => Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Container(
                                width: 200,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                            ),
                            error: (error, stack) => Center(
                              child: Text('Error: $error'),
                            ),
                            data: (deliveryDates) {
                              // Create a list of date strings for the dropdown
                              List<DeliveryDate> dateOptions = deliveryDates;

                              // State to hold the selected date
                              return DateSelectionWidget(
                                  dateOptions: dateOptions);
                            },
                          ),
                        ],
                      ),

                      // Right Side: Dropdown with Arrow and Delivery Date

                      SizedBox(
                        height: responsive.height(0.01),
                      ),
                      Divider(
                        color: Colors.grey[300],
                      ),
                      GestureDetector(
                        onTap: () {
                          context.push('/coupons');
                        },
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
                            'Rs. ${grandTotal.toStringAsFixed(1)} /-',
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
                        height: responsive.height(0.07),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.orange,
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

// Calculate the total amount based on product type
    String totalAmountText = '';
    if (cartItem.product.productTypeId == '2') {
      // Weight-based product (type 2): Use quantityKg for calculation
      totalAmountText =
          'Rs. ${(cartItem.product.price * cartItem.quantityKg).toStringAsFixed(2)}';
    } else {
      // Count-based product: Use quantityPcs for calculation
      totalAmountText =
          'Rs. ${(cartItem.product.price * cartItem.quantityPcs).toStringAsFixed(2)}';
    }

    return Padding(
      padding: EdgeInsets.only(
        bottom: responsive.padding(11),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Product image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: cartItem.product.photo == null
                ? Image.asset(
                    'assets/images/placeholder.png',
                    width: responsive.width(0.25),
                    height: responsive.height(0.11),
                    fit: BoxFit.cover,
                  )
                : CachedNetworkImage(
                    imageUrl: cartItem.product.photo!,
                    width: responsive.width(0.25),
                    height: responsive.height(0.11),
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        Image.asset('assets/images/placeholder.png'),
                    errorWidget: (context, url, error) => Icon(Icons.error),
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
                            width: responsive.width(0.04),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Rs. ${cartItem.product.price}/${cartItem.product.uomCode}',
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
                      totalAmountText,
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
                            if (cartItem.quantityPcs > 1) {
                              onQuantityChanged(cartItem.quantityPcs - 1);
                            }
                          },
                        ),
                        // Quantity
                        Container(
                          width: responsive.width(0.1),
                          alignment: Alignment.center,
                          child: Text(
                            '${cartItem.quantityPcs}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        // Increment button
                        _buildQuantityButton(
                          icon: Icons.add,
                          onPressed: () {
                            onQuantityChanged(cartItem.quantityPcs + 1);
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

// Separate widget for managing date selection
class DateSelectionWidget extends ConsumerStatefulWidget {
  final List<DeliveryDate> dateOptions;

  DateSelectionWidget({required this.dateOptions});

  @override
  _DateSelectionWidgetState createState() => _DateSelectionWidgetState();
}

class _DateSelectionWidgetState extends ConsumerState<DateSelectionWidget> {
  late DeliveryDate selectedDate; // Holds the currently selected date
  FixedExtentScrollController? _scrollController;

  @override
  void initState() {
    super.initState();
    // Set the default date to the first date in the list
    if (widget.dateOptions.isNotEmpty) {
      selectedDate = widget.dateOptions.first;
      _scrollController = FixedExtentScrollController(initialItem: 0);
    }
  }

  @override
  void dispose() {
    _scrollController?.dispose(); // Dispose of the scroll controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            // Open a centered dialog when the date is tapped
            _openIOSStyleDatePicker(context);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_formatDate(selectedDate.date)} (₹.${selectedDate.price})',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.black,
                ),
              ),
              Icon(Icons.arrow_drop_down, color: Colors.grey),
            ],
          ),
        ),
      ],
    );
  }

  void _openIOSStyleDatePicker(BuildContext context) {
    // Find the index of the currently selected date
    int selectedIndex = widget.dateOptions.indexOf(selectedDate);

    // Reset the scroll controller to the selected index
    _scrollController = FixedExtentScrollController(initialItem: selectedIndex);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0), // Add rounded corners
          ), // Remove default padding
          content: SizedBox(
            height: 250,
            width: 500, // Height of the dialog
            child: Column(
              children: [
                Expanded(
                  child: CupertinoPicker(
                    scrollController: _scrollController,
                    itemExtent: 40, // Height of each item
                    onSelectedItemChanged: (int index) {
                      setState(() {
                        selectedDate = widget.dateOptions[index];
                      });
                    },
                    children: widget.dateOptions.map((DeliveryDate date) {
                      return Center(
                        child: Text(
                          '${_formatDate(date.date)} - Rs.${date.price}',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Divider(height: 1, thickness: 0.5),
                // Header with "Cancel" and "Done" buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        // Update the cart provider with the selected date's price
                        double grandTotal = double.tryParse(
                                selectedDate.price.replaceAll(',', '')) ??
                            0.0;
                        ref
                            .read(cartProvider.notifier)
                            .setGrandTotal(grandTotal);

                        Navigator.pop(context); // Close the dialog
                      },
                      child: Text(
                        'Done',
                        style: TextStyle(
                          color: AppTheme.orange,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper function to format the date as '23rd Mar 2025'
  String _formatDate(String dateString) {
    DateTime date =
        DateFormat('yyyy-MM-dd').parse(dateString); // Parse the input date
    int day = date.day;
    String month = DateFormat('MMM').format(date); // Get abbreviated month name
    String year = DateFormat('yyyy').format(date); // Get full year
    String ordinalDay =
        _getOrdinal(day); // Convert day to ordinal (e.g., 23 → 23rd)
    return '$ordinalDay $month $year'; // Combine into '23rd Mar 2025'
  }

  // Helper function to convert a numeric day into its ordinal form
  String _getOrdinal(int day) {
    if (day % 10 == 1 && day != 11) {
      return '${day}st';
    } else if (day % 10 == 2 && day != 12) {
      return '${day}nd';
    } else if (day % 10 == 3 && day != 13) {
      return '${day}rd';
    } else {
      return '${day}th';
    }
  }
}
