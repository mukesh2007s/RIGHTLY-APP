import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_typography.dart';
import '../../widgets/buttons/gradient_button.dart';
import '../../widgets/common/glass_container.dart';

/// Login Screen — Premium justice-themed authentication
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  late AnimationController _bgController;
  late AnimationController _cardController;
  late Animation<double> _cardSlide;
  late Animation<double> _cardOpacity;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..forward();

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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    await Future.delayed(const Duration(milliseconds: 500));

    setState(() => _isLoading = false);
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (r) => false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    await Future.delayed(const Duration(milliseconds: 500));

    setState(() => _isLoading = false);
    if (mounted) {
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
                  child: Opacity(
                    opacity: _cardOpacity.value,
                    child: child,
                  ),
                );
              },
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  // Logo
                  _buildLogo(),
                  const SizedBox(height: 40),
                  // Login Card
                  _buildLoginCard(),
                  const SizedBox(height: 24),
                  // Social Sign In
                  _buildSocialSignIn(),
                  const SizedBox(height: 24),
                  // Register link
                  _buildRegisterLink(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.legalGold, AppColors.legalGold.withOpacity(0.7)],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.legalGold.withOpacity(0.4),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(Icons.balance, size: 40, color: Colors.white),
        ),
        const SizedBox(height: 16),
        Text(
          'Welcome Back',
          style: AppTypography.displaySmall.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sign in to continue your legal journey',
          style: AppTypography.bodyMedium.copyWith(
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard() {
    return GlassmorphicContainer(
      borderRadius: 24,
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Email Address',
              style: AppTypography.labelMedium.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Enter your email',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                prefixIcon: Icon(Icons.email_outlined, color: AppColors.legalGold),
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
              validator: (value) {
                if (value == null || value.isEmpty) return 'Email is required';
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return 'Enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            Text(
              'Password',
              style: AppTypography.labelMedium.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Enter your password',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                prefixIcon: Icon(Icons.lock_outline, color: AppColors.legalGold),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.white54,
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
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
              validator: (value) {
                if (value == null || value.isEmpty) return 'Password is required';
                if (value.length < 6) return 'Password must be at least 6 characters';
                return null;
              },
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.pushNamed(context, '/forgot-password'),
                child: Text(
                  'Forgot Password?',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.legalGold,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: GradientButton(
                text: 'Sign In',
                onPressed: _handleLogin,
                borderRadius: 16,
                isLoading: _isLoading,
                icon: Icons.login,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialSignIn() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: Colors.white.withOpacity(0.3))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'OR',
                style: AppTypography.labelMedium.copyWith(color: Colors.white54),
              ),
            ),
            Expanded(child: Divider(color: Colors.white.withOpacity(0.3))),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton.icon(
            onPressed: _isLoading ? null : _handleGoogleSignIn,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.white.withOpacity(0.3)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  'G',
                  style: TextStyle(
                    color: Color(0xFF4285F4),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            label: Text(
              'Continue with Google',
              style: AppTypography.labelLarge.copyWith(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: AppTypography.bodyMedium.copyWith(color: Colors.white60),
        ),
        TextButton(
          onPressed: () => Navigator.pushNamed(context, '/register'),
          child: Text(
            'Register',
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
