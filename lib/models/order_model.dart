// order_model.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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
        return const Color(0xFFD35400);
      case OrderStatus.cancel:
        return const Color(0xFFE74C3C);
      case OrderStatus.newOrder:
        return const Color(0xFF27AE60);
      case OrderStatus.paid:
        return const Color(0xFF2980B9);
    }
  }
}

class OrderItem {
  final String name;
  final double pricePerKg;
  final int quantity;
  final String imageUrl;

  OrderItem({
    required this.name,
    required this.pricePerKg,
    required this.quantity,
    required this.imageUrl,
  });

  double get total => pricePerKg * quantity;

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      name: json['name'],
      pricePerKg: json['pricePerKg'].toDouble(),
      quantity: json['quantity'],
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'pricePerKg': pricePerKg,
      'quantity': quantity,
      'imageUrl': imageUrl,
    };
  }
}

class Order {
  final String id;
  final DateTime date;
  final OrderStatus status;
  final List<OrderItem> items;
  final String? imageUrl;

  Order({
    required this.id,
    required this.date,
    required this.status,
    required this.items,
    this.imageUrl,
  });

  double get subTotal => items.fold(0, (sum, item) => sum + item.total);

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      date: DateTime.parse(json['date']),
      status: OrderStatus.values
          .firstWhere((e) => e.toString() == 'OrderStatus.${json['status']}'),
      items: (json['items'] as List)
          .map((item) => OrderItem.fromJson(item))
          .toList(),
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'status': status.toString().split('.').last,
      'items': items.map((item) => item.toJson()).toList(),
      'imageUrl': imageUrl,
    };
  }
}
