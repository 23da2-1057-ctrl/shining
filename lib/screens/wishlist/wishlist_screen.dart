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
const Color _surfaceContainerLow = Color(0xFFF0F1F1);
const Color _surfaceContainerHighest = Color(0xFFDBDDDD);
const Color _onSurface = Color(0xFF2D2F2F);
const Color _onSurfaceVariant = Color(0xFF5A5C5C);
const Color _outlineVariant = Color(0xFFACADAD);
const Color _tertiaryContainer = Color(0xFFFADD30);
const Color _onTertiaryContainer = Color(0xFF5B4E00);
const Color _tertiary = Color(0xFF695B00);

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final _firestoreService = FirestoreService();
  List<ProductModel> _wishlistItems = [];
  StreamSubscription<List<ProductModel>>? _wishlistSub;

  @override
  void initState() {
    super.initState();
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      _wishlistSub = _firestoreService.getWishlist(userId).listen((items) {
        if (mounted) setState(() => _wishlistItems = items);
      });
    }
  }

  @override
  void dispose() {
    _wishlistSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = _wishlistItems;
    return Scaffold(
      backgroundColor: _surface,
      appBar: _buildTopBar(context),
      body: items.isEmpty ? _buildEmpty(context) : _buildContent(context, items),
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
                  if (Navigator.canPop(context))
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back_rounded,
                          color: Color(0xFFE91E8C), size: 24),
                    )
                  else
                    const SizedBox(width: 24),
                  Expanded(
                    child: Center(
                      child: Text(
                        'My Wishlist 🤍',
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

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border_rounded, size: 72, color: _outlineVariant),
          const SizedBox(height: 16),
          Text(
            'Your wishlist is empty',
            style: GoogleFonts.epilogue(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: _onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Save items you love here',
            style: GoogleFonts.plusJakartaSans(
                fontSize: 14, color: _onSurfaceVariant),
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
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Start Shopping',
                style: GoogleFonts.epilogue(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<ProductModel> items) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Editorial header
          Text(
            'Curated\nFavorites',
            style: GoogleFonts.epilogue(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
              height: 1.1,
              color: _onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: _tertiaryContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${items.length} ITEMS',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: _onTertiaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(height: 1, color: _surfaceContainerHighest),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Staggered 2-column grid
          _buildStaggeredGrid(context, items),
          const SizedBox(height: 48),

          // CTA button
          Center(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 32, vertical: 16),
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
                child: Text(
                  'Find More Treasures',
                  style: GoogleFonts.epilogue(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.2,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaggeredGrid(BuildContext context, List<ProductModel> items) {
    // Split into left and right columns
    final leftItems = <ProductModel>[];
    final rightItems = <ProductModel>[];
    for (int i = 0; i < items.length; i++) {
      if (i.isEven) {
        leftItems.add(items[i]);
      } else {
        rightItems.add(items[i]);
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: leftItems
                .map((p) => _buildWishlistCard(context, p, false))
                .toList(),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            children: [
              const SizedBox(height: 32),
              ...rightItems
                  .map((p) => _buildWishlistCard(context, p, true)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWishlistCard(
      BuildContext context, ProductModel product, bool rotateRight) {
    final angle = rotateRight ? 0.017 : -0.035;
    final categoryColors = [_primary, _secondary, _tertiary];
    final colorIndex = _wishlistItems.indexOf(product) % categoryColors.length;
    final categoryColor = colorIndex >= 0 ? categoryColors[colorIndex] : _primary;

    return GestureDetector(
      onTap: () =>
          Navigator.pushNamed(context, '/product-detail', arguments: product),
      child: Container(
        margin: const EdgeInsets.only(bottom: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: _surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(8),
              child: Stack(
                children: [
                  // Image with slight tilt
                  Transform.rotate(
                    angle: angle,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: AspectRatio(
                        aspectRatio: 4 / 5,
                        child: product.imageUrl.isNotEmpty
                            ? Image.network(
                                product.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Container(
                                  color: _surfaceContainerLow,
                                  child: const Icon(Icons.checkroom_rounded,
                                      size: 40, color: _outlineVariant),
                                ),
                              )
                            : Container(
                                color: _surfaceContainerLow,
                                child: const Icon(Icons.checkroom_rounded,
                                    size: 40, color: _outlineVariant),
                              ),
                      ),
                    ),
                  ),
                  // Remove button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () {
                        final uid = FirebaseAuth.instance.currentUser?.uid;
                        if (uid != null) {
                          _firestoreService.removeFromWishlist(uid, product.id);
                        }
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.92),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.close_rounded,
                            size: 16, color: _onSurfaceVariant),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.category.toUpperCase(),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: categoryColor,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.epilogue(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _onSurface,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: _onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
