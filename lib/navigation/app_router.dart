import 'package:flutter/material.dart';
import 'package:shining/screens/splash/splash_screen.dart';
import 'package:shining/screens/auth/login_screen.dart';
import 'package:shining/screens/auth/register_screen.dart';
import 'package:shining/screens/product/product_detail_screen.dart';
import 'package:shining/screens/product/product_listing_screen.dart';
import 'package:shining/screens/cart/cart_screen.dart';
import 'package:shining/screens/wishlist/wishlist_screen.dart';
import 'package:shining/screens/checkout/checkout_screen.dart';
import 'package:shining/screens/orders/order_history_screen.dart';
import 'package:shining/navigation/main_navigation.dart';
import 'package:shining/models/product_model.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      
      case '/register':
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      
      case '/main':
        return MaterialPageRoute(builder: (_) => const MainNavigation());
      
      case '/product-detail':
        final product = settings.arguments as ProductModel;
        return MaterialPageRoute(
          builder: (_) => ProductDetailScreen(product: product),
        );
      
      case '/cart':
        return MaterialPageRoute(builder: (_) => const CartScreen());

      case '/wishlist':
        return MaterialPageRoute(builder: (_) => const WishlistScreen());

      case '/shop':
        final args = settings.arguments;
        return MaterialPageRoute(
          builder: (_) => const ProductListingScreen(),
          settings: RouteSettings(name: '/shop', arguments: args),
        );

      case '/checkout':
        return MaterialPageRoute(builder: (_) => const CheckoutScreen());

      case '/order-history':
        return MaterialPageRoute(builder: (_) => const OrderHistoryScreen());
      
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Page Not Found')),
            body: const Center(
              child: Text('No route defined for that path'),
            ),
          ),
        );
    }
  }
}
