import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_typography.dart';
import '../../themes/app_theme.dart';
import '../../widgets/cards/feature_card.dart';
import '../chat/chat_screen.dart';
import '../voice/voice_screen.dart';
import '../call/call_screen.dart';
import '../legal/legal_topics_screen.dart';
import '../settings/settings_screen.dart';
import '../lawyer/lawyer_discovery_screen.dart';
import '../profile/user_profile_screen.dart';
import '../emergency/emergency_contacts_screen.dart';
import '../../services/database_service.dart';
import '../../providers/providers.dart';
import '../../utils/app_localizations.dart';

/// Premium Dashboard Screen
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late Animation<double> _headerSlide;
  late Animation<double> _headerOpacity;

  int _selectedIndex = 0;
  List<Map<String, dynamic>> _recentChats = [];

  @override
  void initState() {
    super.initState();

    _headerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _headerSlide = Tween<double>(begin: -30, end: 0).animate(
      CurvedAnimation(
        parent: _headerController,
        curve: Curves.easeOutCubic,
      ),
    );

    _headerOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _headerController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _headerController.forward();

    _loadRecentChats();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  @override
  void dispose() {
    _headerController.dispose();
    super.dispose();
  }

  Future<void> _loadRecentChats() async {
    try {
      final chats = await DatabaseService().getChatHistory(limit: 5);
      if (mounted) {
        setState(() => _recentChats = chats);
      }
    } catch (_) {}
  }

  Future<void> _openPastChat(Map<String, dynamic> chat) async {
    // Load all messages from this conversation timeframe
    final allChats = await DatabaseService().getChatHistory(limit: 100);
    _navigateTo(ChatScreen(existingMessages: allChats));
  }

  void _navigateTo(Widget screen) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.05, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            ),
          );
        },
        transitionDuration: AppAnimations.normal,
      ),
    ).then((_) => _loadRecentChats());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: _buildHeader(),
            ),

            // Quick Actions
            SliverToBoxAdapter(
              child: _buildQuickActions(),
            ),

            // Feature Grid
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              sliver: _buildFeatureGrid(),
            ),

            // Recent Conversations
            SliverToBoxAdapter(
              child: _buildRecentSection(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: _headerController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _headerSlide.value),
          child: Opacity(
            opacity: _headerOpacity.value,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Row(
                children: [
                  // User Avatar
                  GestureDetector(
                    onTap: () => _navigateTo(const UserProfileScreen()),
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: AppGradients.primary,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.person_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Greeting
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getGreeting(),
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.coolGray,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          AppLocalizations.get('how_can_help', Provider.of<AppStateProvider>(context).settings.language),
                          style: AppTypography.titleLarge.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Notification Bell
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: AppShadows.soft,
                    ),
                    child: Stack(
                      children: [
                        const Center(
                          child: Icon(
                            Icons.notifications_outlined,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Positioned(
                          top: 10,
                          right: 12,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: AppColors.secondary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: GestureDetector(
        onTap: () => _navigateTo(const ChatScreen()),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppGradients.primary,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              // AI Icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.get('ask_ai_assistant', Provider.of<AppStateProvider>(context).settings.language),
                      style: AppTypography.titleMedium.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.get('get_instant_answers', Provider.of<AppStateProvider>(context).settings.language),
                      style: AppTypography.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),

              // Arrow
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureGrid() {
    final lang = Provider.of<AppStateProvider>(context).settings.language;
    String _t(String key) => AppLocalizations.get(key, lang);
    
    final features = [
      FeatureData(
        title: _t('ai_chat'),
        subtitle: _t('text_conversation'),
        icon: Icons.chat_bubble_rounded,
        gradient: const LinearGradient(
          colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
        ),
        onTap: () => _navigateTo(const ChatScreen()),
      ),
      FeatureData(
        title: _t('voice'),
        subtitle: _t('speak_naturally'),
        icon: Icons.mic_rounded,
        gradient: const LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
        ),
        onTap: () => _navigateTo(const VoiceAssistantScreen()),
      ),
      FeatureData(
        title: _t('ai_call'),
        subtitle: _t('phone_assistant'),
        icon: Icons.phone_in_talk_rounded,
        gradient: const LinearGradient(
          colors: [Color(0xFF283593), Color(0xFF5C6BC0)],
        ),
        onTap: () => _navigateTo(const CallAgentScreen()),
      ),
      FeatureData(
        title: _t('legal_topics'),
        subtitle: _t('browse_laws'),
        icon: Icons.menu_book_rounded,
        gradient: const LinearGradient(
          colors: [Color(0xFFD4AF37), Color(0xFFE8D5A3)],
        ),
        iconColor: AppColors.textPrimary,
        onTap: () => _navigateTo(const LegalTopicsScreen()),
      ),
      FeatureData(
        title: _t('emergency'),
        subtitle: _t('quick_contacts'),
        icon: Icons.emergency_rounded,
        gradient: const LinearGradient(
          colors: [Color(0xFFEF4444), Color(0xFFF87171)],
        ),
        onTap: () => _navigateTo(const EmergencyContactsScreen()),
      ),
      FeatureData(
        title: _t('lawyers'),
        subtitle: _t('find_experts'),
        icon: Icons.gavel_rounded,
        gradient: const LinearGradient(
          colors: [Color(0xFF4E342E), Color(0xFF8D6E63)],
        ),
        onTap: () => _navigateTo(const LawyerDiscoveryScreen()),
      ),
      FeatureData(
        title: _t('profile'),
        subtitle: _t('your_account'),
        icon: Icons.person_rounded,
        gradient: const LinearGradient(
          colors: [Color(0xFF00897B), Color(0xFF4DB6AC)],
        ),
        onTap: () => _navigateTo(const UserProfileScreen()),
      ),
      FeatureData(
        title: _t('settings'),
        subtitle: _t('customize_app'),
        icon: Icons.settings_rounded,
        gradient: const LinearGradient(
          colors: [Color(0xFF64748B), Color(0xFF94A3B8)],
        ),
        onTap: () => _navigateTo(const SettingsScreen()),
      ),
    ];

    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return AnimationConfiguration.staggeredGrid(
            position: index,
            duration: const Duration(milliseconds: 500),
            columnCount: 2,
            child: ScaleAnimation(
              child: FadeInAnimation(
                child: FeatureCard(data: features[index]),
              ),
            ),
          );
        },
        childCount: features.length,
      ),
    );
  }

  Widget _buildRecentSection() {
    final lang = Provider.of<AppStateProvider>(context).settings.language;
    String _t(String key) => AppLocalizations.get(key, lang);
    
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _t('recent_conversations'),
                style: AppTypography.titleMedium,
              ),
              TextButton(
                onPressed: () => _navigateTo(const ChatScreen()),
                child: Text(
                  _t('see_all'),
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_recentChats.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppShadows.soft,
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.chat_bubble_outline, size: 40, color: AppColors.coolGray),
                    const SizedBox(height: 8),
                    Text(
                      _t('no_conversations'),
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.coolGray),
                    ),
                  ],
                ),
              ),
            )
          else
            ..._recentChats.take(3).map((chat) {
              final message = chat['message'] as String? ?? '';
              final createdAt = chat['created_at'] as String? ?? '';
              final isUser = (chat['is_user'] as int?) == 1;
              final timeAgo = _formatTimeAgo(createdAt);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: () => _openPastChat(chat),
                  child: _buildRecentItem(
                    message.length > 60 ? '${message.substring(0, 60)}...' : message,
                    timeAgo,
                    isUser ? Icons.chat_bubble_outline_rounded : Icons.smart_toy_outlined,
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  String _formatTimeAgo(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      final diff = DateTime.now().difference(date);
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return '';
    }
  }

  Widget _buildRecentItem(String title, String time, IconData icon) {
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
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.ultraLightGray,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: AppTypography.caption,
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
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_rounded, AppLocalizations.get('home', Provider.of<AppStateProvider>(context).settings.language)),
              _buildNavItem(1, Icons.chat_bubble_rounded, AppLocalizations.get('chat', Provider.of<AppStateProvider>(context).settings.language)),
              _buildCenterNavItem(),
              _buildNavItem(3, Icons.menu_book_rounded, AppLocalizations.get('learn', Provider.of<AppStateProvider>(context).settings.language)),
              _buildNavItem(4, Icons.settings_rounded, AppLocalizations.get('settings', Provider.of<AppStateProvider>(context).settings.language)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        HapticFeedback.selectionClick();
        // Navigate based on selected tab
        switch (index) {
          case 1:
            _navigateTo(const ChatScreen());
            break;
          case 3:
            _navigateTo(const LegalTopicsScreen());
            break;
          case 4:
            _navigateTo(const SettingsScreen());
            break;
        }
      },
      child: AnimatedContainer(
        duration: AppAnimations.fast,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.coolGray,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: isSelected ? AppColors.primary : AppColors.coolGray,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterNavItem() {
    return GestureDetector(
      onTap: () => _navigateTo(const VoiceAssistantScreen()),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: AppGradients.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.mic_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    final lang = Provider.of<AppStateProvider>(context, listen: false).settings.language;
    if (hour < 12) return AppLocalizations.get('good_morning', lang);
    if (hour < 17) return AppLocalizations.get('good_afternoon', lang);
    return AppLocalizations.get('good_evening', lang);
  }
}


/// Feature Data Model
class FeatureData {
  final String title;
  final String subtitle;
  final IconData icon;
  final Gradient gradient;
  final Color? iconColor;
  final VoidCallback onTap;

  FeatureData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    this.iconColor,
    required this.onTap,
  });
}
