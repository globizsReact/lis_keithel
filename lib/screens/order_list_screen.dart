import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../utils/responsive_sizing.dart';
import '../utils/theme.dart';
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

    // Initialize responsive sizing
    ResponsiveSizing().init(context);
    final responsive = ResponsiveSizing();

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(65),
        child: Padding(
          padding: EdgeInsets.all(
            responsive.padding(8),
          ),
          child: AppBar(
            backgroundColor: AppTheme.white,
            scrolledUnderElevation: 0,
            elevation: 0,
            automaticallyImplyLeading: false,
            title: Text(
              'Orders',
              style: TextStyle(
                fontSize: responsive.textSize(23),
              ),
            ),
            actions: [
              if (authState.isLoggedIn)
                hasDateFilter
                    ? GestureDetector(
                        onTap: () =>
                            ref.read(ordersProvider.notifier).clearDateFilter(),
                        child: Text(
                          'Clear',
                          style: TextStyle(
                            color: AppTheme.red,
                            fontWeight: FontWeight.w600,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      )
                    : Text(
                        'Filter',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: AppTheme.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              // Date filter button
              if (authState.isLoggedIn)
                IconButton(
                  icon: Image.asset(
                    'assets/icons/filter.png',
                    width: responsive.width(0.05),
                    gaplessPlayback: true,
                  ),
                  onPressed: () => _showDateFilterDialog(context, ref),
                ),
              SizedBox(
                width: responsive.width(0.01),
              )
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
                    gaplessPlayback: true,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Sign in to see your orders',
                    style: TextStyle(
                      fontSize: responsive.textSize(12),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 22,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.orange,
                      padding: EdgeInsets.symmetric(
                        horizontal: responsive.padding(23),
                        vertical: responsive.padding(11),
                      ),
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
                          width: responsive.width(0.2),
                          gaplessPlayback: true,
                        ),
                        SizedBox(height: 20),
                        Text(
                          'No orders found',
                          style: TextStyle(
                            fontSize: responsive.textSize(12),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 22),
                        if (hasDateFilter)
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.orange,
                              padding: EdgeInsets.symmetric(
                                horizontal: responsive.padding(23),
                                vertical: responsive.padding(11),
                              ),
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

                return RefreshIndicator(
                  onRefresh: () => _refreshOrders(ref),
                  child: ListView.separated(
                    physics: AlwaysScrollableScrollPhysics(),
                    shrinkWrap: true,
                    padding: EdgeInsets.symmetric(
                      horizontal: responsive.padding(23),
                    ),
                    itemCount: orders.length,
                    separatorBuilder: (context, index) => SizedBox(
                      height: 5,
                    ),
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return _OrderCard(
                        order: order,
                        dateFormat: dateFormat,
                      );
                    },
                  ),
                );
              },
            ),
    );
  }

  Future<void> _refreshOrders(WidgetRef ref) async {
    // Call the refresh method on your orders provider
    return ref.read(ordersProvider.notifier).fetchOrders();
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
      final start =
          DateTime(now.year, now.month, 1); // Start of the current month
      final end =
          DateTime(now.year, now.month + 1, 0); // End of the current month
      dateRange = DateTimeRange(start: start, end: end);
    }

    // Show the date range picker
    final result = await showDateRangePicker(
      context: context,
      initialDateRange: dateRange,
      firstDate: DateTime(2020), // Minimum selectable date
      lastDate: DateTime(2030), // Maximum selectable date
      builder: (context, child) {
        return Theme(
          data: ThemeData(
            colorScheme: ColorScheme.light(
              primary: AppTheme.orange, // Customize the primary color
              onPrimary: Colors.white, // Customize text color on primary
              secondaryContainer:
                  AppTheme.lightOrange, // Customize secondary color
            ),
          ),
          child: child!,
        );
      },
    );

    // If a valid date range is selected, apply the filter
    if (result != null) {
      // Apply filter using the OrdersNotifier
      await notifier.filterOrdersByDateRange(
        startDate: result.start,
        endDate: result.end,
      );
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
    // Initialize responsive sizing
    ResponsiveSizing().init(context);
    final responsive = ResponsiveSizing();

    return GestureDetector(
      onTap: () => context.push("/order-details/${order.id}"),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.white,
        ),
        child: Padding(
          padding: EdgeInsets.only(bottom: responsive.padding(11)),
          child: Row(
            children: [
              // Order image
              Container(
                width: responsive.width(0.2),
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: AssetImage(
                      'assets/images/placeholder.png',
                    ),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(20),
                      blurRadius: 5.0,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: responsive.width(0.04),
              ),

              // Order details
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '#${order.id}',
                    style: TextStyle(
                      color: AppTheme.black,
                      fontWeight: FontWeight.bold,
                      fontSize: responsive.textSize(17),
                    ),
                  ),
                  Text(
                    dateFormat.format(order.date),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.grey[600],
                      fontSize: responsive.textSize(11),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: order.status.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(
                        10,
                      ),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    child: Text(
                      order.status.displayName.toUpperCase(),
                      style: TextStyle(
                        fontSize: responsive.textSize(11),
                        color: order.status.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              )),

              // Arrow icon
              Image.asset(
                'assets/icons/arrowR.png',
                width: responsive.width(0.04),
                gaplessPlayback: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
