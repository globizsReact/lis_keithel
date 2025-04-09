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
}

List<DeliveryDate> parseDeliveryDates(Map<String, dynamic> jsonResponse) {
  List<DeliveryDate> deliveryDates = [];

  jsonResponse.forEach((date, data) {
    deliveryDates.add(DeliveryDate.fromJson(date, data));
  });

  return deliveryDates;
}
