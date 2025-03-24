import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/selected_index_provider.dart';
import '../utils/theme.dart';

// All Screens
import 'screens.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final int selectedIndex = ref.watch(selectedIndexProvider);

    // Access the CartNotifier instance
    final cartItems = ref.watch(cartProvider);

    final List<Widget> screen = [
      ProductScreen(),
      CartScreen(),
      OrderListScreen(),
      AccountScreen(),
    ];

    return Scaffold(
      body: screen[selectedIndex],
      bottomNavigationBar: BottomAppBar(
        color: AppTheme.lightOrange,
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onTap: () {
                  ref.read(selectedIndexProvider.notifier).state = 0;
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 6),
                  width: 80,
                  color: Colors.transparent,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        selectedIndex == 0
                            ? 'assets/icons/homeA.png'
                            : 'assets/icons/home.png',
                        width: 23,
                      ),
                      Text(
                        'Home',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: selectedIndex == 0
                              ? AppTheme.orange
                              : Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  ref.read(selectedIndexProvider.notifier).state = 1;
                },
                child: Container(
                  width: 80,
                  padding: EdgeInsets.symmetric(vertical: 6),
                  color: Colors.transparent,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.topRight,
                        children: [
                          Image.asset(
                            selectedIndex == 1
                                ? 'assets/icons/cartA.png'
                                : 'assets/icons/cart.png',
                            width: 23,
                          ),
                          if (cartItems.isNotEmpty)
                            Positioned(
                              right: -10,
                              top: -4,
                              child: Container(
                                padding: EdgeInsets.all(1),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                constraints: BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                child: Text(
                                  '${cartItems.length}',
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
                      Text(
                        'Cart',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: selectedIndex == 1
                              ? AppTheme.orange
                              : Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  ref.read(selectedIndexProvider.notifier).state = 2;
                },
                child: Container(
                  width: 80,
                  padding: EdgeInsets.symmetric(vertical: 6),
                  color: Colors.transparent,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        selectedIndex == 2
                            ? 'assets/icons/orderA.png'
                            : 'assets/icons/order.png',
                        width: 23,
                      ),
                      Text(
                        'Orders',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: selectedIndex == 2
                              ? AppTheme.orange
                              : Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  final authState = ref.read(authProvider);
                  if (!authState.isLoggedIn) {
                    context.push('/login');
                  } else {
                    ref.read(selectedIndexProvider.notifier).state = 3;
                  }
                },
                child: Container(
                  width: 80,
                  padding: EdgeInsets.symmetric(vertical: 6),
                  color: Colors.transparent,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        selectedIndex == 3
                            ? 'assets/icons/profileA.png'
                            : 'assets/icons/profile.png',
                        height: 23,
                        width: 23,
                      ),
                      Text(
                        'Account',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: selectedIndex == 3
                              ? AppTheme.orange
                              : Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
