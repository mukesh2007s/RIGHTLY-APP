import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_typography.dart';
import '../../providers/lawyer_provider.dart';
import '../../providers/providers.dart';
import '../../models/lawyer_model.dart';
import '../../widgets/buttons/gradient_button.dart';
import '../../utils/app_localizations.dart';
import 'lawyer_chat_screen.dart';

/// Lawyer Profile Screen — Detailed lawyer view with contact & rating
class LawyerProfileScreen extends StatefulWidget {
  final String lawyerId;
  const LawyerProfileScreen({super.key, required this.lawyerId});

  @override
  State<LawyerProfileScreen> createState() => _LawyerProfileScreenState();
}

class _LawyerProfileScreenState extends State<LawyerProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;

  String get _langCode =>
      Provider.of<AppStateProvider>(context, listen: false).settings.language;
  String _t(String key) => AppLocalizations.get(key, _langCode);
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LawyerProvider>().selectLawyer(widget.lawyerId);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _makePhoneCall(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone.replaceAll(' ', ''));
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _sendEmail(String email) async {
    final uri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {'subject': 'Legal Consultation Request - Rightly App'},
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _showReviewDialog() {
    double selectedRating = 5.0;
    final reviewController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _t('rate_this_lawyer'),
                    style: AppTypography.titleLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _t('share_experience'),
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Star Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return GestureDetector(
                        onTap: () {
                          setSheetState(
                              () => selectedRating = index + 1.0);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            index < selectedRating
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            size: 44,
                            color: index < selectedRating
                                ? Colors.amber.shade600
                                : Colors.grey.shade300,
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getRatingLabel(selectedRating),
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.legalGold,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Review Text
                  TextField(
                    controller: reviewController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: _t('write_review_hint'),
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: GradientButton(
                      text: _t('submit_review'),
                      onPressed: () async {
                        final success = await context
                            .read<LawyerProvider>()
                            .submitReview(
                              lawyerId: widget.lawyerId,
                              userId: 'user_001',
                              userName: 'User',
                              rating: selectedRating,
                              reviewText: reviewController.text,
                            );
                        if (mounted) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(success
                                  ? _t('review_submitted')
                                  : _t('already_reviewed')),
                              backgroundColor: success
                                  ? Colors.green.shade700
                                  : Colors.orange.shade700,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        }
                      },
                      borderRadius: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _getRatingLabel(double rating) {
    if (rating >= 5) return _t('excellent');
    if (rating >= 4) return _t('very_good');
    if (rating >= 3) return _t('good');
    if (rating >= 2) return _t('fair');
    return _t('poor');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<LawyerProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading || provider.selectedLawyer == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          final lawyer = provider.selectedLawyer!;
          return FadeTransition(
            opacity: _fadeIn,
            child: CustomScrollView(
              slivers: [
                _buildSliverAppBar(lawyer),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildContactButtons(lawyer),
                        const SizedBox(height: 20),
                        _buildInfoSection(lawyer),
                        const SizedBox(height: 20),
                        _buildAboutSection(lawyer),
                        const SizedBox(height: 20),
                        _buildLanguagesSection(lawyer),
                        const SizedBox(height: 20),
                        _buildReviewsSection(provider.reviews),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: FloatingActionButton.extended(
          onPressed: _showReviewDialog,
          backgroundColor: AppColors.primary,
          icon: const Icon(Icons.rate_review, color: Colors.white),
          label: Text(
            _t('write_review'),
            style: AppTypography.labelMedium.copyWith(color: Colors.white),
          ),
          elevation: 8,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildSliverAppBar(LawyerModel lawyer) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: AppColors.primary,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, const Color(0xFF0D47A1)],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Hero(
                  tag: 'lawyer_avatar_${lawyer.id}',
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.legalGold,
                          AppColors.legalGold.withOpacity(0.7),
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.legalGold.withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        lawyer.name.split(' ').last[0].toUpperCase(),
                        style: AppTypography.displaySmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      lawyer.name,
                      style: AppTypography.titleLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (lawyer.isVerified) ...[
                      const SizedBox(width: 8),
                      Icon(Icons.verified, color: AppColors.legalGold, size: 22),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  lawyer.specialization,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.legalGold,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildBadge(Icons.star, lawyer.rating.toStringAsFixed(1)),
                    const SizedBox(width: 16),
                    _buildBadge(Icons.work_outline, '${lawyer.experience} yrs'),
                    const SizedBox(width: 16),
                    _buildBadge(Icons.reviews, '${lawyer.reviewCount} reviews'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.legalGold),
          const SizedBox(width: 6),
          Text(
            text,
            style: AppTypography.labelSmall.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildContactButtons(LawyerModel lawyer) {
    return Row(
      children: [
        Expanded(
          child: _buildContactBtn(
            icon: Icons.call,
            label: _t('call'),
            color: Colors.green,
            onTap: () => _makePhoneCall(lawyer.phone),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildContactBtn(
            icon: Icons.email,
            label: _t('email'),
            color: AppColors.accent,
            onTap: () => _sendEmail(lawyer.email),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildContactBtn(
            icon: Icons.chat,
            label: _t('chat'),
            color: AppColors.primary,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => LawyerChatScreen(lawyer: lawyer),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactBtn({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(LawyerModel lawyer) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.location_on_outlined, _t('office'),
              lawyer.officeAddress),
          const Divider(height: 24),
          _buildInfoRow(Icons.phone_outlined, _t('phone'), lawyer.phone),
          const Divider(height: 24),
          _buildInfoRow(Icons.email_outlined, _t('email'), lawyer.email),
          const Divider(height: 24),
          _buildInfoRow(Icons.circle,
              _t('status'), lawyer.isOnline ? _t('online') : _t('offline')),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
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

  Widget _buildAboutSection(LawyerModel lawyer) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _t('about'),
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            lawyer.bio ?? 'No bio available.',
            style: AppTypography.bodyMedium.copyWith(
              height: 1.6,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguagesSection(LawyerModel lawyer) {
    final languages = lawyer.languages;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _t('languages'),
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: languages.map((lang) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary.withOpacity(0.15)),
                ),
                child: Text(
                  lang,
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection(List<ReviewModel> reviews) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_t('reviews')} (${reviews.length})',
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 12),
        if (reviews.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(Icons.rate_review_outlined,
                    size: 40, color: Colors.grey.shade400),
                const SizedBox(height: 8),
                Text(
                  _t('no_reviews_yet'),
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          )
        else
          ...reviews.map((review) => _buildReviewCard(review)),
      ],
    );
  }

  Widget _buildReviewCard(ReviewModel review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    review.userName[0].toUpperCase(),
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: AppTypography.labelLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _formatDate(review.createdAt),
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < review.rating ? Icons.star : Icons.star_outline,
                    size: 16,
                    color: Colors.amber.shade600,
                  ),
                ),
              ),
            ],
          ),
          if (review.reviewText != null && review.reviewText!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              review.reviewText!,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
