import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';

class CartItem {
  final Product product;
  final int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  CartItem copyWith({
    Product? product,
    int? quantity,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }

  double get total => product.price * quantity;
}

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addItem(Product product, int quantity) {
    final existingIndex =
        state.indexWhere((item) => item.product.id == product.id);

    if (existingIndex >= 0) {
      // Product already in cart, update quantity
      state = [
        ...state.sublist(0, existingIndex),
        state[existingIndex].copyWith(
          quantity: state[existingIndex].quantity + quantity,
        ),
        ...state.sublist(existingIndex + 1),
      ];
    } else {
      // Add new product to cart
      state = [...state, CartItem(product: product, quantity: quantity)];
    }
  }

  void removeItem(String productId) {
    state = state.where((item) => item.product.id != productId).toList();
  }

  void updateQuantity(String productId, int quantity) {
    final existingIndex =
        state.indexWhere((item) => item.product.id == productId);

    if (existingIndex >= 0) {
      if (quantity <= 0) {
        // Remove item if quantity is 0 or less
        removeItem(productId);
      } else {
        // Update quantity
        state = [
          ...state.sublist(0, existingIndex),
          state[existingIndex].copyWith(quantity: quantity),
          ...state.sublist(existingIndex + 1),
        ];
      }
    }
  }

  void clearCart() {
    state = [];
  }

  int get itemCount {
    return state.fold(0, (sum, item) => sum + item.quantity);
  }

  double get total {
    return state.fold(0.0, (sum, item) => sum + item.total);
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

// Create a provider for cart summary data
final cartSummaryProvider = Provider((ref) {
  final cartItems = ref.watch(cartProvider);

  final itemCount = cartItems.fold(0, (sum, item) => sum + item.quantity);
  final totalAmount = cartItems.fold(
      0.0, (sum, item) => sum + (item.product.price * item.quantity));

  return {
    'itemCount': itemCount,
    'totalAmount': totalAmount,
  };
});
