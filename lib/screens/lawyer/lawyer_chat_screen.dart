import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_typography.dart';
import '../../themes/app_theme.dart';
import '../../models/lawyer_model.dart';
import '../../services/database_service.dart';

/// Predefined lawyer responses for demo purposes
class LawyerDemoResponses {
  static const Map<String, List<Map<String, String>>> _responses = {
    'Criminal Law': [
      {
        'keywords': 'bail,arrest,police,fir',
        'response': 'If you or your family member has been arrested, remember these key rights:\n\n1. Right to know the grounds of arrest\n2. Right to inform a relative/friend\n3. Right to be produced before a magistrate within 24 hours\n4. Right to consult a lawyer\n\nI can help you file a bail application. Please share the FIR details and I will guide you through the process.',
      },
      {
        'keywords': 'theft,robbery,stolen',
        'response': 'For theft/robbery cases, you should:\n\n1. File an FIR immediately at the nearest police station\n2. Preserve any evidence (CCTV footage, witnesses)\n3. Note the estimated value of stolen items\n\nI can assist you in filing a complaint and pursuing the case. Would you like me to draft a complaint?',
      },
    ],
    'Family Law': [
      {
        'keywords': 'divorce,separation,marriage',
        'response': 'I understand divorce is a difficult decision. Here are your options:\n\n1. Mutual Consent Divorce - Both parties agree (6-18 months)\n2. Contested Divorce - One party files (1-5 years)\n\nKey considerations:\n• Child custody arrangements\n• Alimony/maintenance\n• Property division\n\nI can guide you through the process. What specific aspect would you like to discuss?',
      },
      {
        'keywords': 'custody,child,children',
        'response': 'Child custody matters are decided based on the "best interest of the child" principle.\n\nTypes of custody:\n• Physical custody\n• Legal custody\n• Joint custody\n\nFactors considered by courts:\n• Age of the child\n• Financial stability of parents\n• Emotional bond with each parent\n• Child\'s preference (if above certain age)\n\nI can help you build a strong custody case. Please share more details about your situation.',
      },
    ],
    'Civil Law': [
      {
        'keywords': 'property,land,dispute',
        'response': 'For property disputes, I recommend:\n\n1. Verify all property documents (title deed, sale deed)\n2. Check for encumbrances at the sub-registrar office\n3. Review property tax receipts\n\nCommon remedies:\n• Filing a civil suit for declaration\n• Injunction to prevent illegal possession\n• Partition suit for joint property\n\nPlease share your property documents for a detailed analysis.',
      },
    ],
    'Cyber Law': [
      {
        'keywords': 'online,fraud,scam,hack',
        'response': 'For cyber crime incidents:\n\n1. Report immediately at cybercrime.gov.in\n2. File a complaint at the nearest cyber police station\n3. Preserve all evidence (screenshots, transaction details)\n\nUnder IT Act 2000:\n• Section 66C - Identity theft\n• Section 66D - Cheating by personation\n• Section 43 - Unauthorized access\n\nI can help you draft a detailed cyber crime complaint. Please share the incident details.',
      },
    ],
    'Consumer Rights': [
      {
        'keywords': 'refund,defective,product,complaint',
        'response': 'Under the Consumer Protection Act 2019, you have the right to:\n\n1. File complaint in consumer forum\n2. Seek refund/replacement of defective product\n3. Claim compensation for loss/suffering\n\nForum jurisdiction:\n• Up to ₹1 Crore - District Forum\n• ₹1-10 Crore - State Commission\n• Above ₹10 Crore - National Commission\n\nI can help you draft a consumer complaint. Please share the purchase details and issue description.',
      },
    ],
  };

  static String getResponse(String specialization, String userMessage) {
    final lowerMessage = userMessage.toLowerCase();
    
    // Check specialization-specific responses
    final specResponses = _responses[specialization];
    if (specResponses != null) {
      for (final entry in specResponses) {
        final keywords = entry['keywords']!.split(',');
        for (final keyword in keywords) {
          if (lowerMessage.contains(keyword.trim())) {
            return entry['response']!;
          }
        }
      }
    }
    
    // Check all specializations for matching keywords
    for (final specEntry in _responses.entries) {
      for (final entry in specEntry.value) {
        final keywords = entry['keywords']!.split(',');
        for (final keyword in keywords) {
          if (lowerMessage.contains(keyword.trim())) {
            return entry['response']!;
          }
        }
      }
    }

    // Generic responses based on common words
    if (lowerMessage.contains('hello') || lowerMessage.contains('hi') || lowerMessage.contains('hey')) {
      return 'Hello! Thank you for reaching out. I am here to help you with your legal concerns regarding $specialization. Please describe your situation and I will provide you with the best guidance.';
    }
    
    if (lowerMessage.contains('fee') || lowerMessage.contains('charge') || lowerMessage.contains('cost') || lowerMessage.contains('price')) {
      return 'My consultation fees are as follows:\n\n• Initial Consultation: ₹500 (first 30 minutes)\n• Detailed Case Review: ₹2,000\n• Court Representation: Varies by case complexity\n\nI offer a free initial assessment for first-time clients. Would you like to schedule a consultation?';
    }
    
    if (lowerMessage.contains('time') || lowerMessage.contains('available') || lowerMessage.contains('appointment') || lowerMessage.contains('schedule')) {
      return 'My office hours are:\n\n• Monday to Friday: 10:00 AM - 6:00 PM\n• Saturday: 10:00 AM - 2:00 PM\n• Sunday: By appointment only\n\nYou can book an appointment by calling my office or through this chat. When would be convenient for you?';
    }
    
    if (lowerMessage.contains('thank') || lowerMessage.contains('thanks')) {
      return 'You\'re welcome! I\'m glad I could help. If you have any more questions about $specialization or need further legal assistance, don\'t hesitate to reach out. Best wishes!';
    }

    if (lowerMessage.contains('help') || lowerMessage.contains('need') || lowerMessage.contains('problem') || lowerMessage.contains('issue')) {
      return 'I understand you need help. As a $specialization specialist, I can assist you with:\n\n• Legal consultation and advice\n• Document drafting and review\n• Court representation\n• Filing petitions and complaints\n\nPlease describe your specific legal issue in detail so I can provide you with the best possible guidance.';
    }
    
    // Default response
    return 'Thank you for your message. As a $specialization specialist, I will review your query carefully.\n\nTo provide you with the most accurate legal advice, could you please share more details about:\n\n1. The specific legal issue you are facing\n2. Any relevant dates or timelines\n3. Documents you may have\n\nI will get back to you with a detailed response shortly.';
  }
}

/// Lawyer Chat Screen — Chat with a specific lawyer
class LawyerChatScreen extends StatefulWidget {
  final LawyerModel lawyer;

  const LawyerChatScreen({super.key, required this.lawyer});

  @override
  State<LawyerChatScreen> createState() => _LawyerChatScreenState();
}

class _LawyerChatScreenState extends State<LawyerChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final DatabaseService _dbService = DatabaseService();
  final List<Map<String, dynamic>> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadChatHistory() async {
    final history = await _dbService.getLawyerChatHistory(widget.lawyer.id);
    if (mounted) {
      setState(() {
        _messages.clear();
        if (history.isEmpty) {
          // Add welcome message
          _messages.add({
            'message': 'Hello! I am ${widget.lawyer.name}, specializing in ${widget.lawyer.specialization}. How can I assist you with your legal matter today?',
            'is_user': false,
            'created_at': DateTime.now().toIso8601String(),
          });
        } else {
          _messages.addAll(history);
        }
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
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
    setState(() {
      _messages.add({
        'message': text,
        'is_user': true,
        'created_at': DateTime.now().toIso8601String(),
      });
    });
    _scrollToBottom();

    // Save user message to DB
    await _dbService.saveLawyerChatMessage(
      lawyerId: widget.lawyer.id,
      message: text,
      isUser: true,
    );

    // Show typing indicator
    setState(() => _isTyping = true);

    // Simulate lawyer thinking delay
    await Future.delayed(const Duration(milliseconds: 1500));

    // Get predefined response
    final response = LawyerDemoResponses.getResponse(
      widget.lawyer.specialization,
      text,
    );

    setState(() {
      _isTyping = false;
      _messages.add({
        'message': response,
        'is_user': false,
        'created_at': DateTime.now().toIso8601String(),
      });
    });
    _scrollToBottom();

    // Save lawyer response to DB
    await _dbService.saveLawyerChatMessage(
      lawyerId: widget.lawyer.id,
      message: response,
      isUser: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(child: _buildMessagesList()),
          if (_isTyping) _buildTypingIndicator(),
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
              gradient: LinearGradient(
                colors: [AppColors.legalGold, AppColors.legalGold.withOpacity(0.7)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                widget.lawyer.name.split(' ').last[0].toUpperCase(),
                style: AppTypography.titleMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.lawyer.name,
                  style: AppTypography.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  widget.lawyer.isOnline ? 'Online' : 'Offline',
                  style: AppTypography.caption.copyWith(
                    color: widget.lawyer.isOnline ? AppColors.success : AppColors.coolGray,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final msg = _messages[index];
        final isUser = msg['is_user'] == true || msg['is_user'] == 1;
        final message = msg['message'] as String? ?? '';
        final createdAt = msg['created_at'] as String? ?? '';
        
        return _buildChatBubble(message, isUser, createdAt);
      },
    );
  }

  Widget _buildChatBubble(String message, bool isUser, String createdAt) {
    String time = '';
    try {
      final dt = DateTime.parse(createdAt);
      time = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {}

    return Padding(
      padding: EdgeInsets.only(
        bottom: 14,
        left: isUser ? 48 : 0,
        right: isUser ? 0 : 16,
      ),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.legalGold, AppColors.legalGold.withOpacity(0.7)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  widget.lawyer.name.split(' ').last[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
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
                    message,
                    style: AppTypography.chatMessage.copyWith(
                      color: isUser ? Colors.white : AppColors.textPrimary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    time,
                    style: AppTypography.caption.copyWith(
                      color: isUser
                          ? Colors.white.withOpacity(0.7)
                          : AppColors.coolGray,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
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
              gradient: LinearGradient(
                colors: [AppColors.legalGold, AppColors.legalGold.withOpacity(0.7)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                widget.lawyer.name.split(' ').last[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
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
                Text(
                  'typing',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.coolGray,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(width: 4),
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.legalGold,
                  ),
                ),
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
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border),
                ),
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Type your message...',
                    hintStyle: AppTypography.bodyMedium.copyWith(
                      color: AppColors.coolGray,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: AppGradients.primary,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
