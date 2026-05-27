import 'package:shining/models/product_model.dart';
import 'package:shining/models/cart_item_model.dart';
import 'package:shining/models/order_model.dart';
import 'package:shining/models/user_model.dart';

class AppData {
  // Current logged-in user
  static UserModel currentUser = UserModel(
    id: 'user_001',
    fullName: 'Sarah Johnson',
    email: 'sarah.johnson@email.com',
    phone: '+1 (555) 123-4567',
    avatarUrl: 'https://i.pravatar.cc/150?img=1',
  );

  // Categories list
  static List<String> categories = [
    'Dresses',
    'Tops',
    'Jeans',
    'Bags',
    'Shoes',
    'Accessories',
  ];

  // Products list - 10+ products
  static List<ProductModel> products = [
    ProductModel(
      id: 'prod_001',
      name: 'Elegant Evening Dress',
      category: 'Dresses',
      price: 89.99,
      imageUrl: 'https://via.placeholder.com/300x400?text=Evening+Dress',
      description: 'A stunning evening dress perfect for special occasions. Made from premium fabric with a flattering silhouette.',
      sizes: ['XS', 'S', 'M', 'L', 'XL'],
      colors: ['Black', 'Burgundy', 'Navy'],
      rating: 4.8,
      reviewCount: 156,
      isNew: true,
    ),
    ProductModel(
      id: 'prod_002',
      name: 'Summer Floral Dress',
      category: 'Dresses',
      price: 59.99,
      imageUrl: 'https://via.placeholder.com/300x400?text=Floral+Dress',
      description: 'Light and breezy summer dress with beautiful floral patterns. Perfect for beach trips and outdoor gatherings.',
      sizes: ['XS', 'S', 'M', 'L', 'XL'],
      colors: ['Pink', 'Blue', 'White'],
      rating: 4.6,
      reviewCount: 89,
      isNew: false,
    ),
    ProductModel(
      id: 'prod_003',
      name: 'Classic White T-Shirt',
      category: 'Tops',
      price: 29.99,
      imageUrl: 'https://via.placeholder.com/300x400?text=White+Tshirt',
      description: 'Timeless classic white t-shirt made from 100% organic cotton. Versatile and comfortable for everyday wear.',
      sizes: ['XS', 'S', 'M', 'L', 'XL', 'XXL'],
      colors: ['White', 'Gray', 'Black'],
      rating: 4.7,
      reviewCount: 234,
      isNew: false,
    ),
    ProductModel(
      id: 'prod_004',
      name: 'Casual Striped Top',
      category: 'Tops',
      price: 39.99,
      imageUrl: 'https://via.placeholder.com/300x400?text=Striped+Top',
      description: 'Relaxed fit striped top perfect for casual outings. Features a comfortable fabric that breathes well.',
      sizes: ['XS', 'S', 'M', 'L', 'XL'],
      colors: ['Navy-White', 'Red-White', 'Black-White'],
      rating: 4.5,
      reviewCount: 124,
      isNew: true,
    ),
    ProductModel(
      id: 'prod_005',
      name: 'Slim Fit Blue Jeans',
      category: 'Jeans',
      price: 69.99,
      imageUrl: 'https://via.placeholder.com/300x400?text=Blue+Jeans',
      description: 'Stylish slim-fit jeans in classic blue. Perfect for pairing with any top for a casual look.',
      sizes: ['24', '25', '26', '27', '28', '29', '30', '32'],
      colors: ['Light Blue', 'Dark Blue', 'Black'],
      rating: 4.7,
      reviewCount: 312,
      isNew: false,
    ),
    ProductModel(
      id: 'prod_006',
      name: 'High-Waist Black Jeans',
      category: 'Jeans',
      price: 74.99,
      imageUrl: 'https://via.placeholder.com/300x400?text=Black+Jeans',
      description: 'Trendy high-waist black jeans that flatters every body shape. Made with premium denim for durability.',
      sizes: ['24', '25', '26', '27', '28', '29', '30', '32'],
      colors: ['Black', 'Dark Gray'],
      rating: 4.6,
      reviewCount: 198,
      isNew: true,
    ),
    ProductModel(
      id: 'prod_007',
      name: 'Leather Crossbody Bag',
      category: 'Bags',
      price: 119.99,
      imageUrl: 'https://via.placeholder.com/300x400?text=Leather+Bag',
      description: 'Premium leather crossbody bag with adjustable strap. Perfect for daily use with multiple compartments.',
      sizes: ['One Size'],
      colors: ['Brown', 'Black', 'Tan'],
      rating: 4.9,
      reviewCount: 287,
      isNew: false,
    ),
    ProductModel(
      id: 'prod_008',
      name: 'Canvas Tote Bag',
      category: 'Bags',
      price: 49.99,
      imageUrl: 'https://via.placeholder.com/300x400?text=Tote+Bag',
      description: 'Spacious canvas tote bag ideal for work, school, or shopping. Durable and eco-friendly material.',
      sizes: ['One Size'],
      colors: ['Beige', 'Navy', 'Gray'],
      rating: 4.4,
      reviewCount: 156,
      isNew: true,
    ),
    ProductModel(
      id: 'prod_009',
      name: 'White Sneakers',
      category: 'Shoes',
      price: 79.99,
      imageUrl: 'https://via.placeholder.com/300x400?text=White+Sneakers',
      description: 'Classic white sneakers with cushioned insoles for ultimate comfort. Perfect for casual everyday wear.',
      sizes: ['5', '6', '7', '8', '9', '10', '11', '12'],
      colors: ['White', 'White-Black'],
      rating: 4.8,
      reviewCount: 405,
      isNew: false,
    ),
    ProductModel(
      id: 'prod_010',
      name: 'Black Heeled Boots',
      category: 'Shoes',
      price: 129.99,
      imageUrl: 'https://via.placeholder.com/300x400?text=Heeled+Boots',
      description: 'Elegant black heeled boots perfect for dressing up any outfit. Comfortable heel height for all-day wear.',
      sizes: ['5', '6', '7', '8', '9', '10', '11', '12'],
      colors: ['Black'],
      rating: 4.7,
      reviewCount: 178,
      isNew: true,
    ),
    ProductModel(
      id: 'prod_011',
      name: 'Gold Statement Necklace',
      category: 'Accessories',
      price: 44.99,
      imageUrl: 'https://via.placeholder.com/300x400?text=Necklace',
      description: 'Eye-catching gold statement necklace to elevate any outfit. Made with high-quality materials.',
      sizes: ['One Size'],
      colors: ['Gold', 'Silver'],
      rating: 4.5,
      reviewCount: 92,
      isNew: false,
    ),
    ProductModel(
      id: 'prod_012',
      name: 'Silk Scarf',
      category: 'Accessories',
      price: 34.99,
      imageUrl: 'https://via.placeholder.com/300x400?text=Silk+Scarf',
      description: 'Luxurious silk scarf with beautiful prints. Versatile piece for various styling options.',
      sizes: ['One Size'],
      colors: ['Pink', 'Blue', 'Purple', 'Multicolor'],
      rating: 4.6,
      reviewCount: 134,
      isNew: true,
    ),
  ];

  // Cart items - starts empty
  static List<CartItemModel> cartItems = [];

  // Wishlist items - starts empty
  static List<ProductModel> wishlistItems = [];

  // Orders list - 2 sample past orders
  static List<OrderModel> orders = [
    OrderModel(
      orderId: 'ORD_001',
      items: [
        CartItemModel(
          id: 'cart_001',
          product: products[0],
          selectedSize: 'M',
          selectedColor: 'Black',
          quantity: 1,
        ),
      ],
      totalAmount: 89.99,
      deliveryAddress: '123 Main Street, New York, NY 10001',
      orderDate: DateTime(2024, 1, 15),
      status: 'Delivered',
    ),
    OrderModel(
      orderId: 'ORD_002',
      items: [
        CartItemModel(
          id: 'cart_002',
          product: products[2],
          selectedSize: 'M',
          selectedColor: 'White',
          quantity: 2,
        ),
        CartItemModel(
          id: 'cart_003',
          product: products[4],
          selectedSize: '28',
          selectedColor: 'Light Blue',
          quantity: 1,
        ),
      ],
      totalAmount: 169.97,
      deliveryAddress: '456 Oak Avenue, Los Angeles, CA 90001',
      orderDate: DateTime(2024, 2, 20),
      status: 'Pending',
    ),
  ];

  // Helper Methods

  /// Add a product to the cart with selected size and color
  static void addToCart(ProductModel product, String size, String color) {
    final cartItem = CartItemModel(
      id: 'cart_${DateTime.now().millisecondsSinceEpoch}',
      product: product,
      selectedSize: size,
      selectedColor: color,
      quantity: 1,
    );
    cartItems.add(cartItem);
  }

  /// Remove an item from the cart
  static void removeFromCart(String cartItemId) {
    cartItems.removeWhere((item) => item.id == cartItemId);
  }

  /// Update the quantity of a cart item
  static void updateCartQuantity(String cartItemId, int quantity) {
    for (var item in cartItems) {
      if (item.id == cartItemId) {
        item.quantity = quantity;
        break;
      }
    }
  }

  /// Add a product to the wishlist
  static void addToWishlist(ProductModel product) {
    if (!wishlistItems.any((item) => item.id == product.id)) {
      wishlistItems.add(product);
    }
  }

  /// Remove a product from the wishlist
  static void removeFromWishlist(String productId) {
    wishlistItems.removeWhere((item) => item.id == productId);
  }

  /// Check if a product is in the wishlist
  static bool isInWishlist(String productId) {
    return wishlistItems.any((item) => item.id == productId);
  }

  /// Get the total price of items in the cart
  static double getCartTotal() {
    double total = 0;
    for (var item in cartItems) {
      total += item.product.price * item.quantity;
    }
    return total;
  }

  /// Get all products of a specific category
  static List<ProductModel> getProductsByCategory(String category) {
    return products.where((product) => product.category == category).toList();
  }

  /// Place an order with current cart items
  static OrderModel placeOrder(List<CartItemModel> items, String address) {
    final orderId = 'ORD_${DateTime.now().millisecondsSinceEpoch}';
    final totalAmount = getCartTotal();
    
    final order = OrderModel(
      orderId: orderId,
      items: items,
      totalAmount: totalAmount,
      deliveryAddress: address,
      orderDate: DateTime.now(),
      status: 'Pending',
    );
    
    orders.add(order);
    cartItems.clear();
    
    return order;
  }
}
