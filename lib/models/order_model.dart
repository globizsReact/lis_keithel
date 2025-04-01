import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum OrderStatus {
  noPayment,
  cancel,
  newOrder,
  paid,
}

extension OrderStatusExtension on OrderStatus {
  String get displayName {
    switch (this) {
      case OrderStatus.noPayment:
        return 'No payment';
      case OrderStatus.cancel:
        return 'Cancel';
      case OrderStatus.newOrder:
        return 'New order';
      case OrderStatus.paid:
        return 'Paid';
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.noPayment:
        return const Color(0xFFC2A600);
      case OrderStatus.cancel:
        return const Color(0xFFE74C3C);
      case OrderStatus.newOrder:
        return const Color(0xFF27AE60);
      case OrderStatus.paid:
        return const Color(0xFF2980B9);
    }
  }
}

class Order {
  final String id;
  final DateTime date;
  final OrderStatus status;
  final DateTime delDate;

  Order({
    required this.id,
    required this.date,
    required this.status,
    required this.delDate,
  });

  // double get subTotal => items.fold(0, (sum, item) => sum + item.total);

  factory Order.fromJson(Map<String, dynamic> json) {
    // Parse the date which is in format "28 Mar 2025"
    final DateFormat dateFormat = DateFormat('dd MMM yyyy');
    final DateTime parsedDate = dateFormat.parse(json['date']);

    // Parse delivery date which is in ISO format "2025-04-03"
    final DateTime parsedDelDate = DateTime.parse(json['del_date']);

    // Convert string status to enum
    OrderStatus orderStatus;
    switch (json['status']) {
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
        // Handle unknown status - either throw an error or default to a status
        debugPrint('Unknown status: ${json['status']}');
        orderStatus = OrderStatus.cancel; // Default value
        break;
    }

    return Order(
      id: json['id'].toString(), // Convert to string in case it's a number
      date: parsedDate,
      delDate: parsedDelDate,
      status: orderStatus,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'status': status.toString().split('.').last,
      'del_date': delDate.toIso8601String(),
    };
  }
}
