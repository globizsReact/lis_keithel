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
  Future<void> filterByDateRange(DateTime start, DateTime end) async {
    state = const AsyncValue.loading();
    try {
      _startDate = start;
      _endDate = end;
      final orders = await _orderService.getOrdersByDateRange(start, end);
      state = AsyncValue.data(orders);
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
    FutureProvider.family<Order?, String>((ref, id) async {
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
