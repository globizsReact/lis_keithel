import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lis_keithel/models/models.dart';
import 'package:lis_keithel/providers/cart_provider.dart';
import 'package:lis_keithel/services/delivery_date_service.dart';

final cartItemsHashProvider = Provider<String>((ref) {
  final cartItems = ref.watch(cartProvider);

  // Create a string hash that only changes when items or quantities change
  final hash = cartItems
      .map(
          (item) => '${item.product.id}:${item.quantityPcs}:${item.quantityKg}')
      .join('|');

  return hash;
});

final deliveryDatesProvider =
    FutureProvider.autoDispose<List<DeliveryDate>>((ref) async {
  // Watch only the cart items hash instead of the entire cart
  final itemsHash = ref.watch(cartItemsHashProvider);

  // Skip API call if cart is empty
  if (itemsHash.isEmpty) {
    return [];
  }

  // Get cart items from the cart provider
  final cartItems = ref.read(cartProvider);

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

  // Pass the transformed items to the fetch function
  return fetchDeliveryDates(loadItems);
});
