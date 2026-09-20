import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_typography.dart';
import '../../widgets/buttons/gradient_button.dart';
import '../../widgets/common/glass_container.dart';

/// Forgot Password Screen — Reset password flow
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;

  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
      _emailSent = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withOpacity(0.95),
              const Color(0xFF0D47A1),
              AppColors.primary,
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeIn,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  // Back button
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Icon
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1),
                      border: Border.all(
                        color: AppColors.legalGold.withOpacity(0.4),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      _emailSent ? Icons.mark_email_read : Icons.lock_reset,
                      size: 48,
                      color: AppColors.legalGold,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    _emailSent ? 'Check Your Email' : 'Forgot Password?',
                    style: AppTypography.headlineMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _emailSent
                        ? 'We\'ve sent a password reset link to\n${_emailController.text}'
                        : 'Enter your email address and we\'ll send\nyou a link to reset your password.',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMedium.copyWith(
                      color: Colors.white60,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 40),
                  if (!_emailSent) ...[
                    GlassmorphicContainer(
                      borderRadius: 24,
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Email Address',
                              style: AppTypography.labelMedium
                                  .copyWith(color: Colors.white70),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Enter your registered email',
                                hintStyle: TextStyle(
                                    color: Colors.white.withOpacity(0.4)),
                                prefixIcon: Icon(Icons.email_outlined,
                                    color: AppColors.legalGold),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.1),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                      color: Colors.white.withOpacity(0.15)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                      color: AppColors.legalGold, width: 1.5),
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'Email is required';
                                }
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                    .hasMatch(v)) {
                                  return 'Enter a valid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: GradientButton(
                                text: 'Send Reset Link',
                                onPressed: _handleResetPassword,
                                borderRadius: 16,
                                isLoading: _isLoading,
                                icon: Icons.send,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    // Success state
                    GlassmorphicContainer(
                      borderRadius: 24,
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 64,
                            color: AppColors.legalGold,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Email Sent Successfully!',
                            style: AppTypography.titleMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: GradientButton(
                              text: 'Back to Login',
                              onPressed: () => Navigator.pop(context),
                              borderRadius: 16,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () {
                              setState(() => _emailSent = false);
                            },
                            child: Text(
                              'Didn\'t receive? Resend',
                              style: AppTypography.labelMedium.copyWith(
                                color: AppColors.legalGold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
