import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_typography.dart';
import '../../themes/app_theme.dart';
import '../../widgets/buttons/gradient_button.dart';

/// Premium Onboarding Screen
class OnboardingScreen extends StatefulWidget {
  final VoidCallback? onComplete;

  const OnboardingScreen({
    super.key,
    this.onComplete,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _illustrationController;
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: 'Know Your Rights',
      description:
          'Access comprehensive legal information about your fundamental rights as an Indian citizen.',
      icon: Icons.menu_book_rounded,
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
      ),
    ),
    OnboardingData(
      title: 'AI Legal Assistant',
      description:
          'Get instant answers to your legal questions in English, Tamil, Hindi, Telugu, and Malayalam.',
      icon: Icons.smart_toy_rounded,
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
      ),
    ),
    OnboardingData(
      title: 'Voice Interaction',
      description:
          'Speak naturally with our AI assistant. Ask questions and receive voice responses.',
      icon: Icons.record_voice_over_rounded,
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF283593), Color(0xFF5C6BC0)],
      ),
    ),
    OnboardingData(
      title: 'Works Offline',
      description:
          'Access legal information even without internet. Your privacy is our priority.',
      icon: Icons.offline_bolt_rounded,
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFD4AF37), Color(0xFFE8D5A3)],
      ),
      iconColor: AppColors.textPrimary,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _illustrationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _illustrationController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: AppAnimations.normal,
        curve: Curves.easeInOutCubic,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  void _completeOnboarding() {
    if (widget.onComplete != null) {
      widget.onComplete!();
    } else if (mounted) {
      Navigator.of(context).pushReplacementNamed('/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _skipOnboarding,
                    child: Text(
                      'Skip',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.coolGray,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Page Content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index], index);
                },
              ),
            ),

            // Page Indicators
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => _buildPageIndicator(index),
                ),
              ),
            ),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: _currentPage == _pages.length - 1
                  ? GradientButton(
                      text: 'Get Started',
                      onPressed: _nextPage,
                      width: double.infinity,
                      gradient: AppGradients.premiumLegal,
                    )
                  : GradientButton(
                      text: 'Continue',
                      onPressed: _nextPage,
                      width: double.infinity,
                      icon: Icons.arrow_forward_rounded,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingData data, int index) {
    return AnimatedBuilder(
      animation: _illustrationController,
      builder: (context, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated Illustration
              Transform.translate(
                offset: Offset(
                  0,
                  math.sin(_illustrationController.value * math.pi) * 10,
                ),
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: data.gradient,
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: (data.gradient.colors.first).withValues(alpha: 0.3),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Background Pattern
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(40),
                          child: CustomPaint(
                            painter: PatternPainter(
                              progress: _illustrationController.value,
                            ),
                          ),
                        ),
                      ),
                      // Icon
                      Center(
                        child: Icon(
                          data.icon,
                          size: 80,
                          color: data.iconColor ?? Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 48),

              // Title
              Text(
                data.title,
                style: AppTypography.headlineMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Description
              Text(
                data.description,
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.coolGray,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPageIndicator(int index) {
    final isActive = index == _currentPage;
    return AnimatedContainer(
      duration: AppAnimations.fast,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 32 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : AppColors.lightGray,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}


/// Onboarding Page Data Model
class OnboardingData {
  final String title;
  final String description;
  final IconData icon;
  final LinearGradient gradient;
  final Color? iconColor;

  OnboardingData({
    required this.title,
    required this.description,
    required this.icon,
    required this.gradient,
    this.iconColor,
  });
}


/// Pattern Painter for Illustration Background
class PatternPainter extends CustomPainter {
  final double progress;

  PatternPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw animated circles
    for (int i = 0; i < 5; i++) {
      final radius = 20.0 + i * 30 + progress * 10;
      canvas.drawCircle(
        Offset(size.width / 2, size.height / 2),
        radius,
        paint,
      );
    }

    // Draw diagonal lines
    for (int i = 0; i < 10; i++) {
      final offset = i * 30.0 + progress * 20;
      canvas.drawLine(
        Offset(offset, 0),
        Offset(offset + size.height, size.height),
        paint..color = Colors.white.withValues(alpha: 0.05),
      );
    }
  }

  @override
  bool shouldRepaint(covariant PatternPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
