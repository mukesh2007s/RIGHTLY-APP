import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_typography.dart';
import '../../providers/lawyer_provider.dart';
import '../../providers/providers.dart';
import '../../models/lawyer_model.dart';
import '../../utils/app_localizations.dart';

/// Lawyer Discovery Screen — Browse, search, and filter lawyers
class LawyerDiscoveryScreen extends StatefulWidget {
  const LawyerDiscoveryScreen({super.key});

  @override
  State<LawyerDiscoveryScreen> createState() => _LawyerDiscoveryScreenState();
}

class _LawyerDiscoveryScreenState extends State<LawyerDiscoveryScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final _searchController = TextEditingController();
  bool _showFilters = false;

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
    _controller.forward();

    // Load lawyers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LawyerProvider>().loadLawyers();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
            stops: const [0.0, 0.22, 0.22],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),
              const SizedBox(height: 12),
              // Search Bar
              _buildSearchBar(),
              const SizedBox(height: 12),
              // Filter Chips
              _buildFilterChips(),
              const SizedBox(height: 8),
              // Lawyer List
              Expanded(child: _buildLawyerList()),
            ],
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _t('lawyer_connect'),
                style: AppTypography.headlineSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _t('find_legal_expert'),
                style: AppTypography.bodySmall.copyWith(color: Colors.white60),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.balance, color: AppColors.legalGold, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (query) {
            context.read<LawyerProvider>().searchLawyers(query);
          },
          decoration: InputDecoration(
            hintText: _t('search_lawyer'),
            hintStyle: TextStyle(color: Colors.grey.shade400),
            prefixIcon: Icon(Icons.search, color: AppColors.primary),
            suffixIcon: IconButton(
              icon: Icon(
                _showFilters ? Icons.filter_list_off : Icons.filter_list,
                color: AppColors.legalGold,
              ),
              onPressed: () => setState(() => _showFilters = !_showFilters),
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Consumer<LawyerProvider>(
      builder: (context, provider, _) {
        if (!_showFilters) return const SizedBox.shrink();

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildChip(
                      'All',
                      provider.activeFilter == null,
                      () => provider.filterBySpecialization(null),
                    ),
                    ...provider.specializations.map(
                      (spec) => _buildChip(
                        spec,
                        provider.activeFilter == spec,
                        () => provider.filterBySpecialization(spec),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChip(String label, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: AppTypography.labelMedium.copyWith(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLawyerList() {
    return Consumer<LawyerProvider>(builder: (context, provider, _) {
      if (provider.isLoading) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        );
      }

      final lawyers = provider.filteredLawyers;

      if (lawyers.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                _t('no_lawyers_found'),
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _t('try_adjusting_search'),
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        itemCount: lawyers.length,
        itemBuilder: (context, index) {
          return _buildLawyerCard(lawyers[index], index);
        },
      );
    });
  }

  Widget _buildLawyerCard(LawyerModel lawyer, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 100)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, '/lawyer-profile',
              arguments: lawyer.id);
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar
                Hero(
                  tag: 'lawyer_avatar_${lawyer.id}',
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.accent,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        lawyer.name.split(' ').last[0].toUpperCase(),
                        style: AppTypography.headlineSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              lawyer.name,
                              style: AppTypography.titleSmall.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (lawyer.isVerified)
                            Icon(Icons.verified, size: 18, color: AppColors.accent),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        lawyer.specialization,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.legalGold,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          // Rating
                          Icon(Icons.star, size: 16, color: Colors.amber.shade600),
                          const SizedBox(width: 4),
                          Text(
                            lawyer.rating.toStringAsFixed(1),
                            style: AppTypography.labelMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            ' (${lawyer.reviewCount})',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Experience
                          Icon(Icons.work_outline, size: 14, color: AppColors.textTertiary),
                          const SizedBox(width: 4),
                          Text(
                            '${lawyer.experience}y',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Location
                          Icon(Icons.location_on_outlined, size: 14, color: AppColors.textTertiary),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              lawyer.location,
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Online indicator
                if (lawyer.isOnline)
                  Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.only(left: 8),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.4),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
