class CartItem {
  final String name;
  final double pricePerUnit;
  final int quantity;

  CartItem({
    required this.name,
    required this.pricePerUnit,
    required this.quantity,
  });

  double get totalPrice => pricePerUnit * quantity;
}
