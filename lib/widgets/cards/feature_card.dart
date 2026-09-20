import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_typography.dart';
import '../../themes/app_theme.dart';
import '../../screens/dashboard/dashboard_screen.dart';

/// Premium Feature Card Widget
class FeatureCard extends StatefulWidget {
  final FeatureData data;

  const FeatureCard({
    super.key,
    required this.data,
  });

  @override
  State<FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<FeatureCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _elevationAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
    HapticFeedback.lightImpact();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            onTap: widget.data.onTap,
            child: Container(
              decoration: BoxDecoration(
                gradient: widget.data.gradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: (widget.data.gradient as LinearGradient)
                        .colors
                        .first
                        .withValues(alpha: 0.3 + (_elevationAnimation.value * 0.02)),
                    blurRadius: 20 + _elevationAnimation.value,
                    offset: Offset(0, 8 + _elevationAnimation.value),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Background Pattern
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: CustomPaint(
                        painter: CardPatternPainter(),
                      ),
                    ),
                  ),

                  // Content
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon Container
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Icon(
                              widget.data.icon,
                              color: widget.data.iconColor ?? Colors.white,
                              size: 26,
                            ),
                          ),
                        ),

                        const Spacer(),

                        // Title
                        Text(
                          widget.data.title,
                          style: AppTypography.titleMedium.copyWith(
                            color: widget.data.iconColor ?? Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 4),

                        // Subtitle
                        Text(
                          widget.data.subtitle,
                          style: AppTypography.bodySmall.copyWith(
                            color: (widget.data.iconColor ?? Colors.white)
                                .withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Arrow Indicator
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Icon(
                      Icons.arrow_outward_rounded,
                      color: (widget.data.iconColor ?? Colors.white)
                          .withValues(alpha: 0.6),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}


/// Card Background Pattern Painter
class CardPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;

    // Draw decorative circles
    canvas.drawCircle(
      Offset(size.width * 0.9, size.height * 0.1),
      40,
      paint,
    );

    canvas.drawCircle(
      Offset(size.width * 1.1, size.height * 0.5),
      60,
      paint..color = Colors.white.withValues(alpha: 0.03),
    );

    // Draw subtle lines
    paint
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 0; i < 3; i++) {
      canvas.drawLine(
        Offset(size.width * 0.6 + i * 20, 0),
        Offset(size.width * 0.8 + i * 20, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


/// Info Card Widget
class InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const InfoCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.soft,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.caption,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTypography.titleMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


/// Legal Topic Card
class LegalTopicCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  const LegalTopicCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppShadows.soft,
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: AppGradients.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTypography.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.coolGray,
            ),
          ],
        ),
      ),
    );
  }
}
