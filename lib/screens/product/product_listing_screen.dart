import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shining/models/product_model.dart';
import 'package:shining/services/firestore_service.dart';

const Color _primary = Color(0xFFB6004F);
const Color _surface = Color(0xFFF6F6F6);
const Color _surfaceContainerHigh = Color(0xFFE1E3E3);
const Color _surfaceContainerLow = Color(0xFFF0F1F1);
const Color _onSurface = Color(0xFF2D2F2F);
const Color _onSurfaceVariant = Color(0xFF5A5C5C);
const Color _tertiaryContainer = Color(0xFFFADD30);
const Color _onTertiaryContainer = Color(0xFF5B4E00);
const Color _pricePink = Color(0xFFFF2D78);

class ProductListingScreen extends StatefulWidget {
  const ProductListingScreen({super.key});

  @override
  State<ProductListingScreen> createState() => _ProductListingScreenState();
}

class _ProductListingScreenState extends State<ProductListingScreen> {
  int _selectedFilter = 0;
  final List<String> _filters = ['All', 'Price Low-High', 'New', 'Popular'];

  final _firestoreService = FirestoreService();
  List<ProductModel> _allProducts = [];
  Set<String> _wishlistIds = {};
  StreamSubscription<List<ProductModel>>? _productsSub;
  StreamSubscription<List<ProductModel>>? _wishlistSub;

  @override
  void initState() {
    super.initState();
    final userId = FirebaseAuth.instance.currentUser?.uid;
    _productsSub = _firestoreService.getProducts().listen((products) {
      if (mounted) setState(() => _allProducts = products);
    });
    if (userId != null) {
      _wishlistSub = _firestoreService.getWishlist(userId).listen((items) {
        if (mounted) {
          setState(() => _wishlistIds = items.map((p) => p.id).toSet());
        }
      });
    }
  }

  @override
  void dispose() {
    _productsSub?.cancel();
    _wishlistSub?.cancel();
    super.dispose();
  }

  List<ProductModel> get _filteredProducts {
    final args = ModalRoute.of(context)?.settings.arguments;
    List<ProductModel> products = _allProducts;
    if (args is String && args != 'All') {
      final filtered = _allProducts.where((p) => p.category == args).toList();
      if (filtered.isNotEmpty) products = filtered;
    }
    switch (_selectedFilter) {
      case 1:
        return [...products]..sort((a, b) => a.price.compareTo(b.price));
      case 2:
        return products.where((p) => p.isNew).toList();
      case 3:
        return [...products]..sort((a, b) => b.rating.compareTo(a.rating));
      default:
        return products;
    }
  }

  String get _title {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String) return args.toUpperCase();
    return 'SHOP';
  }

  @override
  Widget build(BuildContext context) {
    final products = _filteredProducts;
    return Scaffold(
      backgroundColor: _surface,
      appBar: _buildTopBar(context),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: products.isEmpty
                ? Center(
                    child: Text(
                      'No products found',
                      style: GoogleFonts.plusJakartaSans(
                          color: _onSurfaceVariant, fontSize: 14),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 40,
                      childAspectRatio: 0.58,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) =>
                        _buildProductCard(context, products[index]),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
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
                        _title,
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
                    onTap: () {},
                    child: const Icon(Icons.filter_list_rounded,
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

  Widget _buildFilterBar() {
    return SizedBox(
      height: 64,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: _filters.length,
        itemBuilder: (context, i) {
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
                  color: active ? const Color(0xFFFFEFF0) : _onSurfaceVariant,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, ProductModel product) {
    final isWishlisted = _wishlistIds.contains(product.id);
    final userId = FirebaseAuth.instance.currentUser?.uid;
    return GestureDetector(
      onTap: () =>
          Navigator.pushNamed(context, '/product-detail', arguments: product),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    color: _surfaceContainerLow,
                    child: product.imageUrl.isNotEmpty
                        ? Image.network(
                            product.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              color: _surfaceContainerLow,
                              child: const Icon(Icons.checkroom_rounded,
                                  size: 48, color: Color(0xFFACADAD)),
                            ),
                          )
                        : const Icon(Icons.checkroom_rounded,
                            size: 48, color: Color(0xFFACADAD)),
                  ),
                ),
                // Favorite button
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: () {
                      if (userId == null) return;
                      if (isWishlisted) {
                        _firestoreService.removeFromWishlist(userId, product.id);
                      } else {
                        _firestoreService.addToWishlist(userId, product);
                      }
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Icon(
                        isWishlisted
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        size: 18,
                        color: isWishlisted
                            ? _pricePink
                            : const Color(0xFFAAAAAA),
                      ),
                    ),
                  ),
                ),
                // New Drop badge
                if (product.isNew)
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _tertiaryContainer,
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Text(
                        'NEW DROP',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                          color: _onTertiaryContainer,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        size: 14, color: Color(0xFF695B00)),
                    const SizedBox(width: 3),
                    Text(
                      '${product.rating.toStringAsFixed(1)} (${product.reviewCount})',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: _onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: _pricePink,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    final items = [
      {'icon': Icons.home_rounded, 'label': 'Home', 'active': false},
      {'icon': Icons.grid_view_rounded, 'label': 'Shop', 'active': true},
      {'icon': Icons.favorite_border_rounded, 'label': 'Wishlist', 'active': false},
      {'icon': Icons.shopping_cart_outlined, 'label': 'Cart', 'active': false},
      {'icon': Icons.person_outline_rounded, 'label': 'Profile', 'active': false},
    ];
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 30,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.map((item) {
              final isActive = item['active'] as bool;
              return GestureDetector(
                onTap: () {},
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(item['icon'] as IconData,
                        color: isActive ? _primary : const Color(0xFFAAAAAA),
                        size: 24),
                    const SizedBox(height: 4),
                    Text(
                      item['label'] as String,
                      style: GoogleFonts.epilogue(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: isActive ? _primary : const Color(0xFFAAAAAA),
                      ),
                    ),
                    if (isActive) ...[
                      const SizedBox(height: 2),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                            color: _primary, shape: BoxShape.circle),
                      ),
                    ],
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
