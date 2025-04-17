// Define the order response model
class OrderResponse {
  final String reply;
  final String id;
  final String razorpayId;
  final String codEnable;
  final String text;
  final String amount;
  final String razorpayKey;

  OrderResponse({
    required this.reply,
    required this.id,
    required this.razorpayId,
    required this.codEnable,
    required this.text,
    required this.amount,
    required this.razorpayKey,
  });

  factory OrderResponse.fromJson(Map<String, dynamic> json) {
    return OrderResponse(
      reply: json['reply'] ?? '',
      id: json['id'] ?? '',
      razorpayId: json['razorpay_id'] ?? '',
      codEnable: json['cod_enable'] ?? '0',
      text: json['text'] ?? '',
      amount: json['amt'] ?? '0',
      razorpayKey: json['razorpay_key'] ?? '',
    );
  }
  // Whether COD is enabled
  bool get isCodEnabled => codEnable == '1';

  // Amount as double
  double get amountAsDouble {
    try {
      return double.parse(amount);
    } catch (e) {
      return 0.0;
    }
  }
}
