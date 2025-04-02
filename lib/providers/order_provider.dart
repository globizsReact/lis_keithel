// order_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/order_service.dart';

import '../models/models.dart';

// Provider for OrderService
final orderServiceProvider = Provider<OrderService>((ref) {
  return OrderService();
});

// State notifier for orders list
class OrdersNotifier extends StateNotifier<AsyncValue<List<Order>>> {
  final OrderService _orderService;
  DateTime? _startDate;
  DateTime? _endDate;

  OrdersNotifier(this._orderService) : super(const AsyncValue.loading()) {
    fetchOrders();
  }

  // Get current date filter
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;

  // Fetch all orders
  Future<void> fetchOrders() async {
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
  return OrdersNotifier(orderService);
});

// Provider for a single order
final orderDetailsProvider =
    FutureProvider.family<OrderDetail?, String>((ref, id) async {
  final orderService = ref.watch(orderServiceProvider);
  return await orderService.getOrderById(id);
});

// Provider for cancelling an order
final cancelOrderProvider =
    FutureProvider.family<bool, String>((ref, id) async {
  final orderService = ref.watch(orderServiceProvider);
  final result = await orderService.cancelOrder(id);

  // Refresh orders list if successful
  if (result) {
    ref.read(ordersProvider.notifier).fetchOrders();
  }

  return result;
});
