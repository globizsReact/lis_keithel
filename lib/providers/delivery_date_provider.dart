import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lis_keithel/models/models.dart';
import 'package:lis_keithel/providers/cart_provider.dart';
import 'package:lis_keithel/services/delivery_date_service.dart';

final deliveryDatesProvider =
    FutureProvider.autoDispose<List<DeliveryDate>>((ref) async {
  // Get cart items from the cart provider
  final cartItems = ref.watch(cartProvider);

  // Skip API call if cart is empty
  if (cartItems.isEmpty) {
    return [];
  }

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

  print(loadItems);

  // Pass the transformed items to the fetch function
  return fetchDeliveryDates(loadItems);
});
