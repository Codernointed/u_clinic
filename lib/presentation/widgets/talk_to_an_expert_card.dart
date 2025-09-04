import 'package:flutter/material.dart';
import 'package:u_clinic/core/theme/app_dimensions.dart';
import 'package:u_clinic/presentation/widgets/buttons/more_button.dart';

/// A promo style card that allows users to quickly start a conversation
/// with a medical expert. Intended for display on the home page, matching
/// the Figma design specifications.
class TalkToAnExpertCard extends StatelessWidget {
  final VoidCallback onTap;

  const TalkToAnExpertCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 300,
        height: 249,
        color: Colors.white,
        child: Stack(
          clipBehavior:
              Clip.none, // Allow children to overflow for precise positioning
          children: [
            Positioned(
              left: 0,
              top: 0,
              child: Container(
                width: 118,
                height: 249,
                color: const Color(0xFF0C1549),
              ),
            ),
            Positioned(
              left: 10,
              top: 30,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4.0),
                    child: Image.asset(
                      'assets/images/expert.jpg',
                      width: 182,
                      height: 190,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 182,
                        height: 190,
                        color: Colors.grey.shade300,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacingS), // Adjusted gap
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: SizedBox(
                      width: 160,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 0), // Aligns with top of image
                          const Text(
                            'Talk to an Expert',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              height: 1.5, // 24px line-height
                              color: Colors.black,
                            ),
                          ),
                          // const SizedBox(height: AppDimensions.spacingXXS),
                          const Text(
                            'Your Mental Health matters. Are you feeling? Depressed or Anxious? Are you having Mental Breakdowns?',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              height: 1.33, // 16px line-height
                              color: Colors.black,
                            ),
                            maxLines: 5,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: AppDimensions.spacingS),
                          MoreButton(onTap: onTap, text: 'Learn More'),
                        ],
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
  }
}
