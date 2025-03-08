// providers/product_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';

class ProductsNotifier extends StateNotifier<List<Product>> {
  ProductsNotifier() : super([]);

  Future<void> fetchProducts() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // Sample products
    state = [
      Product(
        id: '1',
        name: 'XTech 16mm',
        price: 64.60,
        imageUrl: 'assets/images/xtech.png',
        category: 'Steel',
      ),
      Product(
        id: '2',
        name: 'Dalmia Cement',
        price: 650.0,
        imageUrl: 'assets/images/dalmia.png',
        category: 'Cement',
      ),
      Product(
        id: '3',
        name: 'Ultra Tech Cement',
        price: 670.0,
        imageUrl: 'assets/images/ultratech.png',
        category: 'Cement',
      ),
      Product(
        id: '4',
        name: 'Binding Wire',
        price: 85.0,
        imageUrl: 'assets/images/wire.png',
        category: 'Wire',
      ),
      Product(
        id: '5',
        name: 'Tank',
        price: 85.0,
        imageUrl: 'assets/images/tank.png',
        category: 'Tank',
      ),
      Product(
        id: '6',
        name: 'Plywood',
        price: 85.0,
        imageUrl: 'assets/images/ply.png',
        category: 'Plywood',
      ),
      Product(
        id: '7',
        name: 'Shyam 16mm',
        price: 64.60,
        imageUrl: 'assets/images/shyam.png',
        category: 'Steel',
      ),
      Product(
        id: '8',
        name: 'Tata Steel',
        price: 64.60,
        imageUrl: 'assets/images/tata.png',
        category: 'Steel',
      ),
      Product(
        id: '9',
        name: 'Khamdenu Steel',
        price: 64.60,
        imageUrl: 'assets/images/khamdenu.png',
        category: 'Steel',
      ),
      Product(
        id: '10',
        name: 'ACC Cement',
        price: 85.0,
        imageUrl: 'assets/images/acc.png',
        category: 'Cement',
      ),
      // Add more products as needed
    ];
  }

  Product? getProductById(String id) {
    try {
      return state.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Product> filterProductsByCategory(String category) {
    if (category == 'All') {
      return state;
    }
    return state.where((product) => product.category == category).toList();
  }
}

final productsProvider =
    StateNotifierProvider<ProductsNotifier, List<Product>>((ref) {
  return ProductsNotifier();
});

final productDetailsProvider = Provider.family<Product?, String>((ref, id) {
  final products = ref.watch(productsProvider);
  try {
    return products.firstWhere((product) => product.id == id);
  } catch (e) {
    return null;
  }
});
