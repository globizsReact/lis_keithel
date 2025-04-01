import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'order_model.dart';

class OrderDetail {
  final String clientId;
  final String clientName;
  final String date;
  final String status; // Status as a string
  final DateTime delDate;
  final String paymentMode;
  final String canCancel;
  final String cancelRemark;
  final String cancelTime;
  final String remark;
  final String disAmount;
  final String rewardPointDiscount;
  final String delivery;
  final String? orderFeedback;
  final String? deliveryFeedback;
  final List<OrderItem> items;

  OrderDetail({
    required this.clientId,
    required this.clientName,
    required this.date,
    required this.status,
    required this.delDate,
    required this.paymentMode,
    required this.canCancel,
    required this.cancelRemark,
    required this.cancelTime,
    required this.remark,
    required this.disAmount,
    required this.rewardPointDiscount,
    required this.delivery,
    this.orderFeedback,
    this.deliveryFeedback,
    required this.items,
  });

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
// Parse the date which is in format "28 Mar 2025"

    final DateTime parsedDate =
        DateTime.parse(json['date'].replaceAll(' ', 'T'));
    String formattedDate = DateFormat.yMMMd().add_jm().format(parsedDate);

    // Parse delivery date which is in ISO format "2025-04-03"
    final DateTime parsedDelDate = DateTime.parse(json['del_date']);

    return OrderDetail(
      clientId: json['client_id'],
      clientName: json['client_name'],
      date: formattedDate,
      status: json['status'],
      delDate: parsedDelDate,
      paymentMode: json['payment_mode'],
      canCancel: json['can_cancel'],
      cancelRemark: json['cancel_remark'],
      cancelTime: json['cancel_time'],
      remark: json['remark'],
      disAmount: json['dis_amount'],
      rewardPointDiscount: json['reward_point_discount'],
      delivery: json['delivery'],
      orderFeedback: json['order_feedback'],
      deliveryFeedback: json['delivery_feedback'],
      items: (json['items'] as List<dynamic>)
          .map((item) => OrderItem.fromJson(item))
          .toList(),
    );
  }

  // Computed property to get the color based on the status
  Color get statusColor {
    // Map the status string to the OrderStatus enum
    OrderStatus orderStatus;
    switch (status) {
      case 'No Payment':
        orderStatus = OrderStatus.noPayment;
        break;
      case 'Cancel':
        orderStatus = OrderStatus.cancel;
        break;
      case 'New Order':
        orderStatus = OrderStatus.newOrder;
        break;
      case 'Paid':
        orderStatus = OrderStatus.paid;
        break;
      default:
        // Handle unknown status - default to a neutral color
        debugPrint('Unknown status: $status');
        return Colors.grey; // Default color for unknown statuses
    }
    // Return the color associated with the OrderStatus
    return orderStatus.color;
  }

  // Calculate total amount from all items
  double get totalAmount {
    double total = 0.0;
    for (var item in items) {
      // Parse amount and quantity to double
      // Remove any currency symbols or commas from the amount string
      final cleanAmount = item.amount.replaceAll(RegExp(r'[^\d\.\-]'), '');
      final double itemAmount = double.tryParse(cleanAmount) ?? 0.0;
      final double itemQuantity = double.tryParse(item.quantity) ?? 0.0;

      total += itemAmount * itemQuantity;
    }
    return total;
  }

  // Formatted total amount with currency symbol if needed
  String get formattedTotalAmount {
    return totalAmount.toStringAsFixed(2);
    // Or use NumberFormat for more complex formatting
    // return NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(totalAmount);
  }
}

class OrderItem {
  final String product;
  final String amount;
  final String quantity;

  OrderItem({
    required this.product,
    required this.amount,
    required this.quantity,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      product: json['product'],
      amount: json['amount'],
      quantity: json['quantity'],
    );
  }
}
