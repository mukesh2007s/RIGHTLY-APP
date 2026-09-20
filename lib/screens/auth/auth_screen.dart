import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_typography.dart';
import '../../widgets/buttons/gradient_button.dart';
import '../../widgets/common/glass_container.dart';
import '../../services/database_service.dart';

/// Premium Authentication Screen
class AuthScreen extends StatefulWidget {
  final VoidCallback? onAuthSuccess;
  final VoidCallback? onSkip;

  const AuthScreen({
    super.key,
    this.onAuthSuccess,
    this.onSkip,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with TickerProviderStateMixin {
  late AnimationController _bgController;
  late AnimationController _cardController;
  late Animation<double> _cardSlide;
  late Animation<double> _cardOpacity;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;

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
      CurvedAnimation(
        parent: _cardController,
        curve: Curves.easeOutCubic,
      ),
    );

    _cardOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _cardController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _cardController.forward();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  void dispose() {
    _bgController.dispose();
    _cardController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailAuth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    // Simulate auth delay
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isLoading = false);
    _navigateAfterAuth();
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    // Simulate auth delay
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isLoading = false);
    _navigateAfterAuth();
  }

  void _navigateAfterAuth() async {
    // Save login state so user doesn't need to login again
    await DatabaseService().setPreference('is_logged_in', 'true');
    
    if (widget.onAuthSuccess != null) {
      widget.onAuthSuccess!();
    } else if (mounted) {
      Navigator.of(context).pushReplacementNamed('/dashboard');
    }
  }

  void _toggleAuthMode() {
    setState(() {
      _isLogin = !_isLogin;
    });
    HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Animated Gradient Background
          _buildAnimatedBackground(),

          // Floating Decoration
          _buildFloatingDecoration(size),

          // Main Content
          SafeArea(
            child: SingleChildScrollView(
              child: SizedBox(
                height: size.height - MediaQuery.of(context).padding.top,
                child: Column(
                  children: [
                    // Skip Button
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: widget.onSkip ?? () async {
                                await DatabaseService().setPreference('is_logged_in', 'true');
                                Navigator.of(context).pushReplacementNamed('/dashboard');
                              },
                              child: Text(
                                'Skip',
                                style: AppTypography.labelLarge.copyWith(
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    const Spacer(flex: 1),

                    // Logo and Title
                    _buildHeader(),

                    const SizedBox(height: 40),

                    // Auth Card
                    _buildAuthCard(),

                    const Spacer(flex: 2),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _bgController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: const [
                Color(0xFF1A237E),
                Color(0xFF283593),
                Color(0xFF303F9F),
                Color(0xFF1565C0),
              ],
              stops: [
                0.0,
                0.3 + _bgController.value * 0.1,
                0.6 + _bgController.value * 0.1,
                1.0,
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloatingDecoration(Size size) {
    return Stack(
      children: [
        // Large Circle
        Positioned(
          top: -100,
          right: -100,
          child: AnimatedBuilder(
            animation: _bgController,
            builder: (context, child) {
              return Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        // Small Circle
        Positioned(
          bottom: size.height * 0.3,
          left: -50,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.secondary.withValues(alpha: 0.15),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: _cardController,
      builder: (context, child) {
        return Opacity(
          opacity: _cardOpacity.value,
          child: Column(
            children: [
              // Logo
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.balance_rounded,
                    size: 40,
                    color: AppColors.primary,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Title
              Text(
                _isLogin ? 'Welcome Back' : 'Create Account',
                style: AppTypography.headlineMedium.copyWith(
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 8),

              // Subtitle
              Text(
                _isLogin
                    ? 'Sign in to continue'
                    : 'Sign up to get started',
                style: AppTypography.bodyLarge.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAuthCard() {
    return AnimatedBuilder(
      animation: _cardController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _cardSlide.value),
          child: Opacity(
            opacity: _cardOpacity.value,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: GlassmorphicContainer(
                padding: const EdgeInsets.all(24),
                blur: 20,
                opacity: 0.15,
                borderRadius: 28,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Email Field
                      _buildTextField(
                        controller: _emailController,
                        label: 'Email',
                        hint: 'Enter your email',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter your email';
                          }
                          if (!value!.contains('@')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Password Field
                      _buildTextField(
                        controller: _passwordController,
                        label: 'Password',
                        hint: 'Enter your password',
                        icon: Icons.lock_outline,
                        obscureText: _obscurePassword,
                        suffixIcon: _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        onSuffixTap: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter your password';
                          }
                          if (value!.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),

                      if (_isLogin) ...[
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: Text(
                              'Forgot Password?',
                              style: AppTypography.labelMedium.copyWith(
                                color: AppColors.secondary,
                              ),
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Submit Button
                      GradientButton(
                        text: _isLogin ? 'Sign In' : 'Sign Up',
                        onPressed: _handleEmailAuth,
                        isLoading: _isLoading,
                        gradient: AppGradients.premiumLegal,
                      ),

                      const SizedBox(height: 24),

                      // Divider
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 1,
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'OR',
                              style: AppTypography.labelSmall.copyWith(
                                color: Colors.white.withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 1,
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Google Sign In
                      _buildGoogleButton(),

                      const SizedBox(height: 24),

                      // Toggle Auth Mode
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _isLogin
                                ? "Don't have an account?"
                                : 'Already have an account?',
                            style: AppTypography.bodySmall.copyWith(
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                          TextButton(
                            onPressed: _toggleAuthMode,
                            child: Text(
                              _isLogin ? 'Sign Up' : 'Sign In',
                              style: AppTypography.labelMedium.copyWith(
                                color: AppColors.secondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    IconData? suffixIcon,
    VoidCallback? onSuffixTap,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          style: AppTypography.bodyLarge.copyWith(color: Colors.white),
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.4),
            ),
            prefixIcon: Icon(
              icon,
              color: Colors.white.withValues(alpha: 0.7),
            ),
            suffixIcon: suffixIcon != null
                ? GestureDetector(
                    onTap: onSuffixTap,
                    child: Icon(
                      suffixIcon,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  )
                : null,
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.2),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.2),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppColors.secondary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppColors.error,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleButton() {
    return GestureDetector(
      onTap: _handleGoogleSignIn,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Google Icon (simplified)
            Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: Stack(
                children: [
                  // Red
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEA4335),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  // Yellow
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFBBC05),
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  // Green
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Color(0xFF34A853),
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  // Blue
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4285F4),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Continue with Google',
              style: AppTypography.button.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
