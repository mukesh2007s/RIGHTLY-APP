import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_typography.dart';
import '../../themes/app_theme.dart';
import '../../widgets/common/input_fields.dart';
import '../../models/models.dart';
import '../../services/gemini_service.dart';
import '../../services/voice_service.dart';
import '../../services/database_service.dart';
import '../../providers/providers.dart';
import '../../utils/app_localizations.dart';

/// Premium AI Chat Screen with Gemini AI + Voice
class ChatScreen extends StatefulWidget {
  final String? conversationId;
  final List<Map<String, dynamic>>? existingMessages;
  final String? initialMessage;
  
  const ChatScreen({
    super.key,
    this.conversationId,
    this.existingMessages,
    this.initialMessage,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with TickerProviderStateMixin {
  String get _langCode =>
      Provider.of<AppStateProvider>(context, listen: false).settings.language;
  String _t(String key) => AppLocalizations.get(key, _langCode);

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];

  final GeminiService _geminiService = GeminiService();
  final VoiceService _voiceService = VoiceService();
  final DatabaseService _dbService = DatabaseService();

  bool _isTyping = false;
  bool _isListening = false;
  bool _autoVoiceEnabled = false;
  String _partialVoiceText = '';

  @override
  void initState() {
    super.initState();

    // Initialize services
    _geminiService.initialize();
    _voiceService.initialize();

    // Setup voice callbacks for chat mic button
    _voiceService.onResult = (text) {
      if (!mounted) return;
      setState(() {
        _isListening = false;
        _partialVoiceText = '';
        _messageController.text = text;
      });
      // Auto-send the recognized speech
      _sendMessage();
    };

    _voiceService.onPartialResult = (text) {
      if (!mounted) return;
      setState(() {
        _partialVoiceText = text;
        _messageController.text = text;
      });
    };

    _voiceService.onListeningStopped = () {
      if (!mounted) return;
      setState(() => _isListening = false);
    };

    _voiceService.onError = (error) {
      if (!mounted) return;
      setState(() => _isListening = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    };

    // Add welcome message
    _addMessage(ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content:
          "Hello! I'm Rightly, your AI Legal Assistant. How can I help you today? You can ask me about:\n\n• Fundamental Rights\n• Consumer Protection\n• Labor Laws\n• Property Rights\n• And much more...",
      role: MessageRole.assistant,
      timestamp: DateTime.now(),
    ));

    // Load existing conversation if provided
    if (widget.existingMessages != null && widget.existingMessages!.isNotEmpty) {
      _loadExistingConversation();
    }

    // Auto-send initial message if provided (e.g. from Legal Topics "Ask AI")
    if (widget.initialMessage != null && widget.initialMessage!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _messageController.text = widget.initialMessage!;
        _sendMessage();
      });
    }
  }

  void _loadExistingConversation() {
    for (final chat in widget.existingMessages!.reversed) {
      final message = chat['message'] as String? ?? '';
      final isUser = (chat['is_user'] as int?) == 1;
      final createdAt = chat['created_at'] as String? ?? '';
      DateTime timestamp;
      try {
        timestamp = DateTime.parse(createdAt);
      } catch (_) {
        timestamp = DateTime.now();
      }
      _addMessage(ChatMessage(
        id: chat['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
        content: message,
        role: isUser ? MessageRole.user : MessageRole.assistant,
        timestamp: timestamp,
      ));
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addMessage(ChatMessage message) {
    setState(() {
      _messages.add(message);
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: AppAnimations.normal,
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    HapticFeedback.lightImpact();
    _messageController.clear();

    // Add user message
    _addMessage(ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: text,
      role: MessageRole.user,
      timestamp: DateTime.now(),
    ));

    // Show typing indicator
    setState(() => _isTyping = true);

    // Get real AI response from Gemini
    final rawResponse = await _geminiService.sendMessage(text);
    final response = _stripMarkdown(rawResponse);

    setState(() => _isTyping = false);

    // Add AI response
    _addMessage(ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: response,
      role: MessageRole.assistant,
      timestamp: DateTime.now(),
      isAnimating: true,
    ));

    // Auto-speak if voice toggle is enabled
    if (_autoVoiceEnabled) {
      _speakMessage(response);
    }

    // Save to database for recent conversations
    _dbService.saveChatMessage(message: text, response: response, isUser: true);
    _dbService.saveChatMessage(message: response, isUser: false);
  }

  /// Toggle voice input in chat
  void _toggleVoiceInput() {
    HapticFeedback.mediumImpact();
    if (_isListening) {
      _voiceService.stopListening();
      setState(() => _isListening = false);
    } else {
      setState(() {
        _isListening = true;
        _partialVoiceText = '';
      });
      _voiceService.startListening();
    }
  }

  /// Speak an AI response aloud (voice replay)
  void _speakMessage(String text) {
    HapticFeedback.lightImpact();
    _voiceService.speak(text);
  }

  /// Strip markdown formatting from AI responses
  String _stripMarkdown(String text) {
    return text
        .replaceAll(RegExp(r'\*\*(.+?)\*\*'), r'$1')  // **bold**
        .replaceAll(RegExp(r'\*(.+?)\*'), r'$1')       // *italic*
        .replaceAll(RegExp(r'__(.+?)__'), r'$1')       // __bold__
        .replaceAll(RegExp(r'_(.+?)_'), r'$1')         // _italic_
        .replaceAll(RegExp(r'#{1,6}\s*'), '')           // # headers
        .replaceAll(RegExp(r'`(.+?)`'), r'$1')         // `code`
        .replaceAll(RegExp(r'```[\s\S]*?```'), '')      // ```code blocks```
        .replaceAll(RegExp(r'^\s*[-*+]\s', multiLine: true), '• ')  // bullet points
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Chat Messages
          Expanded(
            child: _buildMessagesList(),
          ),

          // Typing Indicator
          if (_isTyping) _buildTypingIndicator(),

          // Input Field
          _buildInputArea(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: AppGradients.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(
                Icons.smart_toy_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _t('rightly_ai'),
                style: AppTypography.titleMedium,
              ),
              Text(
                _t('online_legal_assistant'),
                style: AppTypography.caption.copyWith(
                  color: AppColors.success,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(
            _autoVoiceEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
            color: _autoVoiceEnabled ? AppColors.primary : AppColors.coolGray,
          ),
          tooltip: _autoVoiceEnabled ? _t('voice_on') : _t('voice_off'),
          onPressed: () {
            HapticFeedback.lightImpact();
            setState(() => _autoVoiceEnabled = !_autoVoiceEnabled);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  _autoVoiceEnabled
                      ? _t('voice_explanation_on')
                      : _t('voice_explanation_off'),
                ),
                duration: const Duration(seconds: 1),
                behavior: SnackBarBehavior.floating,
                backgroundColor: _autoVoiceEnabled ? AppColors.success : AppColors.coolGray,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMessagesList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return _ChatBubble(
          message: message,
          key: ValueKey(message.id),
          onSpeak: message.role == MessageRole.assistant
              ? () => _speakMessage(message.content)
              : null,
        );
      },
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: AppGradients.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Icon(
                Icons.smart_toy_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppShadows.soft,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _TypingDot(delay: 0),
                const SizedBox(width: 4),
                _TypingDot(delay: 200),
                const SizedBox(width: 4),
                _TypingDot(delay: 400),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Voice listening indicator
            if (_isListening)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _partialVoiceText.isNotEmpty
                            ? _partialVoiceText
                            : _t('listening'),
                        style: AppTypography.caption.copyWith(
                          color: AppColors.primary,
                          fontStyle: FontStyle.italic,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      onTap: _toggleVoiceInput,
                      child: const Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ChatInputField(
              controller: _messageController,
              onSend: _sendMessage,
              onVoice: _toggleVoiceInput,
              isListening: _isListening,
              hint: AppLocalizations.get('type_message', Provider.of<AppStateProvider>(context).settings.language),
            ),
          ],
        ),
      ),
    );
  }
}


/// Animated Chat Bubble Widget
class _ChatBubble extends StatefulWidget {
  final ChatMessage message;
  final VoidCallback? onSpeak;

  const _ChatBubble({
    super.key,
    required this.message,
    this.onSpeak,
  });

  @override
  State<_ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<_ChatBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.5, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(widget.message.role == MessageRole.user ? 0.3 : -0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isUser = widget.message.role == MessageRole.user;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _opacityAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: 14,
                  left: isUser ? 48 : 0,
                  right: isUser ? 0 : 16,
                ),
                child: Row(
                  mainAxisAlignment:
                      isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (!isUser) ...[
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          gradient: AppGradients.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.smart_toy_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          gradient: isUser ? AppGradients.primary : null,
                          color: isUser ? null : Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(20),
                            topRight: const Radius.circular(20),
                            bottomLeft: Radius.circular(isUser ? 20 : 4),
                            bottomRight: Radius.circular(isUser ? 4 : 20),
                          ),
                          boxShadow: AppShadows.soft,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.message.content,
                              style: AppTypography.chatMessage.copyWith(
                                color: isUser
                                    ? Colors.white
                                    : AppColors.textPrimary,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _formatTime(widget.message.timestamp),
                                  style: AppTypography.caption.copyWith(
                                    color: isUser
                                        ? Colors.white.withValues(alpha: 0.7)
                                        : AppColors.coolGray,
                                    fontSize: 10,
                                  ),
                                ),
                                // Voice replay button for AI messages
                                if (!isUser && widget.onSpeak != null) ...[
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: widget.onSpeak,
                                    child: Icon(
                                      Icons.volume_up_rounded,
                                      size: 18,
                                      color: AppColors.primary.withValues(alpha: 0.6),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (isUser) const SizedBox(width: 8),
                  ],
                ),
              ),
            ),
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


/// Typing Indicator Dot
class _TypingDot extends StatefulWidget {
  final int delay;

  const _TypingDot({required this.delay});

  @override
  State<_TypingDot> createState() => _TypingDotState();
}

class _TypingDotState extends State<_TypingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.3 + (_animation.value * 0.7)),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}
