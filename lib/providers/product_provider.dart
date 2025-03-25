// lib/providers/product_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/config.dart';
import '../models/models.dart';
import '../services/product_service.dart';

// Provider for the Product Service
final productServiceProvider = Provider<ProductService>((ref) {
  return ProductService(baseUrl: Config.baseUrl);
});

// State class for products
class ProductsState {
  final List<Product> products;
  final bool isLoading;
  final String? error;

  ProductsState({
    required this.products,
    required this.isLoading,
    this.error,
  });

  ProductsState copyWith({
    List<Product>? products,
    bool? isLoading,
    String? error,
  }) {
    return ProductsState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Notifier class for products
class ProductsNotifier extends StateNotifier<ProductsState> {
  final ProductService _productService;

  ProductsNotifier(this._productService)
      : super(ProductsState(products: [], isLoading: false));

  // Fetch products from API
  Future<void> fetchProducts({bool forceFetch = false}) async {
    if (state.products.isNotEmpty && !forceFetch) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final products = await _productService.fetchProducts();
      state = state.copyWith(products: products, isLoading: false);

      print(state);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Filter products by category
  List<Product> filterProductsByCategory(String category) {
    if (category == 'All') {
      return state.products;
    }

    return state.products
        .where((product) => product.productTypeId == category)
        .toList();
  }
}

// Provider for products state
final productsProvider =
    StateNotifierProvider<ProductsNotifier, ProductsState>((ref) {
  final productService = ref.watch(productServiceProvider);
  return ProductsNotifier(productService);
});

// Simple provider for just the list of products
final productsListProvider = Provider<List<Product>>((ref) {
  return ref.watch(productsProvider).products;
});
