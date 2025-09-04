import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';

class HealthEducationScreen extends StatefulWidget {
  const HealthEducationScreen({super.key});

  @override
  State<HealthEducationScreen> createState() => _HealthEducationScreenState();
}

class _HealthEducationScreenState extends State<HealthEducationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = 'All';
  String _searchQuery = '';

  final List<String> _categories = [
    'All',
    'General Health',
    'Mental Health',
    'Nutrition',
    'Exercise',
    'Preventive Care',
    'Student Health',
    'Campus Wellness',
  ];

  final List<HealthArticle> _articles = [
    HealthArticle(
      title: 'Managing Stress During Exam Season',
      summary:
          'Learn effective strategies to cope with academic stress and maintain mental well-being.',
      category: 'Mental Health',
      author: 'Dr. Sarah Johnson',
      publishDate: DateTime.now().subtract(const Duration(days: 2)),
      readTime: '5 min read',
      imageUrl: 'assets/images/stress_management.jpg',
      isFeatured: true,
    ),
    HealthArticle(
      title: 'Healthy Eating on Campus',
      summary:
          'Tips for maintaining a balanced diet while living in university accommodation.',
      category: 'Nutrition',
      author: 'Dr. Michael Chen',
      publishDate: DateTime.now().subtract(const Duration(days: 3)),
      readTime: '7 min read',
      imageUrl: 'assets/images/healthy_eating.jpg',
      isFeatured: false,
    ),
    HealthArticle(
      title: 'Exercise Routines for Busy Students',
      summary:
          'Quick and effective workout routines that fit into your busy academic schedule.',
      category: 'Exercise',
      author: 'Dr. Emily Davis',
      publishDate: DateTime.now().subtract(const Duration(days: 4)),
      readTime: '6 min read',
      imageUrl: 'assets/images/exercise.jpg',
      isFeatured: false,
    ),
    HealthArticle(
      title: 'Preventing Common Cold and Flu',
      summary:
          'Essential preventive measures to stay healthy during the cold and flu season.',
      category: 'Preventive Care',
      author: 'Dr. Robert Wilson',
      publishDate: DateTime.now().subtract(const Duration(days: 5)),
      readTime: '4 min read',
      imageUrl: 'assets/images/cold_prevention.jpg',
      isFeatured: false,
    ),
    HealthArticle(
      title: 'Sleep Hygiene for Better Academic Performance',
      summary:
          'How quality sleep can improve your studies and overall well-being.',
      category: 'General Health',
      author: 'Dr. Lisa Thompson',
      publishDate: DateTime.now().subtract(const Duration(days: 6)),
      readTime: '8 min read',
      imageUrl: 'assets/images/sleep_hygiene.jpg',
      isFeatured: false,
    ),
  ];

  final List<HealthTip> _healthTips = [
    HealthTip(
      title: 'Stay Hydrated',
      description:
          'Drink at least 8 glasses of water daily to maintain good health.',
      icon: Icons.water_drop,
      color: AppColors.cardConsultation,
    ),
    HealthTip(
      title: 'Take Regular Breaks',
      description: 'Take a 5-minute break every hour during study sessions.',
      icon: Icons.timer,
      color: AppColors.cardAppointment,
    ),
    HealthTip(
      title: 'Practice Good Posture',
      description:
          'Maintain proper posture while studying to prevent back pain.',
      icon: Icons.accessibility,
      color: AppColors.cardMedicalRecord,
    ),
    HealthTip(
      title: 'Eat Regular Meals',
      description: 'Don\'t skip meals - maintain regular eating patterns.',
      icon: Icons.restaurant,
      color: AppColors.cardPrescription,
    ),
  ];

  final List<HealthEvent> _events = [
    HealthEvent(
      title: 'Mental Health Awareness Week',
      description:
          'Join us for a week of activities focused on mental health and well-being.',
      date: DateTime.now().add(const Duration(days: 7)),
      time: '9:00 AM - 5:00 PM',
      location: 'Main Campus Hall',
      isRegistrationRequired: true,
      maxParticipants: 100,
    ),
    HealthEvent(
      title: 'Nutrition Workshop',
      description: 'Learn about healthy eating habits and meal planning.',
      date: DateTime.now().add(const Duration(days: 14)),
      time: '2:00 PM - 4:00 PM',
      location: 'Health Center',
      isRegistrationRequired: false,
      maxParticipants: 50,
    ),
    HealthEvent(
      title: 'Fitness Challenge',
      description: 'Participate in our month-long fitness challenge.',
      date: DateTime.now().add(const Duration(days: 21)),
      time: '6:00 AM - 8:00 PM',
      location: 'Sports Complex',
      isRegistrationRequired: true,
      maxParticipants: 200,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Health Education',
          style: AppTypography.heading2.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Articles'),
            Tab(text: 'Tips'),
            Tab(text: 'Events'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildArticlesTab(),
                _buildTipsTab(),
                _buildEventsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingM),
      child: Column(
        children: [
          // Search Bar
          TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search health topics...',
              prefixIcon: const Icon(
                Icons.search,
                color: AppColors.textSecondary,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                borderSide: BorderSide(color: AppColors.divider),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                borderSide: BorderSide(color: AppColors.primary),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingM),
          // Category Filter
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(width: AppDimensions.spacingS),
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;
                return FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = selected ? category : 'All';
                    });
                  },
                  backgroundColor: Colors.white,
                  selectedColor: AppColors.primaryLight,
                  labelStyle: AppTypography.bodySmall.copyWith(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                  side: BorderSide(
                    color: isSelected ? AppColors.primary : AppColors.divider,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticlesTab() {
    final filteredArticles = _articles.where((article) {
      final matchesCategory =
          _selectedCategory == 'All' || article.category == _selectedCategory;
      final matchesSearch =
          _searchQuery.isEmpty ||
          article.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          article.summary.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (filteredArticles.any((article) => article.isFeatured))
            _buildFeaturedArticle(
              filteredArticles.firstWhere((article) => article.isFeatured),
            ),
          if (filteredArticles.any((article) => article.isFeatured))
            const SizedBox(height: AppDimensions.spacingL),
          _buildSection(
            'Latest Articles',
            Icons.article,
            filteredArticles
                .where((article) => !article.isFeatured)
                .map((article) => _buildArticleCard(article))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedArticle(HealthArticle article) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingL),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryLight, AppColors.primary],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimensions.spacingS),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                ),
                child: const Text(
                  'FEATURED',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                article.readTime,
                style: AppTypography.bodySmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingM),
          Text(
            article.title,
            style: AppTypography.heading3.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingS),
          Text(
            article.summary,
            style: AppTypography.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingM),
          Row(
            children: [
              Text(
                'By ${article.author}',
                style: AppTypography.bodySmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              const Spacer(),
              Text(
                _formatDate(article.publishDate),
                style: AppTypography.bodySmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildArticleCard(HealthArticle article) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppDimensions.radiusM),
                topRight: Radius.circular(AppDimensions.radiusM),
              ),
            ),
            child: Center(
              child: Icon(Icons.article, size: 48, color: AppColors.primary),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.spacingS,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusS,
                        ),
                      ),
                      child: Text(
                        article.category,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      article.readTime,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.spacingS),
                Text(
                  article.title,
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingS),
                Text(
                  article.summary,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppDimensions.spacingM),
                Row(
                  children: [
                    Text(
                      'By ${article.author}',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _formatDate(article.publishDate),
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            'Daily Health Tips',
            Icons.lightbulb,
            _healthTips.map((tip) => _buildTipCard(tip)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard(HealthTip tip) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingM),
      padding: const EdgeInsets.all(AppDimensions.spacingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: tip.color,
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
            child: Icon(tip.icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: AppDimensions.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tip.title,
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingS),
                Text(
                  tip.description,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            'Upcoming Health Events',
            Icons.event,
            _events.map((event) => _buildEventCard(event)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(HealthEvent event) {
    final daysUntil = event.date.difference(DateTime.now()).inDays;
    final isToday = daysUntil == 0;
    final isTomorrow = daysUntil == 1;

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.spacingM),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppDimensions.radiusM),
                topRight: Radius.circular(AppDimensions.radiusM),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.event, color: AppColors.primary, size: 24),
                const SizedBox(width: AppDimensions.spacingS),
                Text(
                  isToday
                      ? 'Today'
                      : isTomorrow
                      ? 'Tomorrow'
                      : 'In $daysUntil days',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (event.isRegistrationRequired)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacingS,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warning,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusS,
                      ),
                    ),
                    child: Text(
                      'Registration Required',
                      style: AppTypography.bodySmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: AppTypography.heading4.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingS),
                Text(
                  event.description,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingM),
                _buildEventDetail(Icons.access_time, event.time),
                _buildEventDetail(Icons.location_on, event.location),
                _buildEventDetail(
                  Icons.people,
                  '${event.maxParticipants} participants',
                ),
                const SizedBox(height: AppDimensions.spacingM),
                Row(
                  children: [
                    if (event.isRegistrationRequired)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _registerForEvent(event),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Register Now'),
                        ),
                      )
                    else
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _viewEventDetails(event),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: BorderSide(color: AppColors.primary),
                          ),
                          child: const Text('View Details'),
                        ),
                      ),
                    const SizedBox(width: AppDimensions.spacingM),
                    IconButton(
                      onPressed: () => _addToCalendar(event),
                      icon: const Icon(
                        Icons.calendar_today,
                        color: AppColors.primary,
                      ),
                      tooltip: 'Add to Calendar',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventDetail(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 16),
          const SizedBox(width: AppDimensions.spacingS),
          Text(
            text,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(width: AppDimensions.spacingS),
            Text(
              title,
              style: AppTypography.heading3.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingM),
        ...children,
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _registerForEvent(HealthEvent event) {
    // TODO: Implement event registration
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Registration for ${event.title} coming soon!'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _viewEventDetails(HealthEvent event) {
    // TODO: Implement event details view
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Event details for ${event.title} coming soon!'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _addToCalendar(HealthEvent event) {
    // TODO: Implement calendar integration
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${event.title} to calendar'),
        backgroundColor: AppColors.success,
      ),
    );
  }
}

class HealthArticle {
  final String title;
  final String summary;
  final String category;
  final String author;
  final DateTime publishDate;
  final String readTime;
  final String imageUrl;
  final bool isFeatured;

  HealthArticle({
    required this.title,
    required this.summary,
    required this.category,
    required this.author,
    required this.publishDate,
    required this.readTime,
    required this.imageUrl,
    required this.isFeatured,
  });
}

class HealthTip {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  HealthTip({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

class HealthEvent {
  final String title;
  final String description;
  final DateTime date;
  final String time;
  final String location;
  final bool isRegistrationRequired;
  final int maxParticipants;

  HealthEvent({
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.location,
    required this.isRegistrationRequired,
    required this.maxParticipants,
  });
}
