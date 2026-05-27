import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shining/data/app_data.dart';
import 'package:shining/models/cart_item_model.dart';
import 'package:shining/models/order_model.dart';
import 'package:shining/services/firestore_service.dart';

const Color _primary = Color(0xFFB6004F);
const Color _secondary = Color(0xFF7738C0);
const Color _tertiary = Color(0xFF695B00);
const Color _surface = Color(0xFFF6F6F6);
const Color _surfaceContainerLowest = Color(0xFFFFFFFF);
const Color _surfaceContainerHighest = Color(0xFFDBDDDD);
const Color _surfaceContainerHigh = Color(0xFFE1E3E3);
const Color _surfaceContainerLow = Color(0xFFF0F1F1);
const Color _onSurface = Color(0xFF2D2F2F);
const Color _onSurfaceVariant = Color(0xFF5A5C5C);
const Color _outline = Color(0xFF767777);
const Color _tertiaryContainer = Color(0xFFFADD30);
const Color _onTertiaryContainer = Color(0xFF5B4E00);

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  int _selectedFilter = 0;
  final List<String> _filters = ['All Orders', 'Delivered', 'Active'];
  final _searchController = TextEditingController();

  final _firestoreService = FirestoreService();
  List<OrderModel> _orders = [];
  StreamSubscription<List<OrderModel>>? _ordersSub;

  @override
  void initState() {
    super.initState();
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      // Seed 2 demo orders into Firestore if the user has none yet
      _seedDemoOrdersIfEmpty(userId);
      _ordersSub = _firestoreService.getUserOrders(userId).listen((orders) {
        if (mounted) setState(() => _orders = orders);
      });
    }
  }

  /// Writes two sample orders (one Delivered, one Pending) into Firestore
  /// only on the very first open — subsequent calls are instant no-ops.
  Future<void> _seedDemoOrdersIfEmpty(String userId) async {
    final db = FirebaseFirestore.instance;
    final existing = await db
        .collection('users')
        .doc(userId)
        .collection('orders')
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) return; // already has orders

    final batch = db.batch();

    // Demo order 1 — Delivered
    final ref1 =
        db.collection('users').doc(userId).collection('orders').doc();
    batch.set(
      ref1,
      OrderModel(
        orderId: ref1.id,
        items: [
          CartItemModel(
            id: 'demo_item_1',
            product: AppData.products[0], // Elegant Evening Dress
            selectedSize: 'M',
            selectedColor: 'Black',
            quantity: 1,
          ),
        ],
        totalAmount: AppData.products[0].price,
        deliveryAddress: '123 Main Street, New York, NY 10001',
        orderDate: DateTime(2024, 1, 15),
        status: 'Delivered',
      ).toMap(),
    );

    // Demo order 2 — Pending (2 items)
    final ref2 =
        db.collection('users').doc(userId).collection('orders').doc();
    batch.set(
      ref2,
      OrderModel(
        orderId: ref2.id,
        items: [
          CartItemModel(
            id: 'demo_item_2',
            product: AppData.products[2], // Classic White T-Shirt
            selectedSize: 'M',
            selectedColor: 'White',
            quantity: 2,
          ),
          CartItemModel(
            id: 'demo_item_3',
            product: AppData.products[4], // Slim Fit Blue Jeans
            selectedSize: '28',
            selectedColor: 'Light Blue',
            quantity: 1,
          ),
        ],
        totalAmount:
            AppData.products[2].price * 2 + AppData.products[4].price,
        deliveryAddress: '456 Oak Avenue, Los Angeles, CA 90001',
        orderDate: DateTime(2024, 2, 20),
        status: 'Pending',
      ).toMap(),
    );

    await batch.commit();
  }

  @override
  void dispose() {
    _ordersSub?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  List<OrderModel> get _filteredOrders {
    var orders = _orders;
    final query = _searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      orders = orders
          .where((o) => o.orderId.toLowerCase().contains(query))
          .toList();
    }
    switch (_selectedFilter) {
      case 1:
        return orders.where((o) => o.status == 'Delivered').toList();
      case 2:
        return orders.where((o) => o.status == 'Pending').toList();
      default:
        return orders;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      appBar: _buildTopBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(),
            const SizedBox(height: 16),
            _buildFilterChips(),
            const SizedBox(height: 24),
            ..._filteredOrders.isEmpty
                ? [_buildEmpty()]
                : _filteredOrders.map((o) => _buildOrderTile(o)),
            const SizedBox(height: 32),
            _buildRecommendedSection(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildTopBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(64),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.85),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF2D78).withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: SizedBox(
            height: 64,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_rounded,
                        color: Color(0xFFE91E8C), size: 24),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'My Orders 📦',
                        style: GoogleFonts.epilogue(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                          color: const Color(0xFF1A1A1A),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/cart'),
                    child: const Icon(Icons.shopping_bag_outlined,
                        color: Color(0xFFE91E8C), size: 24),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: _surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (_) => setState(() {}),
        style: GoogleFonts.plusJakartaSans(fontSize: 14, color: _onSurface),
        decoration: InputDecoration(
          hintText: 'Find an order ID...',
          hintStyle: GoogleFonts.plusJakartaSans(
              fontSize: 14, color: _outline),
          prefixIcon: const Icon(Icons.search_rounded, color: _outline),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                BorderSide(color: _primary.withValues(alpha: 0.25), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_filters.length, (i) {
          final active = i == _selectedFilter;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: active ? _primary : _surfaceContainerHigh,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                _filters[i],
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                  color: active
                      ? const Color(0xFFFFEFF0)
                      : _onSurfaceVariant,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildEmpty() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.receipt_long_outlined,
                size: 64, color: _surfaceContainerHighest),
            const SizedBox(height: 16),
            Text(
              'No orders found',
              style: GoogleFonts.epilogue(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: _onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderTile(OrderModel order) {
    final statusConfig = _statusConfig(order.status);
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ORDER ID: #${order.orderId}',
                      style: GoogleFonts.epilogue(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                        color: _outline,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Placed on ${_formatDate(order.orderDate)}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: statusConfig['bg'] as Color,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  order.status.toUpperCase(),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                    color: statusConfig['text'] as Color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Thumbnails + total
          Row(
            children: [
              SizedBox(
                height: 56,
                width: 180,
                child: Stack(
                  children: [
                    ...List.generate(
                      order.items.length.clamp(0, 3),
                      (i) => Positioned(
                        left: i * 38.0,
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: _surfaceContainerLowest, width: 3),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: order.items[i].product.imageUrl.isNotEmpty
                                ? Image.network(
                                    order.items[i].product.imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => Container(
                                      color: _surfaceContainerHigh,
                                      child: const Icon(Icons.checkroom_rounded,
                                          size: 22, color: _outline),
                                    ),
                                  )
                                : Container(
                                    color: _surfaceContainerHigh,
                                    child: const Icon(Icons.checkroom_rounded,
                                        size: 22, color: _outline),
                                  ),
                          ),
                        ),
                      ),
                    ),
                    if (order.items.length > 3)
                      Positioned(
                        left: 3 * 38.0,
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: _surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: _surfaceContainerLowest, width: 3),
                          ),
                          child: Center(
                            child: Text(
                              '+${order.items.length - 3}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: _onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Total',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _outline,
                    ),
                  ),
                  Text(
                    '\$${order.totalAmount.toStringAsFixed(2)}',
                    style: GoogleFonts.epilogue(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: order.status == 'Cancelled'
                          ? _onSurfaceVariant
                          : _primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Action buttons
          Row(
            children: _buildActionButtons(order),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildActionButtons(OrderModel order) {
    TextStyle btnStyle(bool filled) => GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
          color: filled ? _primary : _onSurface,
        );

    Widget pill(String label, bool filled, VoidCallback onTap) {
      return Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: filled
                  ? _primary.withValues(alpha: 0.1)
                  : _surfaceContainerLow,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Center(
              child: Text(label.toUpperCase(), style: btnStyle(filled)),
            ),
          ),
        ),
      );
    }

    switch (order.status) {
      case 'Delivered':
        return [
          pill('Order Details', false, () {}),
          const SizedBox(width: 10),
          pill('Buy Again', true, () {}),
        ];
      case 'Pending':
        return [pill('Track Shipment', false, () {})];
      default:
        return [pill('Refund Status', false, () {})];
    }
  }

  Widget _buildRecommendedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'RECOMMENDED FOR YOU',
          style: GoogleFonts.epilogue(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.3,
            color: _onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CYBER DROP',
                        style: GoogleFonts.epilogue(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                          color: _secondary,
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.checkroom_rounded,
                          size: 48,
                          color: _secondary.withValues(alpha: 0.3)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _tertiary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ESSENTIALS',
                        style: GoogleFonts.epilogue(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                          color: _tertiary,
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.headphones_rounded,
                          size: 48,
                          color: _tertiary.withValues(alpha: 0.3)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Map<String, Color> _statusConfig(String status) {
    switch (status) {
      case 'Delivered':
        return {
          'bg': const Color(0xFFDCFCE7),
          'text': const Color(0xFF15803D),
        };
      case 'Pending':
        return {
          'bg': _tertiaryContainer,
          'text': _onTertiaryContainer,
        };
      default:
        return {
          'bg': const Color(0xFFFEE2E2),
          'text': const Color(0xFFB91C1C),
        };
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

}
