import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_typography.dart';
import '../../services/database_service.dart';
import '../../providers/providers.dart';
import '../../utils/app_localizations.dart';

/// Emergency Contacts Screen — Quick dial for emergency services
class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({super.key});

  @override
  State<EmergencyContactsScreen> createState() => _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;

  final DatabaseService _dbService = DatabaseService();
  List<Map<String, dynamic>> _contacts = [];
  bool _isLoading = true;

  String get _langCode =>
      Provider.of<AppStateProvider>(context, listen: false).settings.language;
  String _t(String key) => AppLocalizations.get(key, _langCode);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
    _loadContacts();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadContacts() async {
    try {
      final contacts = await _dbService.getEmergencyContacts();
      if (mounted) {
        setState(() {
          _contacts = contacts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _makeCall(String number) async {
    HapticFeedback.mediumImpact();
    final uri = Uri(scheme: 'tel', path: number);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${_t('could_not_dial')} $number'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  IconData _getCategoryIcon(String? category) {
    switch (category) {
      case 'emergency':
        return Icons.emergency_rounded;
      case 'women':
        return Icons.woman_rounded;
      case 'children':
        return Icons.child_care_rounded;
      case 'rights':
        return Icons.gavel_rounded;
      case 'medical':
        return Icons.local_hospital_rounded;
      case 'cyber':
        return Icons.computer_rounded;
      case 'consumer':
        return Icons.shopping_bag_rounded;
      case 'seniors':
        return Icons.elderly_rounded;
      default:
        return Icons.phone_rounded;
    }
  }

  Color _getCategoryColor(String? category) {
    switch (category) {
      case 'emergency':
        return const Color(0xFFEF4444);
      case 'women':
        return const Color(0xFFEC4899);
      case 'children':
        return const Color(0xFF8B5CF6);
      case 'rights':
        return const Color(0xFFD4AF37);
      case 'medical':
        return const Color(0xFF10B981);
      case 'cyber':
        return const Color(0xFF3B82F6);
      case 'consumer':
        return const Color(0xFFF59E0B);
      case 'seniors':
        return const Color(0xFF6366F1);
      default:
        return AppColors.primary;
    }
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
              const Color(0xFFEF4444),
              const Color(0xFFEF4444).withOpacity(0.85),
              AppColors.background,
            ],
            stops: const [0.0, 0.3, 0.3],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeIn,
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 16),
                _buildEmergencyBanner(),
                const SizedBox(height: 12),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _buildContactsList(),
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
            _t('emergency_contacts'),
            style: AppTypography.headlineSmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.emergency_rounded, color: Color(0xFFEF4444), size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _t('national_emergency'),
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFEF4444),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _t('life_threatening_emergency'),
                    style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => _makeCall('112'),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEF4444), Color(0xFFF87171)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.call, color: Colors.white, size: 24),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: _contacts.length,
      itemBuilder: (context, index) {
        final contact = _contacts[index];
        final category = contact['category'] as String?;
        final color = _getCategoryColor(category);
        final icon = _getCategoryIcon(category);

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contact['name'] as String,
                        style: AppTypography.titleSmall.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        contact['description'] as String? ?? '',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        contact['number'] as String,
                        style: AppTypography.labelMedium.copyWith(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => _makeCall(contact['number'] as String),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color, color.withOpacity(0.7)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.call, color: Colors.white, size: 22),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
