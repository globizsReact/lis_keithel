// lib/providers/category_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import 'product_provider.dart';

class CategoryNotifier extends StateNotifier<String> {
  CategoryNotifier() : super('All'); // Default category is 'All'

  void setCategory(String category) {
    state = category;
  }

  String get selectedCategory => state;
}

// Provider for the selected category
final selectedCategoryProvider =
    StateNotifierProvider<CategoryNotifier, String>((ref) {
  return CategoryNotifier();
});

// Provider for the list of available categories
final categoriesProvider = Provider<List<String>>((ref) {
  final products = ref.watch(productsProvider);

  // Extract unique categories from products
  final categories =
      products.map((product) => product.category).toSet().toList();

  // Make sure 'All' is always the first option
  return ['All', ...categories..sort()];
});

// Provider for filtered products based on selected category
final filteredProductsProvider = Provider<List<Product>>((ref) {
  final products = ref.watch(productsProvider);
  final selectedCategory = ref.watch(selectedCategoryProvider);

  return ref
      .read(productsProvider.notifier)
      .filterProductsByCategory(selectedCategory);
});
