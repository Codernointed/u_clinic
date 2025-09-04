import 'package:flutter/material.dart';
import 'package:u_clinic/core/theme/app_colors.dart';
import 'package:u_clinic/core/theme/app_typography.dart';

class InspirationCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String explanation;
  final VoidCallback? onTap;

  const InspirationCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.explanation,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 32,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.asset(
                imagePath,
                width: 120,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: Text(
                        explanation,
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.normal,
                          color: AppColors.textPrimary.withValues(alpha: 0.75),
                          height:
                              1.14, // Corresponds to line-height: 16px for font-size: 14px
                        ),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
