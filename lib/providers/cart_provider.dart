import 'package:flutter/material.dart';
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
  // Add delivery and coupon-related properties
  DeliveryOption? _selectedDelivery;
  bool _isCouponApplied = false;
  String? _appliedCoupon;
  double _subtotal = 0.0;
  double _deliveryChargeTotal = 0.0;
  double _couponDiscount = 0.0;
  double _grandTotal = 0.0;

  CartNotifier() : super([]);

  // Getter for cart summary
  DeliveryOption? get selectedDelivery => _selectedDelivery;
  bool get isCouponApplied => _isCouponApplied;
  String? get appliedCoupon => _appliedCoupon;
  double get subtotal => _subtotal;
  double get deliveryChargeTotal => _deliveryChargeTotal;
  double get couponDiscount => _couponDiscount;
  double get grandTotal => _grandTotal;

  // Calculate all cart totals
  void _calculateTotals() {
    // Calculate subtotal from items
    _subtotal = state.fold(0.0, (sum, item) => sum + item.total);

    // Set delivery charge if delivery option is selected
    _deliveryChargeTotal = _selectedDelivery?.price ?? 0.0;

    // Calculate total with delivery
    double totalWithDelivery = deliveryChargeTotal;

    // Calculate grand total
    _grandTotal = totalWithDelivery - _couponDiscount;

    // Ensure grand total doesn't go below zero
    if (_grandTotal < 0) {
      _grandTotal = 0;
    }

    // Notify listeners of state change
    state = [...state];
  }

  // Set delivery option
  void setDeliveryOption(DeliveryOption deliveryOption) {
    _selectedDelivery = deliveryOption;

    _calculateTotals();
  }

  // Apply coupon - simplified to just apply the discount amount
  void applyCoupon(double coupon, String code) {
    _couponDiscount = coupon;
    _appliedCoupon = code;
    _isCouponApplied = true;
    _calculateTotals();
  }

  // Remove coupon
  void removeCoupon() {
    _couponDiscount = 0;
    _appliedCoupon = '';
    _isCouponApplied = false;
    _calculateTotals();
  }

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
    _calculateTotals();
  }

  void removeItem(String productId) {
    state = state.where((item) => item.product.id != productId).toList();
    _calculateTotals();
    removeCoupon();
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
    _calculateTotals();
    removeCoupon();
  }

  void clearCart() {
    state = [];
    _calculateTotals();
    removeCoupon();
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
  final cartNotifier = ref.watch(cartProvider.notifier);
  final cartItems = ref.watch(cartProvider);

  final itemCount = cartItems.fold(0, (sum, item) => sum + item.quantityPcs);
  final totalWeight = cartItems.fold(0.0, (sum, item) => sum + item.quantityKg);
  final subtotalAmount = cartItems.fold(0.0, (sum, item) => sum + item.total);

  final totalWeightType2 = cartItems.fold(
      0.0,
      (sum, item) =>
          item.product.productTypeId == '2' ? sum + item.quantityKg : sum);

  // Get the grand total directly from the cart notifier
  final grandTotal = cartNotifier.grandTotal;
  final isCouponApplied = cartNotifier.isCouponApplied;
  final appliedCoupon = cartNotifier.appliedCoupon;
  final couponDiscount = cartNotifier.couponDiscount;
  final selectedDate = cartNotifier.selectedDelivery;

  return {
    'itemCount': itemCount,
    'totalWeight': totalWeight,
    'totalWeightType2': totalWeightType2,
    'subtotalAmount': subtotalAmount,
    'grandTotal': grandTotal,
    'selectedDate': selectedDate?.date,
    'isCouponApplied': isCouponApplied,
    'appliedCoupon': appliedCoupon,
    'couponDiscount': couponDiscount,
  };
});
