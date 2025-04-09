// order_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lis_keithel/providers/auth_provider.dart';
import '../services/order_service.dart';

import '../models/models.dart';

// Provider for OrderService
final orderServiceProvider = Provider<OrderService>((ref) {
  return OrderService();
});

// State notifier for orders list
class OrdersNotifier extends StateNotifier<AsyncValue<List<Order>>> {
  final OrderService _orderService;
  final Ref _ref;
  DateTime? _startDate;
  DateTime? _endDate;

  OrdersNotifier(this._orderService, this._ref)
      : super(const AsyncValue.loading()) {
    // Listen to auth state changes
    _ref.listen(authProvider, (previous, current) {
      // If user logged out (was logged in before, now logged out)
      if (previous?.isLoggedIn == true && current.isLoggedIn == false) {
        // Clear orders when user logs out
        state = AsyncValue.data([]);
        _startDate = null;
        _endDate = null;
      }

      // If user logged in (was logged out before, now logged in)
      if (previous?.isLoggedIn == false && current.isLoggedIn == true) {
        // Fetch orders for the new user
        fetchOrders();
      }
    });

    // Initial fetch if user is already logged in
    if (_ref.read(authProvider).isLoggedIn) {
      fetchOrders();
    } else {
      // If not logged in, set empty list instead of loading state
      state = AsyncValue.data([]);
    }
  }

  // Get current date filter
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;

  // Fetch all orders
  Future<void> fetchOrders() async {
    if (!_ref.read(authProvider).isLoggedIn) {
      state = AsyncValue.data([]);
      return;
    }

    state = const AsyncValue.loading();
    try {
      final orders = await _orderService.getOrders();
      state = AsyncValue.data(orders);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // Filter orders by date range
  Future<void> filterOrdersByDateRange({
    required DateTime? startDate,
    required DateTime? endDate,
  }) async {
    _startDate = startDate;
    _endDate = endDate;

    // If no date range is provided, reset to all orders
    if (_startDate == null && _endDate == null) {
      await fetchOrders();
      return;
    }

    // Only filter if user is logged in
    if (!_ref.read(authProvider).isLoggedIn) {
      state = AsyncValue.data([]);
      return;
    }

    state = const AsyncValue.loading();
    try {
      // Fetch all orders from the service
      final allOrders = await _orderService.getOrders();

      // Filter orders based on the date range
      final filteredOrders = allOrders.where((order) {
        final orderDate = order.date;
        final isAfterStartDate = _startDate == null ||
            orderDate.isAfter(_startDate!) ||
            orderDate.isAtSameMomentAs(_startDate!);
        final isBeforeEndDate = _endDate == null ||
            orderDate.isBefore(_endDate!) ||
            orderDate.isAtSameMomentAs(_endDate!);

        return isAfterStartDate && isBeforeEndDate;
      }).toList();

      // Update the state with the filtered orders
      state = AsyncValue.data(filteredOrders);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // Clear date filter
  Future<void> clearDateFilter() async {
    _startDate = null;
    _endDate = null;
    await fetchOrders();
  }
}

// Provider for orders list
final ordersProvider =
    StateNotifierProvider<OrdersNotifier, AsyncValue<List<Order>>>((ref) {
  final orderService = ref.watch(orderServiceProvider);
  return OrdersNotifier(orderService, ref);
});

// Provider for a single order
final orderDetailsProvider =
    FutureProvider.family<OrderDetail?, String>((ref, id) async {
  final orderService = ref.watch(orderServiceProvider);
  return await orderService.getOrderById(id);
});

// Provider for cancelling an order
final cancelOrderProvider =
    FutureProvider.family<bool, ({String orderId, String status})>(
        (ref, params) async {
  final orderService = ref.watch(orderServiceProvider);
  final result = await orderService.cancelOrder(params.orderId, params.status);

  // Refresh orders list if successful
  if (result) {
    ref.read(ordersProvider.notifier).fetchOrders();
  }

  return result;
});
