import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shining/services/auth_service.dart';

const Color _primary = Color(0xFFB6004F);
const Color _secondary = Color(0xFF7738C0);
const Color _surface = Color(0xFFF6F6F6);
const Color _surfaceContainerHighest = Color(0xFFDBDDDD);
const Color _surfaceContainerLowest = Color(0xFFFFFFFF);
const Color _onSurface = Color(0xFF2D2F2F);
const Color _onSurfaceVariant = Color(0xFF5A5C5C);
const Color _outline = Color(0xFF767777);
const Color _outlineVariant = Color(0xFFACADAD);
const Color _tertiaryContainer = Color(0xFFFADD30);

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  final _authService = AuthService();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please fill in all fields'),
        backgroundColor: _primary,
      ));
      return;
    }
    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Passwords do not match'),
        backgroundColor: _primary,
      ));
      return;
    }
    setState(() => _isLoading = true);
    final error = await _authService.signUpWithEmail(email, password, name);
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error),
        backgroundColor: _primary,
      ));
    } else {
      FocusScope.of(context).unfocus();
      Navigator.pushReplacementNamed(context, '/main');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      appBar: _buildTopBar(context),
      body: Stack(
        children: [
          // Bottom-right yellow blur
          Positioned(
            bottom: 80,
            right: -80,
            child: Container(
              width: 256,
              height: 256,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _tertiaryContainer.withValues(alpha: 0.15),
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _buildHero(),
                const SizedBox(height: 40),
                _buildForm(),
                const SizedBox(height: 40),
                _buildDivider(),
                const SizedBox(height: 28),
                _buildSocialGrid(),
                const SizedBox(height: 40),
                _buildFooter(context),
                const SizedBox(height: 24),
                _buildTerms(),
              ],
            ),
          ),
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
                  const SizedBox(width: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHero() {
    return Center(
      child: Column(
        children: [
          Transform.rotate(
            angle: 3 * 3.14159 / 180,
            child: Container(
              width: 96,
              height: 96,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_primary, _secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: _primary.withValues(alpha: 0.3),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [_primary, _secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    size: 44,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Create Account ✨',
            style: GoogleFonts.epilogue(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
              color: _onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Join our curated fashion community',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: _onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        _formField(
          label: 'Full Name',
          controller: _nameController,
          hint: 'Alex Rivera',
          prefixIcon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: 20),
        _formField(
          label: 'Email Address',
          controller: _emailController,
          hint: 'alex@shining.store',
          prefixIcon: Icons.mail_outline_rounded,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 20),
        _passwordFormField(
          label: 'Password',
          controller: _passwordController,
          hint: '••••••••',
          prefixIcon: Icons.lock_outline_rounded,
          obscure: _obscurePassword,
          onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
        const SizedBox(height: 20),
        _passwordFormField(
          label: 'Confirm Password',
          controller: _confirmPasswordController,
          hint: '••••••••',
          prefixIcon: Icons.shield_outlined,
          obscure: _obscureConfirm,
          onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
          showToggle: false,
        ),
        const SizedBox(height: 32),
        // Register button
        GestureDetector(
          onTap: _isLoading ? null : _handleRegister,
          child: Container(
            width: double.infinity,
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
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'Register',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        color: const Color(0xFFFFEFF0),
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _formField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            label.toUpperCase(),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: _onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: GoogleFonts.plusJakartaSans(
              fontSize: 15, fontWeight: FontWeight.w500, color: _onSurface),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.plusJakartaSans(
                fontSize: 15, color: _outlineVariant),
            prefixIcon: Icon(prefixIcon, color: _outline, size: 22),
            filled: true,
            fillColor: _surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                  color: _primary.withValues(alpha: 0.25), width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          ),
        ),
      ],
    );
  }

  Widget _passwordFormField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData prefixIcon,
    required bool obscure,
    required VoidCallback onToggle,
    bool showToggle = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            label.toUpperCase(),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: _onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          style: GoogleFonts.plusJakartaSans(
              fontSize: 15, fontWeight: FontWeight.w500, color: _onSurface),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.plusJakartaSans(
                fontSize: 15, color: _outlineVariant),
            prefixIcon: Icon(prefixIcon, color: _outline, size: 22),
            suffixIcon: showToggle
                ? GestureDetector(
                    onTap: onToggle,
                    child: Icon(
                      obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: _outline,
                      size: 22,
                    ),
                  )
                : null,
            filled: true,
            fillColor: _surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                  color: _primary.withValues(alpha: 0.25), width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(height: 1, color: _surfaceContainerHighest),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'OR SIGN UP WITH',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              color: _outline,
            ),
          ),
        ),
        Expanded(
          child: Container(height: 1, color: _surfaceContainerHighest),
        ),
      ],
    );
  }

  Widget _buildSocialGrid() {
    return Row(
      children: [
        Expanded(child: _socialBtn(Icons.g_mobiledata_rounded, 'Google')),
        const SizedBox(width: 16),
        Expanded(child: _socialBtn(Icons.apple_rounded, 'Apple')),
      ],
    );
  }

  Widget _socialBtn(IconData icon, String label) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$label Sign-In — coming soon!'),
            backgroundColor: _primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: _surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: _outlineVariant.withValues(alpha: 0.15), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: _onSurface),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: _onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: RichText(
          text: TextSpan(
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: _onSurfaceVariant,
            ),
            children: [
              const TextSpan(text: 'Already have an account? '),
              TextSpan(
                text: 'Login',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: _primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTerms() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        'By registering, you agree to our Terms of Service and Privacy Policy.',
        textAlign: TextAlign.center,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          color: _outline,
          height: 1.6,
        ),
      ),
    );
  }
}
