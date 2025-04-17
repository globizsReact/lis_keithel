import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lis_keithel/services/checkout_service.dart';
import 'package:lis_keithel/utils/theme.dart';
import 'package:flutter/material.dart';
import '../models/models.dart';
import 'package:lis_keithel/providers/cart_provider.dart';

// Class to manage checkout state
class CheckoutState {
  final bool isLoading;
  final String? error;
  final OrderResponse? orderResponse;

  CheckoutState({
    this.isLoading = false,
    this.error,
    this.orderResponse,
  });

  // Create a copy with updated fields
  CheckoutState copyWith({
    bool? isLoading,
    String? error,
    OrderResponse? orderResponse,
    bool clearError = false,
    bool clearOrderResponse = false,
  }) {
    return CheckoutState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      orderResponse:
          clearOrderResponse ? null : (orderResponse ?? this.orderResponse),
    );
  }
}

// Notifier for checkout
class CheckoutNotifier extends StateNotifier<CheckoutState> {
  final Ref ref;

  CheckoutNotifier(this.ref) : super(CheckoutState());

  // Place order
  Future<void> placeOrder(
    BuildContext context,
  ) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      final checkOutService = ref.read(checkoutServiceProvider);
      final cartNotifier = ref.read(cartProvider.notifier);
      final cartItems = ref.read(cartProvider);
      final cartSummary = ref.watch(cartSummaryProvider);

      final selectedDate = cartSummary['selectedDate'];

      final couponCode = cartSummary['appliedCoupon'].toString();

      final loadItems = cartItems.map((item) {
        final quantity = item.product.productTypeId == '2'
            ? item.quantityKg.round() // round to nearest int
            : item.quantityPcs; // already an int

        return {
          "prod_id": int.parse(item.product.id),
          "quantity": quantity,
          "rate": item.product.price.round(), // round price to int if needed
        };
      }).toList();

      final response = await checkOutService.placeOrder(
        loadItems: loadItems,
        deliveryDate: selectedDate.toString(),
        couponCode: couponCode,
      );

      if (response.reply == 'Saved') {
        // Order placed successfully
        state = state.copyWith(
          isLoading: false,
          orderResponse: response,
        );

        debugPrint('$response');

        cartItems.clear();

        context.push('/payment', extra: {
          'orderId': response.id,
          'razorpayId': response.razorpayId,
          'amount': response.amount,
          'razorpayKey': response.razorpayKey,
          'text': response.text,
        });
      } else {
        // Order failed
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to place order: ${response.text}',
        );

        Fluttertoast.showToast(
          msg: 'Failed to place order',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          backgroundColor: AppTheme.red,
          textColor: AppTheme.white,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error placing order: $e',
      );

      Fluttertoast.showToast(
        msg: 'Error: $e',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: AppTheme.red,
        textColor: AppTheme.white,
      );
    }
  }

  // Reset checkout state
  void resetCheckout() {
    state = CheckoutState();
  }
}

// Provider for Riverpod
final checkoutProvider =
    StateNotifierProvider<CheckoutNotifier, CheckoutState>((ref) {
  return CheckoutNotifier(ref);
});
