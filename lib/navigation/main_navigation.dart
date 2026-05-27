import 'dart:async';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shining/screens/home/home_screen.dart';
import 'package:shining/screens/product/product_listing_screen.dart';
import 'package:shining/screens/wishlist/wishlist_screen.dart';
import 'package:shining/screens/cart/cart_screen.dart';
import 'package:shining/screens/profile/profile_screen.dart';
import 'package:shining/services/firestore_service.dart';
import 'package:shining/utils/constants.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  int _cartCount = 0;
  StreamSubscription? _cartSub;

  final List<Widget> _screens = [
    const HomeScreen(),
    const ProductListingScreen(),
    const WishlistScreen(),
    const CartScreen(),
    const ProfileScreen(),
  ];

  final List<String> _titles = [
    'Home',
    'Shop',
    'Wishlist',
    'Cart',
    'Profile',
  ];

  @override
  void initState() {
    super.initState();
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      _cartSub = FirestoreService().getCartItems(userId).listen((items) {
        if (mounted) setState(() => _cartCount = items.length);
      });
    }
  }

  @override
  void dispose() {
    _cartSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: kSurface,
        selectedItemColor: kPrimary,
        unselectedItemColor: kTextSecondary,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            activeIcon: Icon(Icons.shopping_bag),
            label: 'Shop',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline),
            activeIcon: Icon(Icons.favorite),
            label: 'Wishlist',
          ),
          BottomNavigationBarItem(
            icon: badges.Badge(
              badgeContent: Text(
                '$_cartCount',
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
              badgeStyle: const badges.BadgeStyle(
                badgeColor: kError,
              ),
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            activeIcon: badges.Badge(
              badgeContent: Text(
                '$_cartCount',
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
              badgeStyle: const badges.BadgeStyle(
                badgeColor: kError,
              ),
              child: const Icon(Icons.shopping_cart),
            ),
            label: 'Cart',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
