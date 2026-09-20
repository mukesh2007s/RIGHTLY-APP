import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_typography.dart';
import '../../themes/app_theme.dart';
import '../../widgets/common/input_fields.dart';
import '../../providers/providers.dart';
import '../../utils/app_localizations.dart';
import '../chat/chat_screen.dart';

/// Legal Topics Screen with Comprehensive Indian Law Knowledge
class LegalTopicsScreen extends StatefulWidget {
  const LegalTopicsScreen({super.key});

  @override
  State<LegalTopicsScreen> createState() => _LegalTopicsScreenState();
}

class _LegalTopicsScreenState extends State<LegalTopicsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _selectedCategoryIndex = 0;

  String get _langCode =>
      Provider.of<AppStateProvider>(context, listen: false).settings.language;
  String _t(String key) => AppLocalizations.get(key, _langCode);

  final List<LegalCategory> _categories = [
    LegalCategory(
      id: 'fundamental',
      name: 'Fundamental Rights',
      icon: Icons.verified_user_rounded,
      color: AppColors.primary,
      topics: [
        LegalTopic(
          title: 'Right to Equality',
          subtitle: 'Articles 14-18',
          description:
              'Equality before law, prohibition of discrimination on grounds of religion, race, caste, sex or place of birth, equality of opportunity in public employment, abolition of untouchability, and abolition of titles.',
          articles: ['Article 14', 'Article 15', 'Article 16', 'Article 17', 'Article 18'],
        ),
        LegalTopic(
          title: 'Right to Freedom',
          subtitle: 'Articles 19-22',
          description:
              'Protection of certain rights regarding freedom of speech, assembly, association, movement, residence, and profession. Also includes protection in respect of conviction for offences.',
          articles: ['Article 19', 'Article 20', 'Article 21', 'Article 22'],
        ),
        LegalTopic(
          title: 'Right against Exploitation',
          subtitle: 'Articles 23-24',
          description:
              'Prohibition of traffic in human beings and forced labour. Prohibition of employment of children in factories, mines, and other hazardous employment.',
          articles: ['Article 23', 'Article 24'],
        ),
        LegalTopic(
          title: 'Right to Freedom of Religion',
          subtitle: 'Articles 25-28',
          description:
              'Freedom of conscience and free profession, practice and propagation of religion. Freedom to manage religious affairs.',
          articles: ['Article 25', 'Article 26', 'Article 27', 'Article 28'],
        ),
        LegalTopic(
          title: 'Cultural & Educational Rights',
          subtitle: 'Articles 29-30',
          description:
              'Protection of interests of minorities. Right of minorities to establish and administer educational institutions.',
          articles: ['Article 29', 'Article 30'],
        ),
        LegalTopic(
          title: 'Right to Constitutional Remedies',
          subtitle: 'Article 32',
          description:
              'Right to move the Supreme Court for enforcement of fundamental rights. The Supreme Court has power to issue writs for enforcement.',
          articles: ['Article 32'],
        ),
      ],
    ),
    LegalCategory(
      id: 'criminal',
      name: 'Criminal Law',
      icon: Icons.gavel_rounded,
      color: AppColors.error,
      topics: [
        LegalTopic(
          title: 'Rights During Arrest',
          subtitle: 'CrPC Section 41-60',
          description:
              'Right to know the grounds of arrest, right to inform a relative, right to be produced before magistrate within 24 hours, right to consult a lawyer, and right against illegal detention.',
          articles: ['Section 41', 'Section 50', 'Section 55', 'Section 56', 'Section 57'],
        ),
        LegalTopic(
          title: 'Bail Provisions',
          subtitle: 'CrPC Section 436-450',
          description:
              'Provisions for bail in bailable and non-bailable offences. Anticipatory bail, bail in case of illness of accused, and appellate bail.',
          articles: ['Section 436', 'Section 437', 'Section 438', 'Section 439'],
        ),
        LegalTopic(
          title: 'FIR and Police Complaint',
          subtitle: 'CrPC Section 154-157',
          description:
              'Information relating to commission of cognizable offence. Procedure for investigation, examination of complainant and witnesses.',
          articles: ['Section 154', 'Section 155', 'Section 156', 'Section 157'],
        ),
        LegalTopic(
          title: 'Rights of Accused',
          subtitle: 'Constitution & CrPC',
          description:
              'Right to fair trial, presumption of innocence, right to remain silent, right against double jeopardy, and right against self-incrimination.',
          articles: ['Article 20', 'Article 21', 'Article 22'],
        ),
      ],
    ),
    LegalCategory(
      id: 'consumer',
      name: 'Consumer Rights',
      icon: Icons.shopping_bag_rounded,
      color: AppColors.success,
      topics: [
        LegalTopic(
          title: 'Right to Safety',
          subtitle: 'Consumer Protection Act 2019',
          description:
              'Protection against goods and services hazardous to life and property. Right to be protected against marketing of goods which are dangerous.',
          articles: ['Section 2(9)'],
        ),
        LegalTopic(
          title: 'Right to Information',
          subtitle: 'Consumer Protection Act 2019',
          description:
              'Right to be informed about quality, quantity, potency, purity, standard and price of goods or services.',
          articles: ['Section 2(9)'],
        ),
        LegalTopic(
          title: 'Right to Choose',
          subtitle: 'Consumer Protection Act 2019',
          description:
              'Right to be assured access to variety of goods and services at competitive prices. Right to choose from available options.',
          articles: ['Section 2(9)'],
        ),
        LegalTopic(
          title: 'Right to be Heard',
          subtitle: 'Consumer Protection Act 2019',
          description:
              'Right to be heard and to be assured that consumer interests will receive due consideration at appropriate forums.',
          articles: ['Section 2(9)'],
        ),
        LegalTopic(
          title: 'Right to Redressal',
          subtitle: 'Consumer Protection Act 2019',
          description:
              'Right to seek redressal against unfair trade practices or restrictive trade practices or unscrupulous exploitation.',
          articles: ['Section 35', 'Section 38', 'Section 47'],
        ),
      ],
    ),
    LegalCategory(
      id: 'women',
      name: 'Women\'s Rights',
      icon: Icons.female_rounded,
      color: AppColors.accent,
      topics: [
        LegalTopic(
          title: 'Protection from Domestic Violence',
          subtitle: 'DV Act 2005',
          description:
              'Protection against domestic violence, right to residence, protection orders, residence orders, monetary reliefs, and custody orders.',
          articles: ['Section 3', 'Section 17', 'Section 18', 'Section 19', 'Section 20'],
        ),
        LegalTopic(
          title: 'Sexual Harassment at Workplace',
          subtitle: 'POSH Act 2013',
          description:
              'Prevention, prohibition and redressal of sexual harassment at workplace. Establishment of Internal Complaints Committee.',
          articles: ['Section 2', 'Section 3', 'Section 4', 'Section 9'],
        ),
        LegalTopic(
          title: 'Maternity Benefits',
          subtitle: 'Maternity Benefit Act 1961',
          description:
              '26 weeks of maternity leave, nursing breaks, no discharge during pregnancy, work from home option, and crèche facility.',
          articles: ['Section 5', 'Section 11', 'Section 11A', 'Section 12'],
        ),
        LegalTopic(
          title: 'Dowry Prohibition',
          subtitle: 'Dowry Prohibition Act 1961',
          description:
              'Penalty for giving or taking dowry, penalty for demanding dowry, and ban on dowry advertisements.',
          articles: ['Section 3', 'Section 4', 'Section 4A'],
        ),
      ],
    ),
    LegalCategory(
      id: 'property',
      name: 'Property Law',
      icon: Icons.home_rounded,
      color: AppColors.legalGold,
      topics: [
        LegalTopic(
          title: 'Transfer of Property',
          subtitle: 'TPA 1882',
          description:
              'Rules relating to transfer of property by act of parties. Sale, mortgage, lease, exchange, and gift of immovable property.',
          articles: ['Section 5', 'Section 54', 'Section 58', 'Section 105', 'Section 118'],
        ),
        LegalTopic(
          title: 'Tenant Rights',
          subtitle: 'Rent Control Acts',
          description:
              'Protection against eviction, fair rent determination, right to essential services, right to subletting with consent.',
          articles: ['Varies by State'],
        ),
        LegalTopic(
          title: 'Registration of Property',
          subtitle: 'Registration Act 1908',
          description:
              'Compulsory registration of documents, procedure for registration, time limit, and effects of non-registration.',
          articles: ['Section 17', 'Section 18', 'Section 23', 'Section 49'],
        ),
        LegalTopic(
          title: 'Succession Laws',
          subtitle: 'Hindu/Muslim/Christian Laws',
          description:
              'Rules of intestate and testamentary succession for different religions. Distribution of property among heirs.',
          articles: ['Hindu Succession Act', 'Indian Succession Act'],
        ),
      ],
    ),
    LegalCategory(
      id: 'labor',
      name: 'Labor Laws',
      icon: Icons.work_rounded,
      color: Colors.orange,
      topics: [
        LegalTopic(
          title: 'Minimum Wages',
          subtitle: 'Minimum Wages Act 1948',
          description:
              'Fixing of minimum rates of wages, procedure for fixing, payment of minimum wages, and maintenance of registers.',
          articles: ['Section 3', 'Section 4', 'Section 5', 'Section 20'],
        ),
        LegalTopic(
          title: 'Payment of Wages',
          subtitle: 'Payment of Wages Act 1936',
          description:
              'Responsibility for payment of wages, time of payment, deductions from wages, and claims arising out of deductions.',
          articles: ['Section 3', 'Section 5', 'Section 7', 'Section 15'],
        ),
        LegalTopic(
          title: 'Gratuity',
          subtitle: 'Payment of Gratuity Act 1972',
          description:
              'Payment of gratuity to employees after 5 years of continuous service. Calculation formula and maximum limit.',
          articles: ['Section 4', 'Section 4A', 'Section 7'],
        ),
        LegalTopic(
          title: 'Provident Fund',
          subtitle: 'EPF Act 1952',
          description:
              'Employees\' Provident Fund scheme, contribution rates, withdrawal rules, and pension scheme.',
          articles: ['Section 5', 'Section 6', 'Section 7', 'Section 7A'],
        ),
      ],
    ),
  ];

  List<LegalTopic> get _filteredTopics {
    final category = _categories[_selectedCategoryIndex];
    if (_searchQuery.isEmpty) {
      return category.topics;
    }
    return category.topics.where((topic) {
      return topic.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          topic.subtitle.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          topic.description.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() => _selectedCategoryIndex = _tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            
            // Search Bar
            _buildSearchBar(),
            
            // Category Tabs
            _buildCategoryTabs(),
            
            // Topics List
            Expanded(
              child: _buildTopicsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _t('legal_knowledge'),
                style: AppTypography.titleLarge,
              ),
              Text(
                _t('indian_laws_rights'),
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.balance_rounded,
              color: AppColors.primary,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AnimatedSearchField(
        controller: _searchController,
        hintText: _t('search_legal_topics'),
        onChanged: (value) {
          setState(() => _searchQuery = value);
        },
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      height: 100,
      margin: const EdgeInsets.only(top: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = index == _selectedCategoryIndex;
          
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _selectedCategoryIndex = index);
              _tabController.animateTo(index);
            },
            child: AnimatedContainer(
              duration: AppAnimations.fast,
              width: 85,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? category.color.withValues(alpha: 0.15) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? category.color : AppColors.border,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected ? AppShadows.soft : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    category.icon,
                    color: isSelected ? category.color : AppColors.textSecondary,
                    size: 28,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    category.name.split(' ').first,
                    style: AppTypography.labelSmall.copyWith(
                      color: isSelected ? category.color : AppColors.textSecondary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopicsList() {
    final topics = _filteredTopics;
    
    if (topics.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              _t('no_topics_found'),
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              _t('try_different_search'),
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      );
    }
    
    return AnimationLimiter(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: topics.length,
        itemBuilder: (context, index) {
          final topic = topics[index];
          final category = _categories[_selectedCategoryIndex];
          
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: AppAnimations.medium,
            child: SlideAnimation(
              verticalOffset: 30,
              child: FadeInAnimation(
                child: _buildTopicCard(topic, category.color),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopicCard(LegalTopic topic, Color accentColor) {
    return GestureDetector(
      onTap: () => _showTopicDetail(topic, accentColor),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppShadows.soft,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.article_rounded,
                color: accentColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    topic.title,
                    style: AppTypography.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    topic.subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: accentColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    topic.description,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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

  void _showTopicDetail(LegalTopic topic, Color accentColor) {
    HapticFeedback.lightImpact();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _TopicDetailSheet(
        topic: topic,
        accentColor: accentColor,
        saveLabel: _t('save'),
        askAiLabel: _t('ask_ai'),
        relatedLabel: _t('related_articles'),
        onSave: () {
          Navigator.pop(sheetContext);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_t('topic_saved')),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        },
        onAskAi: () {
          Navigator.pop(sheetContext);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatScreen(
                initialMessage:
                    'Tell me about ${topic.title} (${topic.subtitle}). ${topic.description}',
              ),
            ),
          );
        },
      ),
    );
  }
}


/// Topic Detail Bottom Sheet
class _TopicDetailSheet extends StatelessWidget {
  final LegalTopic topic;
  final Color accentColor;
  final String saveLabel;
  final String askAiLabel;
  final String relatedLabel;
  final VoidCallback onSave;
  final VoidCallback onAskAi;

  const _TopicDetailSheet({
    required this.topic,
    required this.accentColor,
    required this.saveLabel,
    required this.askAiLabel,
    required this.relatedLabel,
    required this.onSave,
    required this.onAskAi,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                
                // Header
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          topic.subtitle,
                          style: AppTypography.labelSmall.copyWith(
                            color: accentColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        topic.title,
                        style: AppTypography.headlineSmall,
                      ),
                    ],
                  ),
                ),
                
                // Description
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    topic.description,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Related Articles
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        relatedLabel,
                        style: AppTypography.titleSmall,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: topic.articles.map((article) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Text(
                              article,
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.textPrimary,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Action Buttons
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: onSave,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: accentColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.bookmark_outline_rounded,
                                  color: accentColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  saveLabel,
                                  style: AppTypography.labelMedium.copyWith(
                                    color: accentColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: onAskAi,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              gradient: AppGradients.primaryGradient,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.chat_bubble_outline_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  askAiLabel,
                                  style: AppTypography.labelMedium.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
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


/// Legal Category Model
class LegalCategory {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final List<LegalTopic> topics;

  LegalCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.topics,
  });
}


/// Legal Topic Model
class LegalTopic {
  final String title;
  final String subtitle;
  final String description;
  final List<String> articles;

  LegalTopic({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.articles,
  });
}
