// lib/screens/cart_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../models/models.dart';
import '../providers/providers.dart';
import '../utils/responsive_sizing.dart';
import '../utils/theme.dart';
import '../widgets/widgets.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // cart provider
    final cartItems = ref.watch(cartProvider);
    final cartSummary = ref.watch(cartSummaryProvider);
    final subTotal = cartSummary['subtotalAmount'];
    final grandTotal = cartSummary['grandTotal'];

    // Access the login state using Riverpod
    final authState = ref.read(authProvider);

    final deliveryDatesAsync = ref.watch(deliveryDatesProvider);

    // check out provider
    final checkOut = ref.watch(checkoutProvider.notifier);
    final checkOutState = ref.watch(checkoutProvider);

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
                            'Rs. ${double.parse(subTotal.toString()).toStringAsFixed(2)}/-',
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
                              child: Text('Error: Fail'),
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
                            'Rs. $grandTotal/-',
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
                      authState.isLoggedIn
                          ? SlideToCheckout(
                              onSlideComplete: () {
                                checkOut.placeOrder(context);
                              },
                              isLoading: checkOutState.isLoading,
                            )
                          : SizedBox(
                              width: double.infinity,
                              height: responsive.height(0.07),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: checkOutState.isLoading
                                      ? AppTheme.grey
                                      : AppTheme.orange,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: AppTheme.grey,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(11),
                                  ),
                                ),
                                onPressed: () {
                                  context.push('/login');
                                },
                                child: Text(
                                  'Log in to checkout',
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
