import 'package:flutter/material.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_theme.dart';
import '../../themes/app_typography.dart';

/// Premium Animated Input Field
class AnimatedInputField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final int maxLines;
  final bool autofocus;
  final FocusNode? focusNode;

  const AnimatedInputField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.maxLines = 1,
    this.autofocus = false,
    this.focusNode,
  });

  @override
  State<AnimatedInputField> createState() => _AnimatedInputFieldState();
}

class _AnimatedInputFieldState extends State<AnimatedInputField>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _borderAnimation;
  late Animation<Color?> _colorAnimation;
  late FocusNode _focusNode;
  bool _isFocused = false;
  // ignore: unused_field
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _controller = AnimationController(
      duration: AppAnimations.fast,
      vsync: this,
    );

    _borderAnimation = Tween<double>(begin: 1, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _colorAnimation = ColorTween(
      begin: AppColors.lightGray,
      end: AppColors.primary,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _focusNode.addListener(_onFocusChange);
    _hasText = widget.controller?.text.isNotEmpty ?? false;
  }

  @override
  void dispose() {
    _controller.dispose();
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
    if (_focusNode.hasFocus) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Floating Label
            AnimatedDefaultTextStyle(
              duration: AppAnimations.fast,
              style: AppTypography.labelMedium.copyWith(
                color: _isFocused ? AppColors.primary : AppColors.coolGray,
                fontWeight: _isFocused ? FontWeight.w600 : FontWeight.w500,
              ),
              child: Text(widget.label),
            ),
            const SizedBox(height: 8),
            // Input Container
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _colorAnimation.value ?? AppColors.lightGray,
                  width: _borderAnimation.value,
                ),
                boxShadow: _isFocused
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: TextFormField(
                controller: widget.controller,
                focusNode: _focusNode,
                obscureText: widget.obscureText,
                keyboardType: widget.keyboardType,
                maxLines: widget.maxLines,
                autofocus: widget.autofocus,
                style: AppTypography.bodyLarge,
                validator: widget.validator,
                onChanged: (value) {
                  setState(() {
                    _hasText = value.isNotEmpty;
                  });
                  widget.onChanged?.call(value);
                },
                onFieldSubmitted: widget.onSubmitted,
                decoration: InputDecoration(
                  hintText: widget.hint,
                  hintStyle: AppTypography.bodyMedium.copyWith(
                    color: AppColors.coolGray,
                  ),
                  prefixIcon: widget.prefixIcon != null
                      ? Icon(
                          widget.prefixIcon,
                          color:
                              _isFocused ? AppColors.primary : AppColors.coolGray,
                        )
                      : null,
                  suffixIcon: widget.suffixIcon != null
                      ? GestureDetector(
                          onTap: widget.onSuffixTap,
                          child: Icon(
                            widget.suffixIcon,
                            color: _isFocused
                                ? AppColors.primary
                                : AppColors.coolGray,
                          ),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}


/// Chat Input Field with Voice Button
class ChatInputField extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback? onVoice;
  final String hint;
  final bool isListening;

  const ChatInputField({
    super.key,
    required this.controller,
    required this.onSend,
    this.onVoice,
    this.hint = 'Type your message...',
    this.isListening = false,
  });

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField>
    with SingleTickerProviderStateMixin {
  late AnimationController _voiceController;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _voiceController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _voiceController.dispose();
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  @override
  void didUpdateWidget(ChatInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isListening != oldWidget.isListening) {
      if (widget.isListening) {
        _voiceController.repeat(reverse: true);
      } else {
        _voiceController.stop();
        _voiceController.reset();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: AppShadows.soft,
      ),
      child: Row(
        children: [
          // Text Input
          Expanded(
            child: TextField(
              controller: widget.controller,
              style: AppTypography.bodyLarge,
              maxLines: 4,
              minLines: 1,
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: AppTypography.bodyMedium.copyWith(
                  color: AppColors.coolGray,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Voice / Send Button
          AnimatedSwitcher(
            duration: AppAnimations.fast,
            transitionBuilder: (child, animation) {
              return ScaleTransition(scale: animation, child: child);
            },
            child: _hasText
                ? _buildSendButton()
                : _buildVoiceButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildSendButton() {
    return GestureDetector(
      key: const ValueKey('send'),
      onTap: () {
        if (widget.controller.text.isNotEmpty) {
          widget.onSend();
        }
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppGradients.primary,
        ),
        child: const Icon(
          Icons.send_rounded,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildVoiceButton() {
    return GestureDetector(
      key: const ValueKey('voice'),
      onTap: widget.onVoice,
      child: AnimatedBuilder(
        animation: _voiceController,
        builder: (context, child) {
          return Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.isListening
                  ? AppColors.accent.withValues(alpha: 0.1 + (_voiceController.value * 0.2))
                  : AppColors.ultraLightGray,
            ),
            child: Icon(
              widget.isListening ? Icons.mic : Icons.mic_none_rounded,
              color: widget.isListening ? AppColors.accent : AppColors.coolGray,
              size: 22,
            ),
          );
        },
      ),
    );
  }
}


/// Search Input Field
class SearchInputField extends StatefulWidget {
  final String hint;
  final void Function(String)? onChanged;
  final VoidCallback? onClear;

  const SearchInputField({
    super.key,
    this.hint = 'Search...',
    this.onChanged,
    this.onClear,
  });

  @override
  State<SearchInputField> createState() => _SearchInputFieldState();
}

class _SearchInputFieldState extends State<SearchInputField> {
  final TextEditingController _controller = TextEditingController();
  bool _hasText = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.ultraLightGray,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: _controller,
        style: AppTypography.bodyMedium,
        onChanged: (value) {
          setState(() {
            _hasText = value.isNotEmpty;
          });
          widget.onChanged?.call(value);
        },
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: AppTypography.bodyMedium.copyWith(
            color: AppColors.coolGray,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.coolGray,
          ),
          suffixIcon: _hasText
              ? GestureDetector(
                  onTap: () {
                    _controller.clear();
                    setState(() {
                      _hasText = false;
                    });
                    widget.onClear?.call();
                  },
                  child: const Icon(
                    Icons.close_rounded,
                    color: AppColors.coolGray,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}


/// Animated Search Field with focus animation
class AnimatedSearchField extends StatefulWidget {
  final TextEditingController? controller;
  final String hintText;
  final void Function(String)? onChanged;
  final VoidCallback? onClear;

  const AnimatedSearchField({
    super.key,
    this.controller,
    this.hintText = 'Search...',
    this.onChanged,
    this.onClear,
  });

  @override
  State<AnimatedSearchField> createState() => _AnimatedSearchFieldState();
}

class _AnimatedSearchFieldState extends State<AnimatedSearchField>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scaleAnimation;
  late final TextEditingController _controller;
  bool _isFocused = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
    _hasText = _controller.text.isNotEmpty;
  }

  @override
  void dispose() {
    _animController.dispose();
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: 52,
        decoration: BoxDecoration(
          color: _isFocused ? Colors.white : AppColors.ultraLightGray,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isFocused
                ? AppColors.primary.withValues(alpha: 0.3)
                : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: _isFocused
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: TextField(
          controller: _controller,
          style: AppTypography.bodyMedium,
          onChanged: (value) {
            setState(() => _hasText = value.isNotEmpty);
            widget.onChanged?.call(value);
          },
          onTap: () {
            setState(() => _isFocused = true);
            _animController.forward();
          },
          onEditingComplete: () {
            setState(() => _isFocused = false);
            _animController.reverse();
            FocusScope.of(context).unfocus();
          },
          onTapOutside: (_) {
            setState(() => _isFocused = false);
            _animController.reverse();
            FocusScope.of(context).unfocus();
          },
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: AppTypography.bodyMedium.copyWith(
              color: AppColors.coolGray,
            ),
            prefixIcon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.search_rounded,
                key: ValueKey(_isFocused),
                color: _isFocused ? AppColors.primary : AppColors.coolGray,
              ),
            ),
            suffixIcon: _hasText
                ? GestureDetector(
                    onTap: () {
                      _controller.clear();
                      setState(() => _hasText = false);
                      widget.onChanged?.call('');
                      widget.onClear?.call();
                    },
                    child: const Icon(
                      Icons.close_rounded,
                      color: AppColors.coolGray,
                      size: 20,
                    ),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }
}