// screens/order_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lis_keithel_v1/utils/theme.dart';
import '../widgets/widgets.dart';

import '../models/models.dart';
import '../providers/providers.dart';

class OrderListScreen extends ConsumerWidget {
  const OrderListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsyncValue = ref.watch(ordersProvider);
    final dateFormat = DateFormat('dd MMM yyyy');

    // auth
    final authState = ref.read(authProvider);

    // Check if date filter is active
    final startDate = ref.read(ordersProvider.notifier).startDate;
    final endDate = ref.read(ordersProvider.notifier).endDate;
    final hasDateFilter = startDate != null && endDate != null;

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
              'Orders',
              style: TextStyle(fontSize: 24),
            ),
            actions: [
              // Date filter button
              !authState.isLoggedIn
                  ? Text('')
                  : IconButton(
                      icon: Image.asset(
                        'assets/icons/calendar.png',
                        width: 25,
                      ),
                      onPressed: () => _showDateFilterDialog(context, ref),
                    ),
            ],
          ),
        ),
      ),
      body: !authState.isLoggedIn
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/icons/orderE.png',
                    width: 90,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Sign in to see your orders',
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
                      context.push('/login');
                    },
                    child: const Text('Sign in now'),
                  )
                ],
              ),
            )
          : ordersAsyncValue.when(
              loading: () => OrderLoadingShimmer(),
              error: (error, stack) => Center(child: Text('Error: $error')),
              data: (orders) {
                if (orders.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/icons/orderE.png',
                          width: 90,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'No orders found',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (hasDateFilter)
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.orange,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                            ),
                            onPressed: () => ref
                                .read(ordersProvider.notifier)
                                .clearDateFilter(),
                            child: const Text('Clear Filter'),
                          ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: orders.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 5),
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return _OrderCard(
                      order: order,
                      dateFormat: dateFormat,
                    );
                  },
                );
              },
            ),
    );
  }

  void _showDateFilterDialog(BuildContext context, WidgetRef ref) async {
    final OrdersNotifier notifier = ref.read(ordersProvider.notifier);

    // Initialize with current filter dates or defaults
    DateTimeRange? dateRange;

    if (notifier.startDate != null && notifier.endDate != null) {
      dateRange = DateTimeRange(
        start: notifier.startDate!,
        end: notifier.endDate!,
      );
    } else {
      // Default to current month
      final now = DateTime.now();
      final start = DateTime(now.year, now.month, 1);
      final end = DateTime(now.year, now.month + 1, 0);
      dateRange = DateTimeRange(start: start, end: end);
    }

    final result = await showDateRangePicker(
      context: context,
      initialDateRange: dateRange,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData(
            colorScheme: ColorScheme.light(
              primary: AppTheme.orange,
              onPrimary: Colors.white,
              secondaryContainer: AppTheme.lightOrange,
            ),
          ),
          child: child!,
        );
      },
    );

    if (result != null) {
      // Apply filter
      notifier.filterByDateRange(result.start, result.end);
    }
  }
}

class _OrderCard extends ConsumerWidget {
  final Order order;
  final DateFormat dateFormat;

  const _OrderCard({
    Key? key,
    required this.order,
    required this.dateFormat,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => context.push("/order-details/${order.id}"),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.white,
        ),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Row(
            children: [
              // Order image
              Container(
                width: 85,
                height: 85,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: AssetImage(
                        order.imageUrl ?? 'assets/images/default.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Order details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.id,
                      style: const TextStyle(
                        color: AppTheme.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      dateFormat.format(order.date),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      order.status.displayName,
                      style: TextStyle(
                        fontSize: 13,
                        color: order.status.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // Arrow icon
              Image.asset(
                'assets/icons/arrowR.png',
                width: 15,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
