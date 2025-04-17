class DeliveryDate {
  final String date;
  final Map<String, dynamic> productAvailability;
  final String price;

  DeliveryDate({
    required this.date,
    required this.productAvailability,
    required this.price,
  });

  factory DeliveryDate.fromJson(String date, Map<String, dynamic> json) {
    return DeliveryDate(
      date: date,
      productAvailability: Map<String, dynamic>.from(json),
      price: json['price'],
    );
  }

  // Helper method to get the price as double
  double getPriceAsDouble() {
    return double.parse(price.replaceAll(",", ""));
  }
}

// Simplified DeliveryOption class with just date and price
class DeliveryOption {
  final String date;
  final double price;

  DeliveryOption({
    required this.date,
    required this.price,
  });
}

// Updated function to create delivery option based on the simplified model
DeliveryOption createDeliveryOption(DeliveryDate deliveryDate) {
  return DeliveryOption(
    date: deliveryDate.date,
    price: deliveryDate.getPriceAsDouble(),
  );
}

List<DeliveryDate> parseDeliveryDates(Map<String, dynamic> jsonResponse) {
  List<DeliveryDate> deliveryDates = [];

  jsonResponse.forEach((date, data) {
    deliveryDates.add(DeliveryDate.fromJson(date, data));
  });

  return deliveryDates;
}
