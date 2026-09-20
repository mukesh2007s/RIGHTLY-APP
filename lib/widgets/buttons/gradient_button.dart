import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_theme.dart';
import '../../themes/app_typography.dart';

/// Premium Gradient Button with animations
class GradientButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Gradient gradient;
  final double? width;
  final double height;
  final double borderRadius;
  final bool isLoading;
  final IconData? icon;
  final bool enableGlow;

  const GradientButton({
    super.key,
    required this.text,
    this.onPressed,
    this.gradient = AppGradients.primary,
    this.width,
    this.height = 56,
    this.borderRadius = 16,
    this.isLoading = false,
    this.icon,
    this.enableGlow = true,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

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

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.5).animate(
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
            onTapDown: widget.onPressed != null ? _onTapDown : null,
            onTapUp: widget.onPressed != null ? _onTapUp : null,
            onTapCancel: widget.onPressed != null ? _onTapCancel : null,
            onTap: widget.isLoading ? null : widget.onPressed,
            child: Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                gradient: widget.onPressed != null
                    ? widget.gradient
                    : LinearGradient(
                        colors: [
                          AppColors.coolGray,
                          AppColors.coolGray.withValues(alpha: 0.8),
                        ],
                      ),
                borderRadius: BorderRadius.circular(widget.borderRadius),
                boxShadow: widget.enableGlow && widget.onPressed != null
                    ? [
                        BoxShadow(
                          color: AppColors.primary
                              .withValues(alpha: _glowAnimation.value),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: widget.isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.icon != null) ...[
                            Icon(
                              widget.icon,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            widget.text,
                            style: AppTypography.button.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}


/// Gold Accent Button
class GoldButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final double? width;
  final double height;
  final IconData? icon;

  const GoldButton({
    super.key,
    required this.text,
    this.onPressed,
    this.width,
    this.height = 56,
    this.icon,
  });

  @override
  State<GoldButton> createState() => _GoldButtonState();
}

class _GoldButtonState extends State<GoldButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _shimmerAnimation = Tween<double>(begin: -1, end: 2).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            widget.onPressed?.call();
          },
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: const [
                  AppColors.secondary,
                  AppColors.paleGold,
                  AppColors.secondary,
                ],
                stops: [
                  _shimmerAnimation.value - 1,
                  _shimmerAnimation.value,
                  _shimmerAnimation.value + 1,
                ].map((e) => e.clamp(0.0, 1.0)).toList(),
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppShadows.goldGlow,
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      color: AppColors.textPrimary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    widget.text,
                    style: AppTypography.button.copyWith(
                      color: AppColors.textPrimary,
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


/// Outlined Premium Button
class OutlinedPremiumButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final double? width;
  final double height;
  final Color borderColor;
  final Color textColor;
  final IconData? icon;

  const OutlinedPremiumButton({
    super.key,
    required this.text,
    this.onPressed,
    this.width,
    this.height = 56,
    this.borderColor = AppColors.primary,
    this.textColor = AppColors.primary,
    this.icon,
  });

  @override
  State<OutlinedPremiumButton> createState() => _OutlinedPremiumButtonState();
}

class _OutlinedPremiumButtonState extends State<OutlinedPremiumButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fillAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _fillAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _fillAnimation,
      builder: (context, child) {
        return GestureDetector(
          onTapDown: (_) => _controller.forward(),
          onTapUp: (_) => _controller.reverse(),
          onTapCancel: () => _controller.reverse(),
          onTap: () {
            HapticFeedback.lightImpact();
            widget.onPressed?.call();
          },
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: widget.borderColor.withValues(alpha: _fillAnimation.value * 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: widget.borderColor,
                width: 2,
              ),
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      color: widget.textColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    widget.text,
                    style: AppTypography.button.copyWith(
                      color: widget.textColor,
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


/// Floating Action Button with Glow
class GlowingFAB extends StatefulWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final double size;

  const GlowingFAB({
    super.key,
    this.onPressed,
    this.icon = Icons.add,
    this.backgroundColor = AppColors.primary,
    this.iconColor = Colors.white,
    this.size = 56,
  });

  @override
  State<GlowingFAB> createState() => _GlowingFABState();
}

class _GlowingFABState extends State<GlowingFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.3, end: 0.6).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            widget.onPressed?.call();
          },
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.backgroundColor,
              boxShadow: [
                BoxShadow(
                  color: widget.backgroundColor
                      .withValues(alpha: _pulseAnimation.value),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              widget.icon,
              color: widget.iconColor,
              size: widget.size * 0.5,
            ),
          ),
        );
      },
    );
  }
}


/// Icon Button with Ripple Effect
class PremiumIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? iconColor;
  final Color? backgroundColor;
  final double size;

  const PremiumIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.iconColor,
    this.backgroundColor,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor ?? Colors.transparent,
      borderRadius: BorderRadius.circular(size / 2),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onPressed?.call();
        },
        borderRadius: BorderRadius.circular(size / 2),
        child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          child: Icon(
            icon,
            color: iconColor ?? AppColors.textPrimary,
            size: size * 0.5,
          ),
        ),
      ),
    );
  }
}
