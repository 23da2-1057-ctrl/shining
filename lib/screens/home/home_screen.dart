import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shining/models/product_model.dart';
import 'package:shining/models/user_model.dart';
import 'package:shining/services/firestore_service.dart';

const Color _primary = Color(0xFFB6004F);
const Color _secondary = Color(0xFF7738C0);
const Color _surface = Color(0xFFF6F6F6);
const Color _surfaceContainerHighest = Color(0xFFDBDDDD);
const Color _surfaceContainerLowest = Color(0xFFFFFFFF);
const Color _surfaceContainerLow = Color(0xFFF0F1F1);
const Color _onSurface = Color(0xFF2D2F2F);
const Color _onSurfaceVariant = Color(0xFF5A5C5C);
const Color _outlineVariant = Color(0xFFACADAD);
const Color _tertiaryContainer = Color(0xFFFADD30);
const Color _onTertiaryContainer = Color(0xFF5B4E00);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedCategory = 0;
  final List<Map<String, dynamic>> _categories = [
    {'label': 'All', 'icon': Icons.grid_view_rounded},
    {'label': 'Dresses', 'icon': Icons.checkroom_rounded},
    {'label': 'Tops', 'icon': Icons.style_rounded},
    {'label': 'Bags', 'icon': Icons.shopping_bag_rounded},
  ];

  final _firestoreService = FirestoreService();
  List<ProductModel> _products = [];
  Set<String> _wishlistIds = {};
  UserModel? _userProfile;
  StreamSubscription<List<ProductModel>>? _productsSub;
  StreamSubscription<List<ProductModel>>? _wishlistSub;
  StreamSubscription<UserModel?>? _profileSub;

  @override
  void initState() {
    super.initState();
    final userId = FirebaseAuth.instance.currentUser?.uid;
    _productsSub = _firestoreService.getProducts().listen((products) {
      if (mounted) setState(() => _products = products);
    });
    if (userId != null) {
      _wishlistSub = _firestoreService.getWishlist(userId).listen((items) {
        if (mounted) {
          setState(() => _wishlistIds = items.map((p) => p.id).toSet());
        }
      });
      _profileSub = _firestoreService.getUserProfile(userId).listen((user) {
        if (mounted) setState(() => _userProfile = user);
      });
    }
  }

  @override
  void dispose() {
    _productsSub?.cancel();
    _wishlistSub?.cancel();
    _profileSub?.cancel();
    super.dispose();
  }

  List<ProductModel> get _filteredProducts {
    if (_selectedCategory == 0) return _products.take(4).toList();
    final cat = _categories[_selectedCategory]['label'] as String;
    final filtered = _products.where((p) => p.category == cat).toList();
    return filtered.isEmpty ? _products.take(4).toList() : filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      extendBodyBehindAppBar: true,
      appBar: _buildTopBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 80, bottom: 100, left: 24, right: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            _buildSearchBar(),
            const SizedBox(height: 32),
            _buildBanner(),
            const SizedBox(height: 40),
            _buildCategoriesSection(),
            const SizedBox(height: 40),
            _buildTrendingSection(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  PreferredSizeWidget _buildTopBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(64),
      child: ClipRect(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.85),
            boxShadow: [
              BoxShadow(
                color: _primary.withValues(alpha: 0.05),
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'SHINING STORE',
                      style: GoogleFonts.epilogue(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.5,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {},
                          child: const Icon(
                            Icons.notifications_outlined,
                            color: _onSurface,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        CircleAvatar(
                          radius: 16,
                          backgroundImage: (_userProfile?.avatarUrl.isNotEmpty ?? false)
                              ? NetworkImage(_userProfile!.avatarUrl)
                              : null,
                          backgroundColor: _primary.withValues(alpha: 0.15),
                          child: (_userProfile?.avatarUrl.isNotEmpty ?? false)
                              ? null
                              : const Icon(Icons.person, size: 16, color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
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
        style: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          color: _onSurface,
        ),
        decoration: InputDecoration(
          hintText: 'Find your shine...',
          hintStyle: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: _onSurfaceVariant,
          ),
          prefixIcon: const Icon(Icons.search_rounded, color: _primary),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: _primary.withValues(alpha: 0.3), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildBanner() {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFB6004F), Color(0xFF7738C0)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Icon(Icons.checkroom_rounded,
                      size: 80, color: Colors.white24),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          _primary.withValues(alpha: 0.85),
                        ],
                        stops: const [0.3, 1.0],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 24,
                  left: 24,
                  right: 24,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'New Arrivals 🔥',
                        style: GoogleFonts.epilogue(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -0.5,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Elevate your style game today.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _dot(active: true),
            const SizedBox(width: 6),
            _dot(active: false),
            const SizedBox(width: 6),
            _dot(active: false),
          ],
        ),
      ],
    );
  }

  Widget _dot({required bool active}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: active ? 24 : 6,
      height: 6,
      decoration: BoxDecoration(
        color: active ? _primary : _surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Categories',
              style: GoogleFonts.epilogue(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.3,
                color: _onSurface,
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: Text(
                'View All',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: _primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(_categories.length, (i) {
              final isActive = i == _selectedCategory;
              return Padding(
                padding: EdgeInsets.only(right: i < _categories.length - 1 ? 12 : 0),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedCategory = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: isActive
                          ? const LinearGradient(
                              colors: [_primary, _secondary],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            )
                          : null,
                      color: isActive ? null : _surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: _primary.withValues(alpha: 0.25),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _categories[i]['icon'] as IconData,
                          size: 16,
                          color: isActive ? Colors.white : _onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _categories[i]['label'] as String,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: isActive ? Colors.white : _onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildTrendingSection() {
    final products = _filteredProducts;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Trending Now',
              style: GoogleFonts.epilogue(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.3,
                color: _onSurface,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: _tertiaryContainer,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'HOT DROPS',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: _onTertiaryContainer,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 32,
            childAspectRatio: 0.62,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) => _buildProductCard(products[index]),
        ),
      ],
    );
  }

  Widget _buildProductCard(ProductModel product) {
    final isWishlisted = _wishlistIds.contains(product.id);
    final userId = FirebaseAuth.instance.currentUser?.uid;
    return Column(
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
                                size: 48, color: _outlineVariant),
                          ),
                        )
                      : const Icon(Icons.checkroom_rounded,
                          size: 48, color: _outlineVariant),
                ),
              ),
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
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Icon(
                      isWishlisted ? Icons.favorite : Icons.favorite_border,
                      size: 16,
                      color: isWishlisted ? _primary : _onSurfaceVariant,
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
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: _primary,
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  final uid = FirebaseAuth.instance.currentUser?.uid;
                  if (uid == null) return;
                  _firestoreService.addToCart(
                    uid,
                    product,
                    product.sizes.isNotEmpty ? product.sizes.first : '',
                    product.colors.isNotEmpty ? product.colors.first : '',
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${product.name} added to cart'),
                      duration: const Duration(seconds: 1),
                      backgroundColor: _primary,
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: _surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _outlineVariant.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'ADD TO CART',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: _onSurface,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    final items = [
      {'icon': Icons.home_rounded, 'label': 'Home', 'active': true},
      {'icon': Icons.grid_view_rounded, 'label': 'Shop', 'active': false},
      {'icon': Icons.favorite_border_rounded, 'label': 'Wishlist', 'active': false},
      {'icon': Icons.shopping_cart_outlined, 'label': 'Cart', 'active': false},
      {'icon': Icons.person_outline_rounded, 'label': 'Profile', 'active': false},
    ];
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
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
                    Icon(
                      item['icon'] as IconData,
                      color: isActive ? _primary : const Color(0xFFAAAAAA),
                      size: 24,
                    ),
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
                          color: _primary,
                          shape: BoxShape.circle,
                        ),
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
