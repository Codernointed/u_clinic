import 'package:flutter/material.dart';
import 'package:u_clinic/core/routes/app_router.dart';
import 'package:u_clinic/core/theme/app_dimensions.dart';
import 'package:u_clinic/presentation/widgets/article_category_card.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Placeholder data - replace with actual data from a model/service
    final List<Map<String, String>> categories = [
      {
        'title': 'General Ailments',
        'description': 'Explore common health issues and their remedies.',
        'imagePath': 'assets/images/general_ailments.png',
        'route': AppRouter.generalAilments,
      },
      {
        'title': 'Health Tips',
        'description': 'Daily tips to help you maintain a healthy lifestyle.',
        'imagePath': 'assets/images/health_tips.png',
        'route': AppRouter.home, // Placeholder route
      },
      {
        'title': 'Inspirations',
        'description': 'Get inspired with stories and quotes for a better you.',
        'imagePath': 'assets/images/inspirations.png',
        'route': AppRouter.home, // Placeholder route
      },
      {
        'title': 'Exposing Myths',
        'description': 'Debunking common myths about health and wellness.',
        'imagePath': 'assets/images/exposing_myths.png',
        'route': AppRouter.home, // Placeholder route
      },
      {
        'title': 'Healthy Living',
        'description':
            'Learn how to live a healthier and more fulfilling life.',
        'imagePath': 'assets/images/healthy_living.png',
        'route': AppRouter.home, // Placeholder route
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.screenPaddingHorizontal,
          vertical: 20,
        ),
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(height: 13),
        itemBuilder: (context, index) {
          final category = categories[index];
          return ArticleCategoryCard(
            title: category['title']!,
            description: category['description']!,
            imagePath: category['imagePath']!,
            onReadMore: () {
              Navigator.pushNamed(context, category['route']!);
            },
          );
        },
      ),
    );
  }
}
