import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart_item_model.dart';

class OrderModel {
  final String orderId;
  final List<CartItemModel> items;
  final double totalAmount;
  final String deliveryAddress;
  final DateTime orderDate;
  final String status; // "Pending", "Delivered", "Cancelled"

  OrderModel({
    required this.orderId,
    required this.items,
    required this.totalAmount,
    required this.deliveryAddress,
    required this.orderDate,
    required this.status,
  });

  factory OrderModel.fromMap(String id, Map<String, dynamic> data) {
    final itemsList = (data['items'] as List<dynamic>? ?? [])
        .map((i) => CartItemModel.fromMap(Map<String, dynamic>.from(i)))
        .toList();
    final rawDate = data['orderDate'];
    DateTime orderDate;
    if (rawDate is Timestamp) {
      orderDate = rawDate.toDate();
    } else {
      orderDate = DateTime.now();
    }
    return OrderModel(
      orderId: id,
      items: itemsList,
      totalAmount: (data['totalAmount'] ?? 0).toDouble(),
      deliveryAddress: data['deliveryAddress'] ?? '',
      orderDate: orderDate,
      status: data['status'] ?? 'Pending',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'items': items.map((i) => i.toMap()).toList(),
      'totalAmount': totalAmount,
      'deliveryAddress': deliveryAddress,
      'orderDate': Timestamp.fromDate(orderDate),
      'status': status,
    };
  }
}
