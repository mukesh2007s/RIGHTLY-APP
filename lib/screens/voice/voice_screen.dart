import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_typography.dart';
import '../../themes/app_theme.dart';
import '../../services/voice_service.dart';
import '../../services/gemini_service.dart';
import '../../providers/providers.dart';
import '../../utils/app_localizations.dart';

/// Premium Voice Assistant Screen with real STT/TTS + Gemini AI
class VoiceAssistantScreen extends StatefulWidget {
  const VoiceAssistantScreen({super.key});

  @override
  State<VoiceAssistantScreen> createState() => _VoiceAssistantScreenState();
}

class _VoiceAssistantScreenState extends State<VoiceAssistantScreen>
    with TickerProviderStateMixin {
  String get _langCode =>
      Provider.of<AppStateProvider>(context, listen: false).settings.language;
  String _t(String key) => AppLocalizations.get(key, _langCode);

  late AnimationController _pulseController;
  late AnimationController _waveController;
  late AnimationController _glowController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;

  final VoiceService _voiceService = VoiceService();
  final GeminiService _geminiService = GeminiService();

  VoiceState _voiceState = VoiceState.idle;
  String _recognizedText = '';
  String _partialText = '';
  String _responseText = '';
  String _selectedLanguage = VoiceLanguages.english;
  double _soundLevel = 0.0;
  bool _isInitialized = false;
  String? _errorMessage;

  // Conversation history for voice replay
  final List<_VoiceConversation> _history = [];

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _waveController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.6).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    _initializeServices();
  }

  Future<void> _initializeServices() async {
    final sttReady = await _voiceService.initialize();
    await _geminiService.initialize();

    // Set up voice service callbacks
    _voiceService.onResult = _onSpeechResult;
    _voiceService.onPartialResult = _onPartialResult;
    _voiceService.onListeningStarted = _onListeningStarted;
    _voiceService.onListeningStopped = _onListeningStopped;
    _voiceService.onError = _onVoiceError;
    _voiceService.onSoundLevelChange = _onSoundLevelChange;
    _voiceService.onSpeakingCompleted = _onSpeakingCompleted;

    if (mounted) {
      setState(() {
        _isInitialized = true;
        if (!sttReady) {
          _errorMessage = _t('speech_not_available');
        }
      });
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // VOICE CALLBACKS
  // ═══════════════════════════════════════════════════════════════

  void _onSpeechResult(String text) {
    if (!mounted) return;
    setState(() {
      _recognizedText = text;
      _partialText = '';
    });
    _processWithGemini(text);
  }

  void _onPartialResult(String text) {
    if (!mounted) return;
    setState(() {
      _partialText = text;
    });
  }

  void _onListeningStarted() {
    if (!mounted) return;
    setState(() {
      _voiceState = VoiceState.listening;
      _errorMessage = null;
    });
    _pulseController.repeat(reverse: true);
    _waveController.repeat();
  }

  void _onListeningStopped() {
    if (!mounted) return;
    if (_voiceState == VoiceState.listening && _recognizedText.isEmpty && _partialText.isEmpty) {
      setState(() => _voiceState = VoiceState.idle);
      _pulseController.stop();
      _pulseController.reset();
      _waveController.stop();
      _waveController.reset();
    }
  }

  void _onVoiceError(String error) {
    if (!mounted) return;
    setState(() {
      _errorMessage = error;
      if (_voiceState == VoiceState.listening) {
        _voiceState = VoiceState.idle;
      }
    });
    _pulseController.stop();
    _pulseController.reset();
    _waveController.stop();
    _waveController.reset();
  }

  void _onSoundLevelChange(double level) {
    if (!mounted) return;
    setState(() {
      _soundLevel = level.clamp(0.0, 10.0);
    });
  }

  void _onSpeakingCompleted() {
    if (!mounted) return;
    setState(() => _voiceState = VoiceState.idle);
  }

  // ═══════════════════════════════════════════════════════════════
  // CORE LOGIC
  // ═══════════════════════════════════════════════════════════════

  void _toggleListening() {
    HapticFeedback.mediumImpact();

    if (_voiceState == VoiceState.speaking) {
      // Stop speaking if tapped while speaking
      _voiceService.stopSpeaking();
      setState(() => _voiceState = VoiceState.idle);
      return;
    }

    if (_voiceState == VoiceState.idle) {
      setState(() {
        _errorMessage = null;
        _partialText = '';
      });
      _voiceService.startListening();
    } else if (_voiceState == VoiceState.listening) {
      _voiceService.stopListening();
    }
  }

  Future<void> _processWithGemini(String userText) async {
    if (userText.isEmpty) return;

    setState(() {
      _voiceState = VoiceState.processing;
      _recognizedText = userText;
    });
    _pulseController.stop();
    _waveController.stop();

    try {
      // Get AI response from Gemini
      final response = await _geminiService.sendMessage(userText);

      if (!mounted) return;

      setState(() {
        _responseText = response;
        _voiceState = VoiceState.speaking;
      });

      // Save to history
      _history.add(_VoiceConversation(
        question: userText,
        answer: response,
        timestamp: DateTime.now(),
      ));

      // Speak the response using real TTS
      await _voiceService.speak(response);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _responseText = _t('ai_error_response');
        _voiceState = VoiceState.idle;
        _errorMessage = _t('ai_processing_error');
      });
    }
  }

  /// Replay the last response or a specific response via TTS
  void _replayResponse([String? text]) {
    final textToSpeak = text ?? _responseText;
    if (textToSpeak.isEmpty) return;

    HapticFeedback.lightImpact();
    setState(() => _voiceState = VoiceState.speaking);
    _voiceService.speak(textToSpeak);
  }

  void _reset() {
    _voiceService.stopListening();
    _voiceService.stopSpeaking();
    setState(() {
      _voiceState = VoiceState.idle;
      _recognizedText = '';
      _partialText = '';
      _responseText = '';
      _errorMessage = null;
      _soundLevel = 0.0;
    });
    _pulseController.stop();
    _pulseController.reset();
    _waveController.stop();
    _waveController.reset();
  }

  void _showLanguageSelector() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _LanguageSelector(
        currentLanguage: _selectedLanguage,
        onLanguageSelected: (lang) {
          setState(() => _selectedLanguage = lang);
          _voiceService.setLanguage(lang);
          Navigator.pop(context);
        },
        selectLanguageLabel: _t('select_language'),
        voiceRecognitionLabel: _t('voice_recognition_language'),
      ),
    );
  }

  void _showHistory() {
    if (_history.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_t('no_history_yet')),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _HistorySheet(
        history: _history,
        onReplay: (text) {
          Navigator.pop(context);
          _replayResponse(text);
        },
        historyLabel: _t('conversation_history'),
        replayLabel: _t('replay'),
      ),
    );
  }

  @override
  void dispose() {
    _voiceService.stopListening();
    _voiceService.stopSpeaking();
    _pulseController.dispose();
    _waveController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            _voiceService.stopListening();
            _voiceService.stopSpeaking();
            Navigator.pop(context);
          },
        ),
        title: Text(
          _t('voice_assistant'),
          style: AppTypography.titleLarge,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            onPressed: _showHistory,
            tooltip: _t('history'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Status Text
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  _getStatusText(),
                  style: AppTypography.titleMedium.copyWith(
                    color: _getStatusColor(),
                  ),
                  textAlign: TextAlign.center,
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _errorMessage!,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                // Language indicator
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    VoiceLanguages.getDisplayName(_selectedLanguage),
                    style: AppTypography.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Main Content
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Live Partial Text (while listening)
                    if (_partialText.isNotEmpty && _voiceState == VoiceState.listening)
                      _buildPartialText(),

                    // Recognized Text
                    if (_recognizedText.isNotEmpty)
                      _buildRecognizedText(),

                    const SizedBox(height: 40),

                    // Microphone Button
                    _buildMicrophoneButton(),

                    const SizedBox(height: 40),

                    // Response Text
                    if (_responseText.isNotEmpty)
                      _buildResponseText(),

                    // Waveform
                    if (_voiceState == VoiceState.listening)
                      _buildWaveform(),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Actions
          _buildBottomActions(),
        ],
      ),
    );
  }

  Widget _buildMicrophoneButton() {
    return GestureDetector(
      onTap: _isInitialized ? _toggleListening : null,
      child: AnimatedBuilder(
        animation: Listenable.merge([_pulseController, _glowController]),
        builder: (context, child) {
          final isActive = _voiceState == VoiceState.listening;
          final scale = isActive ? _pulseAnimation.value : 1.0;

          return Stack(
            alignment: Alignment.center,
            children: [
              // Outer Glow Rings
              if (isActive) ...[
                Container(
                  width: 200 * _pulseAnimation.value,
                  height: 200 * _pulseAnimation.value,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      width: 2,
                    ),
                  ),
                ),
                Container(
                  width: 160 * _pulseAnimation.value,
                  height: 160 * _pulseAnimation.value,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      width: 2,
                    ),
                  ),
                ),
              ],

              // Glow Effect
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (isActive ? AppColors.primary : AppColors.secondary)
                          .withValues(alpha: _glowAnimation.value),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
              ),

              // Main Button
              Transform.scale(
                scale: scale,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: isActive
                        ? AppGradients.primary
                        : AppGradients.premiumLegal,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (isActive ? AppColors.primary : AppColors.secondary)
                            .withValues(alpha: 0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      _voiceState == VoiceState.processing
                          ? Icons.hourglass_top_rounded
                          : _voiceState == VoiceState.speaking
                              ? Icons.volume_up_rounded
                              : Icons.mic_rounded,
                      color: isActive ? Colors.white : AppColors.textPrimary,
                      size: 48,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildWaveform() {
    return Container(
      height: 60,
      margin: const EdgeInsets.only(top: 40),
      child: AnimatedBuilder(
        animation: _waveController,
        builder: (context, child) {
          return CustomPaint(
            size: const Size(280, 60),
            painter: WaveformPainter(
              progress: _waveController.value,
              isActive: _voiceState == VoiceState.listening,
              soundLevel: _soundLevel,
            ),
          );
        },
      ),
    );
  }

  Widget _buildPartialText() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _partialText,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.primary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecognizedText() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        children: [
          const Icon(
            Icons.format_quote_rounded,
            color: AppColors.primary,
            size: 24,
          ),
          const SizedBox(height: 12),
          Text(
            _recognizedText,
            style: AppTypography.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildResponseText() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppGradients.primary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.smart_toy_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                _t('rightly_ai'),
                style: AppTypography.labelMedium.copyWith(
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              // Replay button
              GestureDetector(
                onTap: () => _replayResponse(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _voiceState == VoiceState.speaking
                            ? Icons.stop_rounded
                            : Icons.volume_up_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _voiceState == VoiceState.speaking ? _t('stop') : _t('replay'),
                        style: AppTypography.caption.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _responseText,
            style: AppTypography.bodyMedium.copyWith(
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            icon: Icons.refresh_rounded,
            label: _t('reset'),
            onTap: _reset,
          ),
          _buildActionButton(
            icon: Icons.keyboard_rounded,
            label: _t('type'),
            onTap: () => Navigator.pop(context),
          ),
          _buildActionButton(
            icon: Icons.translate_rounded,
            label: _t('language'),
            onTap: _showLanguageSelector,
          ),
          _buildActionButton(
            icon: Icons.replay_rounded,
            label: _t('replay'),
            onTap: _responseText.isNotEmpty ? () => _replayResponse() : () {},
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppShadows.soft,
            ),
            child: Center(
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 24,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTypography.caption,
          ),
        ],
      ),
    );
  }

  String _getStatusText() {
    switch (_voiceState) {
      case VoiceState.idle:
        return _isInitialized ? _t('tap_mic_to_speak') : _t('initializing');
      case VoiceState.listening:
        return _t('listening');
      case VoiceState.processing:
        return _t('getting_ai_response');
      case VoiceState.speaking:
        return _t('speaking');
    }
  }

  Color _getStatusColor() {
    switch (_voiceState) {
      case VoiceState.idle:
        return AppColors.coolGray;
      case VoiceState.listening:
        return AppColors.primary;
      case VoiceState.processing:
        return AppColors.secondary;
      case VoiceState.speaking:
        return AppColors.success;
    }
  }
}


/// Voice State Enum
enum VoiceState {
  idle,
  listening,
  processing,
  speaking,
}


/// Waveform Painter
class WaveformPainter extends CustomPainter {
  final double progress;
  final bool isActive;
  final double soundLevel;

  WaveformPainter({
    required this.progress,
    required this.isActive,
    this.soundLevel = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isActive ? AppColors.primary : AppColors.lightGray
      ..style = PaintingStyle.fill;

    final barWidth = 4.0;
    final spacing = 6.0;
    final barCount = (size.width / (barWidth + spacing)).floor();
    final centerY = size.height / 2;
    // Scale amplitude by real sound level (normalized 0-1)
    final levelFactor = isActive ? (soundLevel / 10.0).clamp(0.2, 1.0) : 0.2;

    for (int i = 0; i < barCount; i++) {
      final x = i * (barWidth + spacing);
      final amplitude = isActive
          ? (math.sin((i * 0.3) + (progress * math.pi * 2)) * 0.5 + 0.5) * levelFactor
          : 0.2;
      final height = 10 + (amplitude * (size.height - 20));

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(x + barWidth / 2, centerY),
            width: barWidth,
            height: height,
          ),
          const Radius.circular(2),
        ),
        paint..color = isActive
            ? AppColors.primary.withValues(alpha: 0.3 + (amplitude * 0.7))
            : AppColors.lightGray,
      );
    }
  }

  @override
  bool shouldRepaint(covariant WaveformPainter oldDelegate) {
    return oldDelegate.progress != progress || 
           oldDelegate.isActive != isActive ||
           oldDelegate.soundLevel != soundLevel;
  }
}


/// Voice conversation record
class _VoiceConversation {
  final String question;
  final String answer;
  final DateTime timestamp;

  _VoiceConversation({
    required this.question,
    required this.answer,
    required this.timestamp,
  });
}


/// Language Selector Bottom Sheet
class _LanguageSelector extends StatelessWidget {
  final String currentLanguage;
  final ValueChanged<String> onLanguageSelected;
  final String selectLanguageLabel;
  final String voiceRecognitionLabel;

  const _LanguageSelector({
    required this.currentLanguage,
    required this.onLanguageSelected,
    required this.selectLanguageLabel,
    required this.voiceRecognitionLabel,
  });

  @override
  Widget build(BuildContext context) {
    final languages = [
      VoiceLanguages.english,
      VoiceLanguages.hindi,
      VoiceLanguages.tamil,
      VoiceLanguages.telugu,
      VoiceLanguages.malayalam,
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.lightGray,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            selectLanguageLabel,
            style: AppTypography.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            voiceRecognitionLabel,
            style: AppTypography.caption,
          ),
          const SizedBox(height: 20),
          ...languages.map((lang) {
            final isSelected = lang == currentLanguage;
            return ListTile(
              onTap: () => onLanguageSelected(lang),
              leading: Icon(
                isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                color: isSelected ? AppColors.primary : AppColors.coolGray,
              ),
              title: Text(
                VoiceLanguages.getDisplayName(lang),
                style: AppTypography.bodyLarge.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
              trailing: isSelected
                  ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
                  : null,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              tileColor: isSelected ? AppColors.primary.withValues(alpha: 0.05) : null,
            );
          }),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}


/// History Bottom Sheet with replay
class _HistorySheet extends StatelessWidget {
  final List<_VoiceConversation> history;
  final ValueChanged<String> onReplay;
  final String historyLabel;
  final String replayLabel;

  const _HistorySheet({
    required this.history,
    required this.onReplay,
    required this.historyLabel,
    required this.replayLabel,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.3,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.lightGray,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                historyLabel,
                style: AppTypography.titleMedium,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final item = history[history.length - 1 - index]; // newest first
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: AppShadows.soft,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Timestamp
                          Text(
                            _formatTime(item.timestamp),
                            style: AppTypography.caption.copyWith(
                              color: AppColors.coolGray,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Question
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.mic_rounded, size: 16, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item.question,
                                  style: AppTypography.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 16),
                          // Answer
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.smart_toy_rounded, size: 16, color: AppColors.secondary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item.answer,
                                  style: AppTypography.bodySmall,
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Replay button
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () => onReplay(item.answer),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.volume_up_rounded,
                                      size: 14,
                                      color: AppColors.primary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      replayLabel,
                                      style: AppTypography.caption.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
