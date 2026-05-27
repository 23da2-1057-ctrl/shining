import 'product_model.dart';

class CartItemModel {
  final String id;
  final ProductModel product;
  final String selectedSize;
  final String selectedColor;
  int quantity;

  CartItemModel({
    required this.id,
    required this.product,
    required this.selectedSize,
    required this.selectedColor,
    required this.quantity,
  });

  factory CartItemModel.fromMap(Map<String, dynamic> data) {
    return CartItemModel(
      id: data['id'] ?? '',
      product: ProductModel.fromMap(
          Map<String, dynamic>.from(data['product'] ?? {})),
      selectedSize: data['selectedSize'] ?? '',
      selectedColor: data['selectedColor'] ?? '',
      quantity: data['quantity'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product': product.toMap(),
      'selectedSize': selectedSize,
      'selectedColor': selectedColor,
      'quantity': quantity,
    };
  }
}
