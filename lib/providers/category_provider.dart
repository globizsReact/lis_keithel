import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/config.dart';
import '../services/category_service.dart';
import '../models/models.dart';
import 'product_provider.dart';

final categoryServiceProvider = Provider<CategoryService>((ref) {
  return CategoryService(baseUrl: Config.baseUrl);
});

// State class for categories
class CategoriesState {
  final List<Category> categories;
  final bool isLoading;
  final String? error;

  CategoriesState({
    required this.categories,
    required this.isLoading,
    this.error,
  });

  CategoriesState copyWith({
    List<Category>? categories,
    bool? isLoading,
    String? error,
  }) {
    return CategoriesState(
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class CategoriesNotifier extends StateNotifier<CategoriesState> {
  final CategoryService _categoryService;

  CategoriesNotifier(this._categoryService)
      : super(CategoriesState(categories: [], isLoading: false));

  // Fetch categories from API
  Future<void> fetchCategories({bool forceFetch = false}) async {
    if (state.categories.isNotEmpty && !forceFetch) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final categories = await _categoryService.fetchCategories();

      // Create an "All" category and add it to the beginning of the list
      final allCategory = Category(
        id: '0',
        name: 'All',
        description: 'All Products',
        status: 'Y',
        photo:
            'https://liandsons.com/marketing_app/frontend/web/uploads/product_type/all-products.jpg', // Replace with an appropriate image
      );

      final updatedCategories = [allCategory, ...categories];
      state = state.copyWith(categories: updatedCategories, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

// Provider for categories state
final categoriesStateProvider =
    StateNotifierProvider<CategoriesNotifier, CategoriesState>((ref) {
  final categoryService = ref.watch(categoryServiceProvider);
  return CategoriesNotifier(categoryService);
});

// Provider for selected category (maintaining original functionality)
class CategoryNotifier extends StateNotifier<String> {
  CategoryNotifier() : super('0'); // Default category is 'All'

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
  final categoriesState = ref.watch(categoriesStateProvider);

  // Extract categories from the state
  final categories = categoriesState.categories.map((cat) => cat.name).toList();

  // Make sure 'All' is always the first option
  return ['All', ...categories..sort()];
});

// Provider for filtered products based on selected category
final filteredProductsProvider = Provider<List<Product>>((ref) {
  final productsState = ref.watch(productsProvider);
  final categoriesState = ref.watch(categoriesStateProvider);
  final selectedCategory = ref.watch(selectedCategoryProvider);

  if (selectedCategory == '0') {
    return productsState.products;
  }

  // Find the selected category ID
  final selectedCategoryId = categoriesState.categories
      .firstWhere((cat) => cat.id == selectedCategory,
          orElse: () => Category(
              id: '', name: '', description: '', status: '', photo: ''))
      .id;

  // Filter products by product_type_id matching the selected category ID
  return productsState.products
      .where((product) => product.productTypeId == selectedCategoryId)
      .toList();
});
