import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shining/models/cart_item_model.dart';
import 'package:shining/services/firestore_service.dart';

const Color _primary = Color(0xFFB6004F);
const Color _secondary = Color(0xFF7738C0);
const Color _surface = Color(0xFFF6F6F6);
const Color _surfaceContainerLowest = Color(0xFFFFFFFF);
const Color _surfaceContainerLow = Color(0xFFF0F1F1);
const Color _surfaceContainer = Color(0xFFE7E8E8);
const Color _onSurface = Color(0xFF2D2F2F);
const Color _onSurfaceVariant = Color(0xFF5A5C5C);
const Color _outlineVariant = Color(0xFFACADAD);
const Color _tertiaryContainer = Color(0xFFFADD30);
const Color _onTertiaryContainer = Color(0xFF5B4E00);

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _firestoreService = FirestoreService();
  List<CartItemModel> _items = [];
  StreamSubscription<List<CartItemModel>>? _cartSub;

  @override
  void initState() {
    super.initState();
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      _cartSub = _firestoreService.getCartItems(userId).listen((items) {
        if (mounted) setState(() => _items = items);
      });
    }
  }

  @override
  void dispose() {
    _cartSub?.cancel();
    super.dispose();
  }

  double get _subtotal =>
      _items.fold(0, (sum, i) => sum + i.product.price * i.quantity);

  @override
  Widget build(BuildContext context) {
    final items = _items;
    final subtotal = _subtotal;

    return Scaffold(
      backgroundColor: _surface,
      appBar: _buildTopBar(context, items.length),
      body: items.isEmpty ? _buildEmpty(context) : _buildContent(items, subtotal),
    );
  }

  PreferredSizeWidget _buildTopBar(BuildContext context, int count) {
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
                  if (Navigator.canPop(context))
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back_rounded,
                          color: Color(0xFFE91E8C), size: 24),
                    )
                  else
                    const SizedBox(width: 24),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'MY CART 🛒',
                          style: GoogleFonts.epilogue(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                            color: const Color(0xFF1A1A1A),
                          ),
                        ),
                        if (count > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _primary,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '$count',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFFFEFF0),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Icon(Icons.shopping_bag_outlined,
                      color: Color(0xFFE91E8C), size: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined,
              size: 72, color: _outlineVariant),
          const SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: GoogleFonts.epilogue(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: _onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add items to get started',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: _onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 28),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [_primary, _secondary]),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'CONTINUE SHOPPING',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(List<CartItemModel> items, double subtotal) {
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 200),
          children: [
            ...items.map((item) => _buildCartItem(item)),
            const SizedBox(height: 32),
            _buildOrderSummary(subtotal),
          ],
        ),
        _buildCheckoutButton(),
      ],
    );
  }

  Widget _buildCartItem(CartItemModel item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 88,
              height: 88,
              color: _surfaceContainer,
              child: item.product.imageUrl.isNotEmpty
                  ? Image.network(
                      item.product.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.checkroom_rounded,
                        size: 36,
                        color: _outlineVariant,
                      ),
                    )
                  : const Icon(
                      Icons.checkroom_rounded,
                      size: 36,
                      color: _outlineVariant,
                    ),
            ),
          ),
          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'SIZE: ${item.selectedSize} • ${item.selectedColor.toUpperCase()}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                    color: _onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 10),
                // Qty stepper
                Container(
                  decoration: BoxDecoration(
                    color: _surfaceContainerLow,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () {
                          final uid = FirebaseAuth.instance.currentUser?.uid;
                          if (uid != null && item.quantity > 1) {
                            _firestoreService.updateCartQuantity(
                                uid, item.id, item.quantity - 1);
                          }
                        },
                        child: Container(
                          width: 28,
                          height: 28,
                          alignment: Alignment.center,
                          child: const Icon(Icons.remove_rounded,
                              size: 14, color: _primary),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          '${item.quantity}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _onSurface,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          final uid = FirebaseAuth.instance.currentUser?.uid;
                          if (uid != null) {
                            _firestoreService.updateCartQuantity(
                                uid, item.id, item.quantity + 1);
                          }
                        },
                        child: Container(
                          width: 28,
                          height: 28,
                          alignment: Alignment.center,
                          child: const Icon(Icons.add_rounded,
                              size: 14, color: _primary),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Delete + Price
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () {
                  final uid = FirebaseAuth.instance.currentUser?.uid;
                  if (uid != null) {
                    _firestoreService.removeFromCart(uid, item.id);
                  }
                },
                child: const Icon(Icons.delete_outline_rounded,
                    size: 20, color: _onSurfaceVariant),
              ),
              const SizedBox(height: 24),
              Text(
                '\$${(item.product.price * item.quantity).toStringAsFixed(2)}',
                style: GoogleFonts.epilogue(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                  color: _primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(double subtotal) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ORDER SUMMARY',
            style: GoogleFonts.epilogue(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
              color: _onSurface,
            ),
          ),
          const SizedBox(height: 16),
          _summaryRow(
            'Subtotal',
            '\$${subtotal.toStringAsFixed(2)}',
            valueStyle: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: _onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Delivery Fee',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: _onSurfaceVariant,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: _tertiaryContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'FREE',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: _onTertiaryContainer,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Divider(
                color: _outlineVariant.withValues(alpha: 0.25), thickness: 1),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Amount',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _onSurface,
                ),
              ),
              Text(
                '\$${subtotal.toStringAsFixed(2)}',
                style: GoogleFonts.epilogue(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                  color: _primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value,
      {TextStyle? valueStyle}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
              fontSize: 14, color: _onSurfaceVariant),
        ),
        Text(value, style: valueStyle),
      ],
    );
  }

  Widget _buildCheckoutButton() {
    return Positioned(
      bottom: 84,
      left: 24,
      right: 24,
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, '/checkout'),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_primary, _secondary],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: _primary.withValues(alpha: 0.25),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'PROCEED TO CHECKOUT',
                style: GoogleFonts.epilogue(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded,
                  color: Colors.white, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
