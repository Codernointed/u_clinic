import 'package:flutter/material.dart';
import 'package:u_clinic/core/routes/app_router.dart';
import 'package:u_clinic/core/theme/app_dimensions.dart';
import 'package:u_clinic/presentation/widgets/appbar/custom_app_bar.dart';
import 'package:u_clinic/presentation/widgets/inspiration_card.dart';

class InspirationsScreen extends StatelessWidget {
  const InspirationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Placeholder data - replace with actual data from a model/service
    final List<Map<String, String>> inspirations = List.generate(
      10,
      (index) => {
        'title': 'Inspiration Title ${index + 1}',
        'explanation':
            'This is a short, inspiring message to brighten your day and offer a fresh perspective.',
        'imagePath': 'assets/images/inspo.jpg', // Using a placeholder
        'route': AppRouter.articleDetails,
      },
    );

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: CAppBar(
          title: 'Inspirations',
          onBack: () => Navigator.pop(context),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.screenPaddingHorizontal,
          vertical: 20,
        ),
        itemCount: inspirations.length,
        separatorBuilder: (context, index) => const SizedBox(height: 13),
        itemBuilder: (context, index) {
          final inspiration = inspirations[index];
          return InspirationCard(
            title: inspiration['title']!,
            explanation: inspiration['explanation']!,
            imagePath: inspiration['imagePath']!,
            onTap: () {
              Navigator.pushNamed(context, inspiration['route']!);
            },
          );
        },
      ),
    );
  }
}
