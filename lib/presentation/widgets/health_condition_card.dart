import 'package:flutter/material.dart';
import 'package:u_clinic/core/theme/app_dimensions.dart';
import 'package:u_clinic/core/theme/app_typography.dart';

class HealthConditionCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final VoidCallback? onTap;
  final Color backgroundColor;

  const HealthConditionCard({
    super.key,
    required this.title,
    required this.imagePath,
    this.onTap,
    this.backgroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 100,
            // height: 88,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              child: Image.asset(
                imagePath,
                width: 100,
                height: 120,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 88,
                    height: 88,
                    color: Colors.grey.shade200,
                    child: const Icon(
                      Icons.image_not_supported,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingXXS * 0.0005),
          Text(
            title,
            textAlign: TextAlign.left,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
