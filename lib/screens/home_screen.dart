import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lis_keithel_v1/providers/cart_provider.dart';

import 'package:lis_keithel_v1/providers/selected_index_provider.dart';
import 'package:lis_keithel_v1/utils/theme.dart';

// all Screen
import 'screens.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int selectedIndex = ref.watch(selectedIndexProvider);

    // Access the CartNotifier instance
    final cartItems = ref.watch(cartProvider);

    final List<Widget> screen = [
      ProductScreen(),
      CartScreen(),
      OrderSCreen(),
      ProfileScreen()
    ];

    return Scaffold(
      body: screen[selectedIndex],
      bottomNavigationBar: BottomAppBar(
        height: 90,
        color: AppTheme.lightOrange,
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    child: selectedIndex == 0
                        ? Image.asset(
                            'assets/icons/homeA.png',
                            width: 23,
                          )
                        : Image.asset(
                            'assets/icons/home.png',
                            width: 23,
                          ),
                    onTap: () {
                      ref.read(selectedIndexProvider.notifier).state = 0;
                    },
                  ),
                  Text(
                    'Home',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: selectedIndex == 0
                            ? AppTheme.orange
                            : Colors.grey[500]),
                  ),
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () {
                      ref.read(selectedIndexProvider.notifier).state = 1;
                    },
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.topRight,
                      children: [
                        ref.watch(selectedIndexProvider) == 1
                            ? Image.asset(
                                'assets/icons/cartA.png',
                                width: 23,
                              )
                            : Image.asset(
                                'assets/icons/cart.png',
                                width: 23,
                              ),
                        if (cartItems.isNotEmpty)
                          Positioned(
                            right:
                                -10, // Adjust position to align with the cart icon
                            top:
                                -4, // Adjust position to align with the cart icon
                            child: Container(
                              padding: EdgeInsets.all(1),
                              decoration: BoxDecoration(
                                color: Colors.red, // Badge background color
                                borderRadius:
                                    BorderRadius.circular(8), // Rounded corners
                              ),
                              constraints: BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                '${cartItems.length}', // Total cart items
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Text(
                    'Cart',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: ref.watch(selectedIndexProvider) == 1
                          ? AppTheme.orange
                          : Colors.grey[500],
                    ),
                  ),
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    child: selectedIndex == 2
                        ? Image.asset(
                            'assets/icons/orderA.png',
                            width: 23,
                          )
                        : Image.asset(
                            'assets/icons/order.png',
                            width: 23,
                          ),
                    onTap: () {
                      ref.read(selectedIndexProvider.notifier).state = 2;
                    },
                  ),
                  Text(
                    'Orders',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: selectedIndex == 2
                            ? AppTheme.orange
                            : Colors.grey[500]),
                  ),
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    child: selectedIndex == 3
                        ? Image.asset(
                            'assets/icons/profileA.png',
                            height: 23,
                            width: 23,
                          )
                        : Image.asset(
                            'assets/icons/profile.png',
                            height: 23,
                            width: 23,
                          ),
                    onTap: () {
                      ref.read(selectedIndexProvider.notifier).state = 3;
                    },
                  ),
                  Text(
                    'Profile',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: selectedIndex == 3
                            ? AppTheme.orange
                            : Colors.grey[500]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
