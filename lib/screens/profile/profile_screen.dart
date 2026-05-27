import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shining/models/user_model.dart';
import 'package:shining/services/auth_service.dart';
import 'package:shining/services/firestore_service.dart';

const Color _primary = Color(0xFFB6004F);
const Color _secondary = Color(0xFF7738C0);
const Color _surface = Color(0xFFF6F6F6);
const Color _surfaceContainerLowest = Color(0xFFFFFFFF);
const Color _surfaceContainerLow = Color(0xFFF0F1F1);
const Color _surfaceContainer = Color(0xFFE7E8E8);
const Color _onSurface = Color(0xFF2D2F2F);
const Color _onSurfaceVariant = Color(0xFF5A5C5C);
const Color _outline = Color(0xFF767777);
const Color _tertiaryContainer = Color(0xFFFADD30);
const Color _onTertiaryContainer = Color(0xFF5B4E00);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _firestoreService = FirestoreService();
  final _authService = AuthService();
  UserModel? _user;
  int _orderCount = 0;
  StreamSubscription<UserModel?>? _profileSub;
  StreamSubscription? _ordersSub;

  @override
  void initState() {
    super.initState();
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      _profileSub = _firestoreService.getUserProfile(userId).listen((user) {
        if (mounted) setState(() => _user = user);
      });
      _ordersSub = _firestoreService.getUserOrders(userId).listen((orders) {
        if (mounted) setState(() => _orderCount = orders.length);
      });
    }
  }

  @override
  void dispose() {
    _profileSub?.cancel();
    _ordersSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final name = _user?.fullName ?? FirebaseAuth.instance.currentUser?.email ?? 'User';
    final email = _user?.email ?? FirebaseAuth.instance.currentUser?.email ?? '';
    final avatarUrl = _user?.avatarUrl ?? '';
    return Scaffold(
      backgroundColor: _surface,
      appBar: _buildTopBar(context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHero(avatarUrl, name, email),
            _buildMenuCard(context),
            const SizedBox(height: 24),
            _buildStatsGrid(),
            const SizedBox(height: 48),
          ],
        ),
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

  Widget _buildHero(String avatarUrl, String name, String email) {
    return Container(
      height: 288,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_primary, Color(0xFFA00044), _secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Decorative yellow blur
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _tertiaryContainer.withValues(alpha: 0.15),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 56,
                      backgroundImage: avatarUrl.isNotEmpty
                          ? NetworkImage(avatarUrl)
                          : null,
                      backgroundColor: _primary,
                      child: avatarUrl.isEmpty
                          ? const Icon(Icons.person, size: 48, color: Colors.white)
                          : null,
                    ),
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: _tertiaryContainer,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.edit_rounded,
                            size: 14, color: _onTertiaryContainer),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  name.toUpperCase(),
                  style: GoogleFonts.epilogue(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 0.3,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -32),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: _surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            _menuItem(
              icon: Icons.person_outline_rounded,
              label: 'Edit Profile',
              iconBg: _primary.withValues(alpha: 0.1),
              iconColor: _primary,
              onTap: () {},
            ),
            _menuItem(
              icon: Icons.inventory_2_outlined,
              label: 'My Orders',
              iconBg: _secondary.withValues(alpha: 0.1),
              iconColor: _secondary,
              badge: '$_orderCount',
              onTap: () => Navigator.pushNamed(context, '/order-history'),
            ),
            _menuItem(
              icon: Icons.favorite_rounded,
              label: 'My Wishlist',
              iconBg: const Color(0xFFFFF0F5),
              iconColor: const Color(0xFFFF4081),
              onTap: () => Navigator.pushNamed(context, '/wishlist'),
            ),
            _menuItem(
              icon: Icons.notifications_outlined,
              label: 'Notifications',
              iconBg: _surfaceContainer,
              iconColor: _onSurfaceVariant,
              onTap: () {},
            ),
            _menuItem(
              icon: Icons.lock_outline_rounded,
              label: 'Change Password',
              iconBg: _surfaceContainer,
              iconColor: _onSurfaceVariant,
              onTap: () {},
            ),
            _menuItem(
              icon: Icons.info_outline_rounded,
              label: 'About Us',
              iconBg: _surfaceContainer,
              iconColor: _onSurfaceVariant,
              onTap: () {},
            ),
            const SizedBox(height: 4),
            _menuItem(
              icon: Icons.logout_rounded,
              label: 'Logout',
              iconBg: const Color(0xFFFFEEF4),
              iconColor: _primary,
              labelColor: _primary,
              onTap: () async {
                await _authService.signOut();
                if (!context.mounted) return;
                Navigator.pushReplacementNamed(context, '/login');
              },
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String label,
    required Color iconBg,
    required Color iconColor,
    Color? labelColor,
    String? badge,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: isLast ? FontWeight.w700 : FontWeight.w600,
                  color: labelColor ?? _onSurface,
                ),
              ),
            ),
            if (badge != null) ...[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _primary,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  badge,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Icon(Icons.chevron_right_rounded,
                size: 20, color: isLast ? _primary : _outline),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 128,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -12,
                    bottom: -12,
                    child: Icon(Icons.payments_outlined,
                        size: 72,
                        color: _primary.withValues(alpha: 0.08)),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'WALLET\nBALANCE',
                        style: GoogleFonts.epilogue(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                          color: _onSurfaceVariant,
                          height: 1.3,
                        ),
                      ),
                      Text(
                        '\$1,240.50',
                        style: GoogleFonts.epilogue(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: _primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              height: 128,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _tertiaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -12,
                    bottom: -12,
                    child: Icon(Icons.loyalty_rounded,
                        size: 72,
                        color: _onTertiaryContainer.withValues(alpha: 0.08)),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'LOYALTY\nPOINTS',
                        style: GoogleFonts.epilogue(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                          color: _onTertiaryContainer,
                          height: 1.3,
                        ),
                      ),
                      Text(
                        '4,820 pts',
                        style: GoogleFonts.epilogue(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: _onTertiaryContainer,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    final items = [
      {'icon': Icons.home_rounded, 'label': 'Home', 'active': false},
      {'icon': Icons.grid_view_rounded, 'label': 'Shop', 'active': false},
      {'icon': Icons.favorite_border_rounded, 'label': 'Wishlist', 'active': false},
      {'icon': Icons.shopping_cart_outlined, 'label': 'Cart', 'active': false},
      {'icon': Icons.person_rounded, 'label': 'Profile', 'active': true},
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
              return Column(
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
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
