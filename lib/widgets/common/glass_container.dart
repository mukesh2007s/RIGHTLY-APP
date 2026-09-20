import 'dart:ui';
import 'package:flutter/material.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_theme.dart';

/// Premium Glassmorphic Container Widget
class GlassmorphicContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blur;
  final double opacity;
  final Color? borderColor;
  final double borderWidth;
  final Gradient? gradient;

  const GlassmorphicContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = 20,
    this.blur = 10,
    this.opacity = 0.1,
    this.borderColor,
    this.borderWidth = 1,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: AppShadows.glass,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              gradient: gradient ??
                  LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: opacity + 0.1),
                      Colors.white.withValues(alpha: opacity),
                    ],
                  ),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: borderColor ?? Colors.white.withValues(alpha: 0.2),
                width: borderWidth,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}


/// Animated Gradient Container
class AnimatedGradientContainer extends StatefulWidget {
  final Widget child;
  final List<Color> colors;
  final Duration duration;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;

  const AnimatedGradientContainer({
    super.key,
    required this.child,
    this.colors = const [
      AppColors.gradientStart,
      AppColors.gradientMiddle,
      AppColors.gradientEnd,
    ],
    this.duration = const Duration(seconds: 3),
    this.width,
    this.height,
    this.padding,
    this.borderRadius = 20,
  });

  @override
  State<AnimatedGradientContainer> createState() =>
      _AnimatedGradientContainerState();
}

class _AnimatedGradientContainerState extends State<AnimatedGradientContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Alignment> _topAlignment;
  late Animation<Alignment> _bottomAlignment;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat(reverse: true);

    _topAlignment = TweenSequence<Alignment>([
      TweenSequenceItem(
        tween: Tween(begin: Alignment.topLeft, end: Alignment.topRight),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: Alignment.topRight, end: Alignment.bottomRight),
        weight: 1,
      ),
    ]).animate(_controller);

    _bottomAlignment = TweenSequence<Alignment>([
      TweenSequenceItem(
        tween: Tween(begin: Alignment.bottomRight, end: Alignment.bottomLeft),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: Alignment.bottomLeft, end: Alignment.topLeft),
        weight: 1,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          padding: widget.padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: _topAlignment.value,
              end: _bottomAlignment.value,
              colors: widget.colors,
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}


/// Premium Card with Shadow and Animations
class PremiumCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? backgroundColor;
  final Gradient? gradient;
  final VoidCallback? onTap;
  final bool enableHover;

  const PremiumCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 20,
    this.backgroundColor,
    this.gradient,
    this.onTap,
    this.enableHover = true,
  });

  @override
  State<PremiumCard> createState() => _PremiumCardState();
}

class _PremiumCardState extends State<PremiumCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.fast,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _elevationAnimation = Tween<double>(begin: 0, end: 8).animate(
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
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: widget.enableHover ? (_) => _controller.forward() : null,
            onTapUp: widget.enableHover ? (_) => _controller.reverse() : null,
            onTapCancel:
                widget.enableHover ? () => _controller.reverse() : null,
            onTap: widget.onTap,
            child: Container(
              margin: widget.margin,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                gradient: widget.gradient,
                color: widget.gradient == null
                    ? (widget.backgroundColor ?? Colors.white)
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04 + (_elevationAnimation.value * 0.01)),
                    blurRadius: 20 + _elevationAnimation.value,
                    offset: Offset(0, 4 + _elevationAnimation.value),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                child: Container(
                  padding: widget.padding,
                  child: widget.child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}


/// Floating Particle Background
class FloatingParticles extends StatefulWidget {
  final int particleCount;
  final Color particleColor;
  final double maxSize;
  final double minSize;

  const FloatingParticles({
    super.key,
    this.particleCount = 20,
    this.particleColor = AppColors.primary,
    this.maxSize = 8,
    this.minSize = 2,
  });

  @override
  State<FloatingParticles> createState() => _FloatingParticlesState();
}

class _FloatingParticlesState extends State<FloatingParticles>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<Offset>> _animations;
  late List<double> _sizes;

  @override
  void initState() {
    super.initState();
    _controllers = [];
    _animations = [];
    _sizes = [];

    for (int i = 0; i < widget.particleCount; i++) {
      final controller = AnimationController(
        duration: Duration(seconds: 3 + (i % 5)),
        vsync: this,
      )..repeat(reverse: true);

      _controllers.add(controller);

      final startOffset = Offset(
        (i * 0.1) % 1.0,
        (i * 0.15) % 1.0,
      );
      final endOffset = Offset(
        ((i * 0.1) + 0.1) % 1.0,
        ((i * 0.15) + 0.2) % 1.0,
      );

      _animations.add(
        Tween<Offset>(begin: startOffset, end: endOffset).animate(
          CurvedAnimation(parent: controller, curve: Curves.easeInOut),
        ),
      );

      _sizes.add(
        widget.minSize + (i % 3) * ((widget.maxSize - widget.minSize) / 3),
      );
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: List.generate(widget.particleCount, (index) {
            return AnimatedBuilder(
              animation: _animations[index],
              builder: (context, child) {
                return Positioned(
                  left: _animations[index].value.dx * constraints.maxWidth,
                  top: _animations[index].value.dy * constraints.maxHeight,
                  child: Container(
                    width: _sizes[index],
                    height: _sizes[index],
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.particleColor.withValues(alpha: 0.1),
                    ),
                  ),
                );
              },
            );
          }),
        );
      },
    );
  }
}


/// Shimmer Loading Effect
class ShimmerLoading extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerLoading({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          colors: [
            AppColors.lightGray.withValues(alpha: 0.5),
            AppColors.ultraLightGray,
            AppColors.lightGray.withValues(alpha: 0.5),
          ],
        ),
      ),
    );
  }
}
