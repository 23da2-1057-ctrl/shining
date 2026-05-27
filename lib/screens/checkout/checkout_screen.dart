import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shining/models/cart_item_model.dart';
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
const Color _outlineVariant = Color(0xFFACADAD);

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalController = TextEditingController();
  int _selectedPayment = 1; // 0=COD, 1=Card, 2=Wallet

  final _firestoreService = FirestoreService();
  List<CartItemModel> _cartItems = [];
  StreamSubscription<List<CartItemModel>>? _cartSub;

  @override
  void initState() {
    super.initState();
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      _cartSub = _firestoreService.getCartItems(userId).listen((items) {
        if (mounted) setState(() => _cartItems = items);
      });
    }
  }

  @override
  void dispose() {
    _cartSub?.cancel();
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _postalController.dispose();
    super.dispose();
  }

  double get _cartTotal =>
      _cartItems.fold(0, (sum, i) => sum + i.product.price * i.quantity);

  Future<void> _placeOrder() async {
    if (_addressController.text.isEmpty || _cityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in your delivery details'),
          backgroundColor: _primary,
        ),
      );
      return;
    }
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;
    final address =
        '${_addressController.text}, ${_cityController.text} ${_postalController.text}';
    final order =
        await _firestoreService.placeOrder(userId, _cartItems, address);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/order-history');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Order #${order.orderId.substring(0, 8)} placed!'),
        backgroundColor: _primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      appBar: _buildTopBar(context),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('Delivery Details', _primary),
                const SizedBox(height: 16),
                _buildDeliveryCard(),
                const SizedBox(height: 28),
                _buildSectionHeader('Order Summary', _secondary),
                const SizedBox(height: 16),
                _buildOrderSummary(),
                const SizedBox(height: 28),
                _buildSectionHeader('Payment Method', _tertiary),
                const SizedBox(height: 16),
                _buildPaymentMethods(),
              ],
            ),
          ),
          _buildPlaceOrderButton(),
        ],
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
                        'Checkout',
                        style: GoogleFonts.epilogue(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                          color: const Color(0xFF1A1A1A),
                        ),
                      ),
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

  Widget _buildSectionHeader(String title, Color accentColor) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 24,
          decoration: BoxDecoration(
            color: accentColor,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
            color: _onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF2D78).withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _deliveryField('Full Name', 'Cameron Williamson',
              TextInputType.name, _nameController),
          const SizedBox(height: 16),
          _deliveryField('Phone Number', '+1 (555) 000-0000',
              TextInputType.phone, _phoneController),
          const SizedBox(height: 16),
          _deliveryField('Address', '8502 Preston Rd. Inglewood',
              TextInputType.streetAddress, _addressController),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _deliveryField(
                    'City', 'Maine', TextInputType.text, _cityController),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _deliveryField('Postal Code', '98380',
                    TextInputType.number, _postalController),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _deliveryField(String label, String hint,
      TextInputType type, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            label.toUpperCase(),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: _onSurfaceVariant,
            ),
          ),
        ),
        TextField(
          controller: controller,
          keyboardType: type,
          style: GoogleFonts.plusJakartaSans(
              fontSize: 14, color: _onSurface),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: _outlineVariant.withValues(alpha: 0.6)),
            filled: true,
            fillColor: _surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                  color: _primary.withValues(alpha: 0.25), width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderSummary() {
    final items = _cartItems;
    final total = _cartTotal;
    return Container(
      decoration: BoxDecoration(
        color: _surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: items.isEmpty
                  ? [
                      Text('No items in cart',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 14, color: _onSurfaceVariant))
                    ]
                  : items.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                width: 56,
                                height: 56,
                                color: _surfaceContainerHigh,
                                child: item.product.imageUrl.isNotEmpty
                                    ? Image.network(
                                        item.product.imageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, _, _) =>
                                            const Icon(
                                          Icons.checkroom_rounded,
                                          size: 24,
                                          color: _outlineVariant,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.checkroom_rounded,
                                        size: 24,
                                        color: _outlineVariant,
                                      ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: _onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Size: ${item.selectedSize} • Qty: ${item.quantity}',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      color: _onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '\$${(item.product.price * item.quantity).toStringAsFixed(2)}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: _primary,
                              ),
                            ),
                          ],
                        ),
                      )).toList(),
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: _surfaceContainerHigh,
              borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'TOTAL AMOUNT',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: _onSurfaceVariant,
                  ),
                ),
                Text(
                  '\$${total.toStringAsFixed(2)}',
                  style: GoogleFonts.epilogue(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: _primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods() {
    final methods = [
      {
        'icon': Icons.payments_outlined,
        'title': 'Cash on Delivery',
        'subtitle': 'Pay when you receive',
      },
      {
        'icon': Icons.credit_card_rounded,
        'title': 'Credit / Debit Card',
        'subtitle': 'Visa, Mastercard, etc.',
      },
      {
        'icon': Icons.account_balance_wallet_outlined,
        'title': 'Wallet',
        'subtitle': 'Balance: \$1,240.50',
      },
    ];

    return Column(
      children: List.generate(methods.length, (i) {
        final isSelected = i == _selectedPayment;
        return GestureDetector(
          onTap: () => setState(() => _selectedPayment = i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _surfaceContainerLowest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? _primary.withValues(alpha: 0.25)
                    : Colors.transparent,
                width: 2,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: _primary.withValues(alpha: 0.06),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _surfaceContainerHigh,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(methods[i]['icon'] as IconData,
                      color: _onSurfaceVariant, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        methods[i]['title'] as String,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _onSurface,
                        ),
                      ),
                      Text(
                        methods[i]['subtitle'] as String,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: _onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? _primary : _outlineVariant,
                      width: 2,
                    ),
                    color: isSelected ? _primary : Colors.transparent,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check_rounded,
                          size: 13, color: Colors.white)
                      : null,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildPlaceOrderButton() {
    return Positioned(
      bottom: 24,
      left: 24,
      right: 24,
      child: GestureDetector(
        onTap: _placeOrder,
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
                color: _primary.withValues(alpha: 0.28),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: Text(
              'PLACE ORDER',
              style: GoogleFonts.epilogue(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
