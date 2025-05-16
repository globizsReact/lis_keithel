// lib/providers/providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../services/ledger_service.dart';

// Provider for API service
final apiServiceProvider = Provider<LedgerService>((ref) {
  return LedgerService();
});

// Provider for product list
final productsProvider = FutureProvider<List<ProductL>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  return await apiService.getProducts();
});

// Provider for selected product ID
final selectedProductIdProvider = StateProvider<int?>((ref) => null);

// Provider for current page
final currentPageProvider = StateProvider<int>((ref) => 1);

// Provider for product ledger entries
final productLedgerProvider =
    FutureProvider.autoDispose<List<ProductLedgerEntry>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  final productId = ref.watch(selectedProductIdProvider);
  final page = ref.watch(currentPageProvider);

  if (productId == null) {
    return [];
  }

  return await apiService.getProductLedger(productId: productId, page: page);
});
