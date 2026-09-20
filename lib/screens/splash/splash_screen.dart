import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_typography.dart';
import '../../services/database_service.dart';
import '../../providers/providers.dart';

/// Premium Animated Splash Screen
class SplashScreen extends StatefulWidget {
  final VoidCallback? onComplete;

  const SplashScreen({
    super.key,
    this.onComplete,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _backgroundController;
  late AnimationController _particleController;

  late Animation<double> _logoScale;
  late Animation<double> _logoRotation;
  late Animation<double> _logoOpacity;
  late Animation<double> _textSlide;
  late Animation<double> _textOpacity;
  late Animation<double> _taglineOpacity;
  late Animation<Alignment> _gradientBegin;
  late Animation<Alignment> _gradientEnd;

  @override
  void initState() {
    super.initState();

    // Set status bar style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    // Logo Animation Controller
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Text Animation Controller
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Background Animation Controller
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    // Particle Animation Controller
    _particleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    // Logo Animations
    _logoScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.2)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.2, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 40,
      ),
    ]).animate(_logoController);

    _logoRotation = Tween<double>(begin: -0.1, end: 0.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    // Text Animations
    _textSlide = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeOutCubic,
      ),
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    // Background Gradient Animation
    _gradientBegin = TweenSequence<Alignment>([
      TweenSequenceItem(
        tween: AlignmentTween(
          begin: Alignment.topLeft,
          end: Alignment.topRight,
        ),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: AlignmentTween(
          begin: Alignment.topRight,
          end: Alignment.bottomRight,
        ),
        weight: 1,
      ),
    ]).animate(_backgroundController);

    _gradientEnd = TweenSequence<Alignment>([
      TweenSequenceItem(
        tween: AlignmentTween(
          begin: Alignment.bottomRight,
          end: Alignment.bottomLeft,
        ),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: AlignmentTween(
          begin: Alignment.bottomLeft,
          end: Alignment.topLeft,
        ),
        weight: 1,
      ),
    ]).animate(_backgroundController);
  }

  void _startAnimations() async {
    // Start logo animation
    await Future.delayed(const Duration(milliseconds: 300));
    _logoController.forward();

    // Start text animation after logo
    await Future.delayed(const Duration(milliseconds: 800));
    _textController.forward();

    // Complete splash after all animations
    await Future.delayed(const Duration(milliseconds: 2500));
    if (widget.onComplete != null) {
      widget.onComplete!();
    } else if (mounted) {
      // Check if user is already logged in
      final isLoggedIn = await DatabaseService().getPreference('is_logged_in');
      // Load saved language and apply to provider
      final savedLang = await DatabaseService().getPreference('app_language');
      if (savedLang != null && mounted) {
        Provider.of<AppStateProvider>(context, listen: false).setLanguage(savedLang);
      }
      if (isLoggedIn == 'true') {
        Navigator.of(context).pushReplacementNamed('/dashboard');
      } else {
        Navigator.of(context).pushReplacementNamed('/onboarding');
      }
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _backgroundController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _backgroundController,
        builder: (context, child) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: _gradientBegin.value,
                end: _gradientEnd.value,
                colors: const [
                  Color(0xFF1A237E),
                  Color(0xFF283593),
                  Color(0xFF303F9F),
                  Color(0xFF1565C0),
                ],
              ),
            ),
            child: Stack(
              children: [
                // Floating Particles
                _buildParticles(),

                // Glow Effect
                _buildGlowEffect(),

                // Main Content
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated Logo
                      _buildAnimatedLogo(),

                      const SizedBox(height: 32),

                      // Animated App Name
                      _buildAnimatedText(),

                      const SizedBox(height: 12),

                      // Animated Tagline
                      _buildAnimatedTagline(),
                    ],
                  ),
                ),

                // Bottom Loading Indicator
                Positioned(
                  bottom: 60,
                  left: 0,
                  right: 0,
                  child: _buildLoadingIndicator(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildParticles() {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: ParticlePainter(
            progress: _particleController.value,
          ),
        );
      },
    );
  }

  Widget _buildGlowEffect() {
    return Center(
      child: AnimatedBuilder(
        animation: _logoController,
        builder: (context, child) {
          return Container(
            width: 300 * _logoScale.value,
            height: 300 * _logoScale.value,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.15 * _logoOpacity.value),
                  Colors.white.withValues(alpha: 0.05 * _logoOpacity.value),
                  Colors.transparent,
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnimatedLogo() {
    return AnimatedBuilder(
      animation: _logoController,
      builder: (context, child) {
        return Transform.rotate(
          angle: _logoRotation.value * math.pi,
          child: Transform.scale(
            scale: _logoScale.value,
            child: Opacity(
              opacity: _logoOpacity.value,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                    BoxShadow(
                      color: AppColors.secondary.withValues(alpha: 0.3),
                      blurRadius: 40,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Center(
                  child: ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.secondary,
                      ],
                    ).createShader(bounds),
                    child: const Icon(
                      Icons.balance_rounded,
                      size: 64,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedText() {
    return AnimatedBuilder(
      animation: _textController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _textSlide.value),
          child: Opacity(
            opacity: _textOpacity.value,
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [
                  Colors.white,
                  AppColors.paleGold,
                ],
              ).createShader(bounds),
              child: Text(
                'RIGHTLY',
                style: AppTypography.displayMedium.copyWith(
                  color: Colors.white,
                  letterSpacing: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedTagline() {
    return AnimatedBuilder(
      animation: _textController,
      builder: (context, child) {
        return Opacity(
          opacity: _taglineOpacity.value,
          child: Text(
            'AI Legal Awareness Assistant',
            style: AppTypography.bodyLarge.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
              letterSpacing: 1,
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return AnimatedBuilder(
      animation: _textController,
      builder: (context, child) {
        return Opacity(
          opacity: _taglineOpacity.value,
          child: Column(
            children: [
              SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Initializing...',
                style: AppTypography.caption.copyWith(
                  color: Colors.white.withValues(alpha: 0.6),
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}


/// Custom Painter for Floating Particles
class ParticlePainter extends CustomPainter {
  final double progress;
  final int particleCount = 30;

  ParticlePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    for (int i = 0; i < particleCount; i++) {
      final seed = i * 137.508; // Golden angle
      final x = (math.sin(seed + progress * math.pi * 2) * 0.5 + 0.5) *
          size.width;
      final y = (math.cos(seed * 0.7 + progress * math.pi * 2) * 0.5 + 0.5) *
          size.height;
      final radius = 2 + (i % 4) * 2.0;
      final opacity = 0.1 + (math.sin(seed + progress * math.pi * 4) * 0.1);

      paint.color = Colors.white.withValues(alpha: opacity.clamp(0.05, 0.2));

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
