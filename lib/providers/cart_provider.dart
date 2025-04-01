// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../models/models.dart';

// class CartItem {
//   final Product product;
//   final int quantity;

//   CartItem({
//     required this.product,
//     this.quantity = 1,
//   });

//   CartItem copyWith({
//     Product? product,
//     int? quantity,
//   }) {
//     return CartItem(
//       product: product ?? this.product,
//       quantity: quantity ?? this.quantity,
//     );
//   }

//   double get total => product.price * quantity;
// }

// class CartNotifier extends StateNotifier<List<CartItem>> {
//   CartNotifier() : super([]);

//   void addItem(Product product, int quantity) {
//     final existingIndex =
//         state.indexWhere((item) => item.product.id == product.id);

//     if (existingIndex >= 0) {
//       // Product already in cart, update quantity
//       state = [
//         ...state.sublist(0, existingIndex),
//         state[existingIndex].copyWith(
//           quantity: state[existingIndex].quantity + quantity,
//         ),
//         ...state.sublist(existingIndex + 1),
//       ];
//     } else {
//       // Add new product to cart
//       state = [...state, CartItem(product: product, quantity: quantity)];
//     }
//   }

//   void removeItem(String productId) {
//     state = state.where((item) => item.product.id != productId).toList();
//   }

//   void updateQuantity(String productId, int quantity) {
//     final existingIndex =
//         state.indexWhere((item) => item.product.id == productId);

//     if (existingIndex >= 0) {
//       if (quantity <= 0) {
//         // Remove item if quantity is 0 or less
//         removeItem(productId);
//       } else {
//         // Update quantity
//         state = [
//           ...state.sublist(0, existingIndex),
//           state[existingIndex].copyWith(quantity: quantity),
//           ...state.sublist(existingIndex + 1),
//         ];
//       }
//     }
//   }

//   void clearCart() {
//     state = [];
//   }

//   int get itemCount {
//     return state.fold(0, (sum, item) => sum + item.quantity);
//   }

//   double get total {
//     return state.fold(0.0, (sum, item) => sum + item.total);
//   }
// }

// final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
//   return CartNotifier();
// });

// // Create a provider for cart summary data
// final cartSummaryProvider = Provider((ref) {
//   final cartItems = ref.watch(cartProvider);

//   final itemCount = cartItems.fold(0, (sum, item) => sum + item.quantity);
//   final totalAmount = cartItems.fold(
//       0.0, (sum, item) => sum + (item.product.price * item.quantity));

//   return {
//     'itemCount': itemCount,
//     'totalAmount': totalAmount,
//   };
// });

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';

class CartItem {
  final Product product;
  final int quantityPcs;
  final double quantityKg;

  CartItem({
    required this.product,
    this.quantityPcs = 1,
    this.quantityKg = 0.0,
  });

  CartItem copyWith({
    Product? product,
    int? quantityPcs,
    double? quantityKg,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantityPcs: quantityPcs ?? this.quantityPcs,
      quantityKg: quantityKg ?? this.quantityKg,
    );
  }

  double get total {
    // For weight-based products (type 2), use kg for price calculation
    if (product.productTypeId == '2') {
      return product.price * quantityKg;
    }
    // For count-based products, use pcs
    return product.price * quantityPcs;
  }
}

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addItem(Product product, int quantityPcs, {double? quantityKg}) {
    final existingIndex =
        state.indexWhere((item) => item.product.id == product.id);
    double calculatedKg = quantityKg ?? 0.0;

    // If kg not provided but we have a weightPerPcs value, calculate kg from pcs
    if (quantityKg == null && product.productTypeId == '2') {
      calculatedKg = quantityPcs * product.weightPerPcs;
    }

    if (existingIndex >= 0) {
      // Product already in cart, update quantity
      final existingItem = state[existingIndex];
      state = [
        ...state.sublist(0, existingIndex),
        existingItem.copyWith(
          quantityPcs: existingItem.quantityPcs + quantityPcs,
          quantityKg: existingItem.quantityKg + calculatedKg,
        ),
        ...state.sublist(existingIndex + 1),
      ];
    } else {
      // Add new product to cart
      state = [
        ...state,
        CartItem(
          product: product,
          quantityPcs: quantityPcs,
          quantityKg: calculatedKg,
        )
      ];
    }
  }

  void removeItem(String productId) {
    state = state.where((item) => item.product.id != productId).toList();
  }

  void updateQuantity(String productId,
      {int? quantityPcs, double? quantityKg}) {
    final existingIndex =
        state.indexWhere((item) => item.product.id == productId);

    if (existingIndex >= 0) {
      final item = state[existingIndex];
      final product = item.product;

      int updatedPcs = quantityPcs ?? item.quantityPcs;
      double updatedKg = quantityKg ?? item.quantityKg;

      // If only pcs provided for weight-based product, calculate kg
      if (quantityPcs != null &&
          quantityKg == null &&
          product.productTypeId == '2') {
        updatedKg = quantityPcs * product.weightPerPcs;
      }

      // If only kg provided for weight-based product, calculate pcs
      if (quantityKg != null &&
          quantityPcs == null &&
          product.productTypeId == '2') {
        updatedPcs = (quantityKg / product.weightPerPcs).round();
      }

      if ((updatedPcs <= 0) ||
          (product.productTypeId == '2' && updatedKg <= 0)) {
        // Remove item if quantity is 0 or less
        removeItem(productId);
      } else {
        // Update quantity
        state = [
          ...state.sublist(0, existingIndex),
          item.copyWith(quantityPcs: updatedPcs, quantityKg: updatedKg),
          ...state.sublist(existingIndex + 1),
        ];
      }
    }
  }

  void clearCart() {
    state = [];
  }

  int get itemCount {
    return state.fold(0, (sum, item) => sum + item.quantityPcs);
  }

  double get totalWeight {
    return state.fold(0.0, (sum, item) => sum + item.quantityKg);
  }

  double get totalWeightType2 {
    return state.fold(
      0.0,
      (sum, item) =>
          item.product.productTypeId == '2' ? sum + item.quantityKg : sum,
    );
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

  final itemCount = cartItems.fold(0, (sum, item) => sum + item.quantityPcs);
  final totalWeight = cartItems.fold(0.0, (sum, item) => sum + item.quantityKg);
  final totalAmount = cartItems.fold(0.0, (sum, item) => sum + item.total);

  final totalWeightType2 = cartItems.fold(
      0.0,
      (sum, item) =>
          item.product.productTypeId == '2' ? sum + item.quantityKg : sum);

  return {
    'itemCount': itemCount,
    'totalWeight': totalWeight,
    'totalWeightType2':
        totalWeightType2, // Add total weight for type 2 products
    'totalAmount': totalAmount,
  };
});
