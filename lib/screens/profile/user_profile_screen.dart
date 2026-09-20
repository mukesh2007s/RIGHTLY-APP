import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_typography.dart';
import '../../providers/providers.dart';
import '../../utils/app_localizations.dart';

/// User Profile Screen — View and edit user profile
class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;

  String get _langCode =>
      Provider.of<AppStateProvider>(context, listen: false).settings.language;
  String _t(String key) => AppLocalizations.get(key, _langCode);

  bool _isEditing = false;
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  String _selectedLanguage = 'English';
  final List<String> _languages = [
    'English',
    'Hindi',
    'Tamil',
    'Telugu',
    'Kannada',
    'Malayalam',
    'Bengali',
    'Gujarati',
    'Marathi',
    'Punjabi',
    'Urdu',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();

    _nameController = TextEditingController(text: 'User');
    _emailController = TextEditingController(text: 'user@example.com');
    _phoneController = TextEditingController(text: '+91 XXXXX XXXXX');

    _loadSavedProfile();
  }

  /// Load saved profile from SharedPreferences
  Future<void> _loadSavedProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString('profile_name');
    final savedEmail = prefs.getString('profile_email');
    final savedPhone = prefs.getString('profile_phone');
    final savedLang = prefs.getString('profile_language');

    if (mounted) {
      setState(() {
        if (savedName != null && savedName.isNotEmpty) _nameController.text = savedName;
        if (savedEmail != null && savedEmail.isNotEmpty) _emailController.text = savedEmail;
        if (savedPhone != null && savedPhone.isNotEmpty) _phoneController.text = savedPhone;
        if (savedLang != null && _languages.contains(savedLang)) _selectedLanguage = savedLang;
      });
    }
  }

  /// Save profile to SharedPreferences
  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_name', _nameController.text.trim());
    await prefs.setString('profile_email', _emailController.text.trim());
    await prefs.setString('profile_phone', _phoneController.text.trim());
    await prefs.setString('profile_language', _selectedLanguage);
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() => _isEditing = !_isEditing);
    if (!_isEditing) {
      // Actually save the profile data
      _saveProfile();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_t('profile_updated')),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(_t('logout')),
        content: Text(_t('logout_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(_t('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (r) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(_t('logout'), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary,
              AppColors.primary.withOpacity(0.8),
              AppColors.background,
            ],
            stops: const [0.0, 0.35, 0.35],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeIn,
            child: Column(
              children: [
                // Header
                _buildHeader(),
                const SizedBox(height: 20),
                // Profile Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        _buildProfileAvatar(),
                        const SizedBox(height: 24),
                        _buildInfoCard(),
                        const SizedBox(height: 16),
                        _buildPreferencesCard(),
                        const SizedBox(height: 16),
                        _buildStatsCard(),
                        const SizedBox(height: 16),
                        _buildLogoutButton(),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          ),
          Text(
            _t('my_profile'),
            style: AppTypography.headlineSmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: _toggleEdit,
            icon: Icon(
              _isEditing ? Icons.check : Icons.edit,
              color: AppColors.legalGold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileAvatar() {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.legalGold,
                    AppColors.legalGold.withOpacity(0.7),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.legalGold.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: const Icon(Icons.person, size: 50, color: Colors.white),
            ),
            if (_isEditing)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          _nameController.text,
          style: AppTypography.headlineSmall.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          _emailController.text,
          style: AppTypography.bodyMedium.copyWith(color: Colors.white60),
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _t('personal_information'),
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoField(
            icon: Icons.person_outline,
            label: _t('full_name'),
            controller: _nameController,
          ),
          const Divider(height: 24),
          _buildInfoField(
            icon: Icons.email_outlined,
            label: _t('email'),
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
          ),
          const Divider(height: 24),
          _buildInfoField(
            icon: Icons.phone_outlined,
            label: _t('phone'),
            controller: _phoneController,
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoField({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 2),
              _isEditing
                  ? TextField(
                      controller: controller,
                      keyboardType: keyboardType,
                      style: AppTypography.bodyMedium,
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        border: InputBorder.none,
                      ),
                    )
                  : Text(
                      controller.text,
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPreferencesCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _t('preferences'),
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.legalGold.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.language, color: AppColors.legalGold, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _t('preferred_language'),
                      style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 2),
                    DropdownButton<String>(
                      value: _selectedLanguage,
                      isExpanded: true,
                      underline: const SizedBox(),
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                      items: _languages
                          .map((lang) =>
                              DropdownMenuItem(value: lang, child: Text(lang)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedLanguage = val);
                          context.read<AppStateProvider>().setLanguage(val);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.accent],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _t('activity_stats'),
            style: AppTypography.titleMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatTile(_t('chats'), '12', Icons.chat_bubble_outline),
              const SizedBox(width: 12),
              _buildStatTile(_t('calls'), '5', Icons.call_outlined),
              const SizedBox(width: 12),
              _buildStatTile(_t('topics'), '8', Icons.menu_book_outlined),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatTile(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.legalGold, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTypography.headlineSmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: _handleLogout,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.red.shade400),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        icon: Icon(Icons.logout, color: Colors.red.shade400),
        label: Text(
          _t('logout'),
          style: AppTypography.labelLarge.copyWith(
            color: Colors.red.shade400,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
