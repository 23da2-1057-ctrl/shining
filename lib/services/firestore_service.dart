import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shining/models/cart_item_model.dart';
import 'package:shining/models/order_model.dart';
import 'package:shining/models/product_model.dart';
import 'package:shining/models/user_model.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  // ─── Products ────────────────────────────────────────────────────────────────

  Stream<List<ProductModel>> getProducts() {
    return _db.collection('products').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => ProductModel.fromFirestore(doc)).toList());
  }

  Stream<List<ProductModel>> getProductsByCategory(String category) {
    return _db
        .collection('products')
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ProductModel.fromFirestore(doc)).toList());
  }

  // ─── Cart ─────────────────────────────────────────────────────────────────────

  Stream<List<CartItemModel>> getCartItems(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('cart')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = Map<String, dynamic>.from(doc.data());
              data['id'] = doc.id;
              return CartItemModel.fromMap(data);
            }).toList());
  }

  Future<void> addToCart(
      String userId, ProductModel product, String size, String color) async {
    final ref = _db
        .collection('users')
        .doc(userId)
        .collection('cart')
        .doc();
    final item = CartItemModel(
      id: ref.id,
      product: product,
      selectedSize: size,
      selectedColor: color,
      quantity: 1,
    );
    await ref.set(item.toMap());
  }

  Future<void> removeFromCart(String userId, String cartItemId) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('cart')
        .doc(cartItemId)
        .delete();
  }

  Future<void> updateCartQuantity(
      String userId, String cartItemId, int quantity) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('cart')
        .doc(cartItemId)
        .update({'quantity': quantity});
  }

  Future<void> clearCart(String userId) async {
    final snapshot = await _db
        .collection('users')
        .doc(userId)
        .collection('cart')
        .get();
    final batch = _db.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  // ─── Wishlist ─────────────────────────────────────────────────────────────────

  Stream<List<ProductModel>> getWishlist(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('wishlist')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProductModel.fromMap(
                Map<String, dynamic>.from(doc.data())..['id'] = doc.id))
            .toList());
  }

  Future<void> addToWishlist(String userId, ProductModel product) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('wishlist')
        .doc(product.id)
        .set(product.toMap());
  }

  Future<void> removeFromWishlist(String userId, String productId) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('wishlist')
        .doc(productId)
        .delete();
  }

  // ─── Orders ───────────────────────────────────────────────────────────────────

  Stream<List<OrderModel>> getUserOrders(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('orders')
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<OrderModel> placeOrder(
      String userId, List<CartItemModel> items, String address) async {
    final ref = _db
        .collection('users')
        .doc(userId)
        .collection('orders')
        .doc();
    final total =
        items.fold<double>(0, (acc, i) => acc + i.product.price * i.quantity);
    final order = OrderModel(
      orderId: ref.id,
      items: items,
      totalAmount: total,
      deliveryAddress: address,
      orderDate: DateTime.now(),
      status: 'Pending',
    );
    await ref.set(order.toMap());
    await clearCart(userId);
    return order;
  }

  // ─── User Profile ─────────────────────────────────────────────────────────────

  Stream<UserModel?> getUserProfile(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);
  }

  Future<void> saveUserProfile(String userId, UserModel user) async {
    await _db.collection('users').doc(userId).set(user.toMap());
  }

  Future<void> updateUserProfile(
      String userId, Map<String, dynamic> fields) async {
    await _db.collection('users').doc(userId).update(fields);
  }
}
