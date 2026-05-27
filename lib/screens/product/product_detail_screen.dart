import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shining/models/product_model.dart';
import 'package:shining/services/firestore_service.dart';

const Color _primary = Color(0xFFB6004F);
const Color _secondary = Color(0xFF7738C0);
const Color _surface = Color(0xFFF6F6F6);
const Color _surfaceContainerLowest = Color(0xFFFFFFFF);
const Color _surfaceContainerHigh = Color(0xFFE1E3E3);
const Color _surfaceContainer = Color(0xFFE7E8E8);
const Color _onSurface = Color(0xFF2D2F2F);
const Color _onSurfaceVariant = Color(0xFF5A5C5C);
const Color _tertiary = Color(0xFF695B00);

final List<Color> _colorSwatches = [
  _primary,
  _secondary,
  const Color(0xFFFADD30),
  const Color(0xFF1A1A1A),
];

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late String _selectedSize;
  late String _selectedColor;
  int _selectedColorIndex = 0;
  int _quantity = 1;

  final _firestoreService = FirestoreService();
  bool _isWishlisted = false;
  StreamSubscription<List<ProductModel>>? _wishlistSub;

  @override
  void initState() {
    super.initState();
    _selectedSize =
        widget.product.sizes.isNotEmpty ? widget.product.sizes.first : '';
    _selectedColor =
        widget.product.colors.isNotEmpty ? widget.product.colors.first : '';
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      _wishlistSub = _firestoreService.getWishlist(userId).listen((items) {
        if (mounted) {
          setState(() =>
              _isWishlisted = items.any((p) => p.id == widget.product.id));
        }
      });
    }
  }

  @override
  void dispose() {
    _wishlistSub?.cancel();
    super.dispose();
  }

  Future<void> _addToCart() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;
    for (int i = 0; i < _quantity; i++) {
      await _firestoreService.addToCart(
          userId, widget.product, _selectedSize, _selectedColor);
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.product.name} added to cart!'),
        backgroundColor: _primary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWishlisted = _isWishlisted;
    return Scaffold(
      backgroundColor: _surface,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHero(isWishlisted)),
              SliverToBoxAdapter(child: _buildSheet()),
            ],
          ),
          _buildTopBar(context),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
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
                        'SHINING STORE',
                        style: GoogleFonts.epilogue(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.5,
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

  Widget _buildHero(bool isWishlisted) {
    return Container(
      height: 530 + MediaQuery.of(context).padding.top,
      color: _surfaceContainerHigh,
      child: Stack(
        fit: StackFit.expand,
        children: [
          widget.product.imageUrl.isNotEmpty
              ? Image.network(
                  widget.product.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    color: _surfaceContainerHigh,
                    child: const Icon(Icons.checkroom_rounded,
                        size: 80, color: Color(0xFFACADAD)),
                  ),
                )
              : Container(
                  color: _surfaceContainerHigh,
                  child: const Icon(Icons.checkroom_rounded,
                      size: 80, color: Color(0xFFACADAD)),
                ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 72,
            right: 24,
            child: GestureDetector(
              onTap: () {
                final uid = FirebaseAuth.instance.currentUser?.uid;
                if (uid == null) return;
                if (isWishlisted) {
                  _firestoreService.removeFromWishlist(uid, widget.product.id);
                } else {
                  _firestoreService.addToWishlist(uid, widget.product);
                }
              },
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Icon(
                  isWishlisted ? Icons.favorite_rounded : Icons.favorite_rounded,
                  color: isWishlisted ? _primary : _primary,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSheet() {
    return Container(
      margin: const EdgeInsets.only(top: -48),
      decoration: const BoxDecoration(
        color: _surfaceContainerLowest,
        borderRadius: BorderRadius.vertical(top: Radius.circular(48)),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 30,
            offset: Offset(0, -8),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(32, 40, 32, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name + price
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  widget.product.name,
                  style: GoogleFonts.epilogue(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                    color: _onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '\$${widget.product.price.toStringAsFixed(2)}',
                style: GoogleFonts.epilogue(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: _primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Rating row
          Row(
            children: [
              ...List.generate(4, (_) => const Icon(Icons.star_rounded,
                  size: 16, color: _tertiary)),
              const Icon(Icons.star_half_rounded, size: 16, color: _tertiary),
              const SizedBox(width: 6),
              Text(
                '(${widget.product.reviewCount} Reviews)',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  color: _onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Size selector
          _sectionLabel('Select Size'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: widget.product.sizes.map((size) {
              final active = _selectedSize == size;
              return GestureDetector(
                onTap: () => setState(() => _selectedSize = size),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: active ? Colors.transparent : _surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: active ? _primary : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      size,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: active ? _primary : _onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 28),

          // Color selector
          _sectionLabel('Select Color'),
          const SizedBox(height: 12),
          Row(
            children: List.generate(_colorSwatches.length, (i) {
              final active = i == _selectedColorIndex;
              return GestureDetector(
                onTap: () => setState(() {
                  _selectedColorIndex = i;
                  if (i < widget.product.colors.length) {
                    _selectedColor = widget.product.colors[i];
                  }
                }),
                child: Container(
                  margin: const EdgeInsets.only(right: 14),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _colorSwatches[i],
                    shape: BoxShape.circle,
                    border: active
                        ? Border.all(
                            color: _surfaceContainer,
                            width: 3,
                            strokeAlign: BorderSide.strokeAlignOutside,
                          )
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 28),

          // Description
          _sectionLabel('Description'),
          const SizedBox(height: 10),
          Text(
            widget.product.description,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: _onSurfaceVariant,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 32),

          // Quantity + Add to Cart
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: _surfaceContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (_quantity > 1) setState(() => _quantity--);
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        child: const Icon(Icons.remove_rounded,
                            size: 18, color: _onSurface),
                      ),
                    ),
                    SizedBox(
                      width: 32,
                      child: Center(
                        child: Text(
                          '$_quantity',
                          style: GoogleFonts.epilogue(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _onSurface,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _quantity++),
                      child: Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        child: const Icon(Icons.add_rounded,
                            size: 18, color: _onSurface),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: GestureDetector(
                  onTap: _addToCart,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
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
                    child: Center(
                      child: Text(
                        'Add to Cart 🛒',
                        style: GoogleFonts.epilogue(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Wishlist link
          Center(
            child: GestureDetector(
              onTap: () {
                final uid = FirebaseAuth.instance.currentUser?.uid;
                if (uid == null) return;
                if (_isWishlisted) {
                  _firestoreService.removeFromWishlist(uid, widget.product.id);
                } else {
                  _firestoreService.addToWishlist(uid, widget.product);
                }
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.favorite_border_rounded,
                      size: 16, color: _primary),
                  const SizedBox(width: 6),
                  Text(
                    'Add to Wishlist 🤍',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return const SizedBox.shrink();
  }

  Widget _sectionLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: GoogleFonts.plusJakartaSans(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
        color: _onSurfaceVariant,
      ),
    );
  }
}
