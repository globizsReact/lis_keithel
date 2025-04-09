import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import 'package:lis_keithel/services/coupon_service.dart';
import '../models/models.dart'; // Import the model

final couponsProvider = FutureProvider<CouponResponse>((ref) async {
  final couponsService = CouponsService();

// Get cart items from the cart provider
  final cartItems = ref.watch(cartProvider);

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

  return await couponsService.getCoupons(loadItems); // Return CouponResponse
});
