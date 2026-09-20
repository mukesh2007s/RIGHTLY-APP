import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_typography.dart';
import '../../widgets/buttons/gradient_button.dart';
import '../../widgets/common/glass_container.dart';

/// Register Screen — New user registration with premium UI
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  late AnimationController _bgController;
  late AnimationController _cardController;
  late Animation<double> _cardSlide;
  late Animation<double> _cardOpacity;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptedTerms = false;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);

    _cardController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _cardSlide = Tween<double>(begin: 50, end: 0).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.easeOutCubic),
    );

    _cardOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _cardController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _cardController.forward();
  }

  @override
  void dispose() {
    _bgController.dispose();
    _cardController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please accept the Terms & Conditions'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isLoading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Account created successfully!'),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (r) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _bgController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary.withOpacity(0.95),
                  const Color(0xFF0D47A1),
                  AppColors.primary,
                ],
                stops: [
                  0.0,
                  0.5 + (_bgController.value * 0.2),
                  1.0,
                ],
              ),
            ),
            child: child,
          );
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: AnimatedBuilder(
              animation: _cardController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _cardSlide.value),
                  child: Opacity(opacity: _cardOpacity.value, child: child),
                );
              },
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  // Back + Title
                  _buildHeader(),
                  const SizedBox(height: 24),
                  // Register Form
                  _buildRegisterCard(),
                  const SizedBox(height: 24),
                  // Login Link
                  _buildLoginLink(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create Account',
              style: AppTypography.headlineMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Join the legal awareness revolution',
              style: AppTypography.bodySmall.copyWith(color: Colors.white60),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRegisterCard() {
    return GlassmorphicContainer(
      borderRadius: 24,
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFieldLabel('Full Name'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _nameController,
              hint: 'Enter your full name',
              icon: Icons.person_outline,
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Name is required' : null,
            ),
            const SizedBox(height: 16),
            _buildFieldLabel('Email Address'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _emailController,
              hint: 'Enter your email',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Email is required';
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) {
                  return 'Enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildFieldLabel('Phone Number'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _phoneController,
              hint: '+91 XXXXX XXXXX',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Phone number is required';
                if (v.replaceAll(RegExp(r'[^0-9]'), '').length < 10) {
                  return 'Enter a valid phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildFieldLabel('Password'),
            const SizedBox(height: 8),
            _buildPasswordField(
              controller: _passwordController,
              hint: 'Create a strong password',
              obscure: _obscurePassword,
              onToggle: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Password is required';
                if (v.length < 6) return 'Minimum 6 characters';
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildFieldLabel('Confirm Password'),
            const SizedBox(height: 8),
            _buildPasswordField(
              controller: _confirmPasswordController,
              hint: 'Confirm your password',
              obscure: _obscureConfirmPassword,
              onToggle: () => setState(
                  () => _obscureConfirmPassword = !_obscureConfirmPassword),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Confirm your password';
                if (v != _passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Terms checkbox
            Row(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: _acceptedTerms,
                    onChanged: (v) =>
                        setState(() => _acceptedTerms = v ?? false),
                    activeColor: AppColors.legalGold,
                    checkColor: Colors.white,
                    side: BorderSide(color: Colors.white.withOpacity(0.5)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'I agree to the Terms of Service & Privacy Policy',
                    style: AppTypography.bodySmall.copyWith(
                      color: Colors.white60,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: GradientButton(
                text: 'Create Account',
                onPressed: _handleRegister,
                borderRadius: 16,
                isLoading: _isLoading,
                icon: Icons.person_add,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: AppTypography.labelMedium.copyWith(color: Colors.white70),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
        prefixIcon: Icon(icon, color: AppColors.legalGold),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.legalGold, width: 1.5),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
        prefixIcon: Icon(Icons.lock_outline, color: AppColors.legalGold),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off : Icons.visibility,
            color: Colors.white54,
          ),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.legalGold, width: 1.5),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account? ',
          style: AppTypography.bodyMedium.copyWith(color: Colors.white60),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Sign In',
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.legalGold,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
