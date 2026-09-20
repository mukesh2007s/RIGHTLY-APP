import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_typography.dart';
import '../../themes/app_theme.dart';

/// Premium Call Agent Screen with Legal AI Assistance
class CallAgentScreen extends StatefulWidget {
  const CallAgentScreen({super.key});

  @override
  State<CallAgentScreen> createState() => _CallAgentScreenState();
}

class _CallAgentScreenState extends State<CallAgentScreen>
    with TickerProviderStateMixin {
  CallState _callState = CallState.idle;
  int _callDuration = 0;
  
  late AnimationController _pulseController;
  late AnimationController _ringController;
  late AnimationController _avatarController;
  
  late Animation<double> _pulseAnimation;
  // ignore: unused_field
  late Animation<double> _ringAnimation;
  late Animation<double> _avatarAnimation;

  @override
  void initState() {
    super.initState();
    
    // Pulse animation for active call
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    // Ring animation for incoming call
    _ringController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _ringAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ringController, curve: Curves.easeOut),
    );
    
    // Avatar animation
    _avatarController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _avatarAnimation = Tween<double>(begin: 0.0, end: 10.0).animate(
      CurvedAnimation(parent: _avatarController, curve: Curves.easeInOut),
    );

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _ringController.dispose();
    _avatarController.dispose();
    super.dispose();
  }

  void _startCall() {
    HapticFeedback.mediumImpact();
    setState(() => _callState = CallState.connecting);
    _ringController.repeat(reverse: true);
    
    // Simulate connecting
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && _callState == CallState.connecting) {
        setState(() => _callState = CallState.active);
        _ringController.stop();
        _pulseController.repeat(reverse: true);
        _startCallTimer();
      }
    });
  }

  void _endCall() {
    HapticFeedback.heavyImpact();
    setState(() {
      _callState = CallState.ended;
      _callDuration = 0;
    });
    _pulseController.stop();
    _ringController.stop();
    
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _callState = CallState.idle);
      }
    });
  }

  void _startCallTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _callState == CallState.active) {
        setState(() => _callDuration++);
        _startCallTimer();
      }
    });
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: _callState == CallState.active
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF0A1628),
                    Color(0xFF1A237E),
                    Color(0xFF0D47A1),
                  ],
                )
              : AppGradients.splash,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              _buildAppBar(),
              
              const Spacer(),
              
              // Avatar and Status
              _buildCallerAvatar(),
              
              const SizedBox(height: 24),
              
              // Caller Info
              _buildCallerInfo(),
              
              const SizedBox(height: 16),
              
              // Call Status
              _buildCallStatus(),
              
              const Spacer(),
              
              // Call Controls
              _buildCallControls(),
              
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          if (_callState == CallState.active)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatDuration(_callDuration),
                    style: AppTypography.labelMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildCallerAvatar() {
    return AnimatedBuilder(
      animation: Listenable.merge([_avatarController, _pulseController, _ringController]),
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer pulse rings (when connecting or active)
            if (_callState == CallState.connecting || _callState == CallState.active)
              ...List.generate(3, (index) {
                return Container(
                  width: 180 + (index * 40) + (_pulseAnimation.value - 1) * 30,
                  height: 180 + (index * 40) + (_pulseAnimation.value - 1) * 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _callState == CallState.active
                          ? AppColors.success.withValues(alpha: 0.3 - (index * 0.1))
                          : Colors.white.withValues(alpha: 0.2 - (index * 0.05)),
                      width: 2,
                    ),
                  ),
                );
              }),
            
            // Avatar glow
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _getGlowColor().withValues(alpha: 0.4),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
            ),
            
            // Avatar container
            Transform.translate(
              offset: Offset(0, _avatarAnimation.value),
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.legalGold,
                      AppColors.primary,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.balance_rounded,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Color _getGlowColor() {
    switch (_callState) {
      case CallState.idle:
        return AppColors.primary;
      case CallState.connecting:
        return AppColors.secondary;
      case CallState.active:
        return AppColors.success;
      case CallState.ended:
        return AppColors.error;
    }
  }

  Widget _buildCallerInfo() {
    return Column(
      children: [
        Text(
          'Rightly AI',
          style: AppTypography.headlineMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Legal Assistance Agent',
          style: AppTypography.bodyMedium.copyWith(
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildCallStatus() {
    String status;
    Color color;
    
    switch (_callState) {
      case CallState.idle:
        status = 'Ready to connect';
        color = Colors.white70;
        break;
      case CallState.connecting:
        status = 'Connecting...';
        color = AppColors.secondary;
        break;
      case CallState.active:
        status = 'Call in progress';
        color = AppColors.success;
        break;
      case CallState.ended:
        status = 'Call ended';
        color = AppColors.error;
        break;
    }
    
    return AnimatedSwitcher(
      duration: AppAnimations.fast,
      child: Row(
        key: ValueKey(status),
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            status,
            style: AppTypography.bodyMedium.copyWith(
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallControls() {
    if (_callState == CallState.idle || _callState == CallState.ended) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48),
        child: Column(
          children: [
            // Start Call Button
            GestureDetector(
              onTap: _startCall,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.success,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.success.withValues(alpha: 0.4),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.call_rounded,
                  color: Colors.white,
                  size: 36,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Tap to start call',
              style: AppTypography.bodySmall.copyWith(
                color: Colors.white70,
              ),
            ),
          ],
        ),
      );
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Mute Button
          _buildControlButton(
            icon: Icons.mic_off_rounded,
            label: 'Mute',
            onTap: () => HapticFeedback.lightImpact(),
          ),
          
          // End Call Button
          GestureDetector(
            onTap: _endCall,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.error,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.error.withValues(alpha: 0.4),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.call_end_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
          
          // Speaker Button
          _buildControlButton(
            icon: Icons.volume_up_rounded,
            label: 'Speaker',
            onTap: () => HapticFeedback.lightImpact(),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.15),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}


/// Call States
enum CallState {
  idle,
  connecting,
  active,
  ended,
}
