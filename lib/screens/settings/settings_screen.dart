import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_typography.dart';
import '../../themes/app_theme.dart';
import '../../services/database_service.dart';
import '../../providers/providers.dart';
import '../../utils/app_localizations.dart';

/// Premium Settings Screen with Comprehensive App Configuration
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Settings State
  String _selectedLanguage = 'English';
  String _selectedAIMode = 'Balanced';
  bool _offlineMode = false;
  bool _notifications = true;
  bool _voiceFeedback = true;
  bool _hapticFeedback = true;
  final bool _darkMode = false;
  double _voiceSpeed = 1.0;
  double _fontSize = 1.0;

  final List<String> _languages = [
    'English',
    'தமிழ் (Tamil)',
    'हிंदी (Hindi)',
    'తెలుగు (Telugu)',
    'മലയാളം (Malayalam)',
  ];

  String get _langCode {
    final provider = Provider.of<AppStateProvider>(context, listen: false);
    return provider.settings.language;
  }

  /// Shortcut for localized strings
  String _t(String key) => AppLocalizations.get(key, _langCode);

  @override
  void initState() {
    super.initState();
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    final savedLang = await DatabaseService().getPreference('app_language');
    if (savedLang != null && mounted) {
      // Find the display name for saved language code
      for (final lang in _languages) {
        if (AppLocalizations.getLanguageCode(lang) == savedLang) {
          setState(() => _selectedLanguage = lang);
          break;
        }
      }
      Provider.of<AppStateProvider>(context, listen: false).setLanguage(savedLang);
    }
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
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _t('settings'),
          style: AppTypography.titleLarge,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            _buildProfileSection(),
            
            const SizedBox(height: 24),
            
            // Language Settings
            _buildSectionTitle(_t('language_voice')),
            _buildLanguageSelector(),
            const SizedBox(height: 12),
            _buildVoiceSpeedSlider(),
            
            const SizedBox(height: 24),
            
            // AI Settings
            _buildSectionTitle(_t('ai_configuration')),
            _buildAIModeSelector(),
            const SizedBox(height: 12),
            _buildSwitchTile(
              icon: Icons.wifi_off_rounded,
              title: _t('offline_mode'),
              subtitle: _t('use_local_ai'),
              value: _offlineMode,
              onChanged: (value) => setState(() => _offlineMode = value),
            ),
            
            const SizedBox(height: 24),
            
            // Appearance
            _buildSectionTitle(_t('appearance')),
            _buildFontSizeSlider(),
            const SizedBox(height: 12),
            _buildSwitchTile(
              icon: Icons.dark_mode_rounded,
              title: _t('dark_mode'),
              subtitle: _t('coming_soon'),
              value: _darkMode,
              onChanged: null, // Disabled for now
            ),
            
            const SizedBox(height: 24),
            
            // Notifications & Feedback
            _buildSectionTitle(_t('notifications_feedback')),
            _buildSwitchTile(
              icon: Icons.notifications_rounded,
              title: _t('push_notifications'),
              subtitle: _t('legal_updates_tips'),
              value: _notifications,
              onChanged: (value) => setState(() => _notifications = value),
            ),
            const SizedBox(height: 12),
            _buildSwitchTile(
              icon: Icons.record_voice_over_rounded,
              title: _t('voice_feedback'),
              subtitle: _t('ai_speaks_answers'),
              value: _voiceFeedback,
              onChanged: (value) => setState(() => _voiceFeedback = value),
            ),
            const SizedBox(height: 12),
            _buildSwitchTile(
              icon: Icons.vibration_rounded,
              title: _t('haptic_feedback'),
              subtitle: _t('vibration_interactions'),
              value: _hapticFeedback,
              onChanged: (value) => setState(() => _hapticFeedback = value),
            ),
            
            const SizedBox(height: 24),
            
            // Data & Privacy
            _buildSectionTitle(_t('data_privacy')),
            _buildActionTile(
              icon: Icons.delete_sweep_rounded,
              title: _t('clear_chat_history'),
              subtitle: _t('delete_all_conversations'),
              onTap: () => _showClearHistoryDialog(),
              isDestructive: true,
            ),
            
            const SizedBox(height: 24),
            
            // About
            _buildSectionTitle(_t('about')),
            _buildActionTile(
              icon: Icons.info_outline_rounded,
              title: _t('about_rightly'),
              subtitle: 'Version 1.0.0',
              onTap: () => _showAboutDialog(),
            ),
            const SizedBox(height: 12),
            _buildActionTile(
              icon: Icons.star_rounded,
              title: _t('rate_app'),
              subtitle: _t('share_feedback'),
              onTap: () {},
            ),
            const SizedBox(height: 12),
            _buildActionTile(
              icon: Icons.help_outline_rounded,
              title: _t('help_support'),
              subtitle: _t('get_assistance'),
              onTap: () {},
            ),
            
            const SizedBox(height: 32),
            
            // Sign Out
            _buildSignOutButton(),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppGradients.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.medium,
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.person_rounded,
                size: 32,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _t('guest_user'),
                  style: AppTypography.titleMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _t('tap_to_sign_in'),
                  style: AppTypography.bodySmall.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: AppTypography.titleSmall.copyWith(
          color: AppColors.textSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.translate_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_t('app_language'), style: AppTypography.bodyMedium),
                    Text(
                      _selectedLanguage,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _languages.map((lang) {
              final isSelected = lang == _selectedLanguage;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedLanguage = lang);
                  // Save to provider and DB
                  final langCode = AppLocalizations.getLanguageCode(lang);
                  Provider.of<AppStateProvider>(context, listen: false).setLanguage(langCode);
                  DatabaseService().setPreference('app_language', langCode);
                },
                child: AnimatedContainer(
                  duration: AppAnimations.fast,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                    ),
                  ),
                  child: Text(
                    lang,
                    style: AppTypography.labelMedium.copyWith(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceSpeedSlider() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.speed_rounded,
                  color: AppColors.success,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(_t('voice_speed'), style: AppTypography.bodyMedium),
              const Spacer(),
              Text(
                '${_voiceSpeed.toStringAsFixed(1)}x',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.border,
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withValues(alpha: 0.2),
            ),
            child: Slider(
              value: _voiceSpeed,
              min: 0.5,
              max: 2.0,
              divisions: 6,
              onChanged: (value) {
                HapticFeedback.selectionClick();
                setState(() => _voiceSpeed = value);
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_t('slow'), style: AppTypography.caption),
              Text(_t('normal'), style: AppTypography.caption),
              Text(_t('fast'), style: AppTypography.caption),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAIModeSelector() {
    final aiModes = [
      {
        'name': _t('concise'),
        'key': 'Concise',
        'description': _t('short_direct'),
        'icon': Icons.flash_on_rounded,
      },
      {
        'name': _t('balanced'),
        'key': 'Balanced',
        'description': _t('detailed_examples'),
        'icon': Icons.balance_rounded,
      },
      {
        'name': _t('comprehensive'),
        'key': 'Comprehensive',
        'description': _t('in_depth'),
        'icon': Icons.menu_book_rounded,
      },
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.legalGold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.psychology_rounded,
                  color: AppColors.legalGold,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(_t('ai_response_mode'), style: AppTypography.bodyMedium),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(aiModes.length, (index) {
            final mode = aiModes[index];
            final isSelected = mode['key'] == _selectedAIMode;
            
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedAIMode = mode['key'] as String);
              },
              child: AnimatedContainer(
                duration: AppAnimations.fast,
                margin: EdgeInsets.only(bottom: index < aiModes.length - 1 ? 8 : 0),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      mode['icon'] as IconData,
                      color: isSelected ? AppColors.primary : AppColors.textSecondary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mode['name'] as String,
                            style: AppTypography.bodyMedium.copyWith(
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                          Text(
                            mode['description'] as String,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.primary,
                        size: 24,
                      ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFontSizeSlider() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.format_size_rounded,
                  color: AppColors.accent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(_t('font_size'), style: AppTypography.bodyMedium),
              const Spacer(),
              Text(
                _getFontSizeLabel(),
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text('A', style: AppTypography.bodySmall),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: AppColors.accent,
                    inactiveTrackColor: AppColors.border,
                    thumbColor: AppColors.accent,
                    overlayColor: AppColors.accent.withValues(alpha: 0.2),
                  ),
                  child: Slider(
                    value: _fontSize,
                    min: 0.8,
                    max: 1.4,
                    divisions: 3,
                    onChanged: (value) {
                      HapticFeedback.selectionClick();
                      setState(() => _fontSize = value);
                    },
                  ),
                ),
              ),
              Text('A', style: AppTypography.titleLarge),
            ],
          ),
        ],
      ),
    );
  }

  String _getFontSizeLabel() {
    if (_fontSize <= 0.8) return _t('small');
    if (_fontSize <= 1.0) return _t('normal');
    if (_fontSize <= 1.2) return _t('large');
    return _t('extra_large');
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) {
    final isEnabled = onChanged != null;
    
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
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (isEnabled ? AppColors.primary : AppColors.textTertiary).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: isEnabled ? AppColors.primary : AppColors.textTertiary,
              size: 20,
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
                    color: isEnabled ? AppColors.textPrimary : AppColors.textTertiary,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeTrackColor: AppColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
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
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (isDestructive ? AppColors.error : AppColors.primary).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isDestructive ? AppColors.error : AppColors.primary,
                size: 20,
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
                      color: isDestructive ? AppColors.error : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignOutButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        _showSignOutDialog();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.logout_rounded,
              color: AppColors.error,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              _t('sign_out'),
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.error,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearHistoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.delete_sweep_rounded, color: AppColors.error),
            const SizedBox(width: 8),
            Text(_t('clear_chat_history')),
          ],
        ),
        content: Text(
          _t('clear_history_confirm'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_t('cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await DatabaseService().clearChatHistory();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_t('chat_cleared')),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: Text(_t('delete')),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(_t('sign_out')),
        content: Text(_t('sign_out_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_t('cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              // Clear login state
              await DatabaseService().setPreference('is_logged_in', 'false');
              if (mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil('/auth', (route) => false);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: Text(_t('sign_out')),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: AppGradients.primaryGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Icon(
                  Icons.balance_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Rightly',
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'AI Legal Awareness Assistant',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Version 1.0.0',
              style: AppTypography.labelMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '© 2024 Rightly. All rights reserved.',
              style: AppTypography.caption.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
