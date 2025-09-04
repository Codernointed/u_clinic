import 'package:flutter/material.dart';
import 'package:u_clinic/core/theme/app_typography.dart';

class ArticleCategoryCard extends StatelessWidget {
  final String title;
  final String description;
  final String imagePath;
  final VoidCallback? onReadMore;

  const ArticleCategoryCard({
    super.key,
    required this.title,
    required this.description,
    required this.imagePath,
    this.onReadMore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 372,
      height: 140,
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(18),
            blurRadius: 32,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4.0),
            child: Image.asset(
              imagePath,
              width: 120,
              height: 120,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 120,
                height: 120,
                color: Colors.grey.shade200,
                child: const Icon(
                  Icons.image_not_supported,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyLarge.copyWith(
                    color: const Color(0xFF3E3232),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Text(
                    description,
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF3E3232).withAlpha(191),
                      height: 1.14, // 16px line-height / 14px font-size
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 200,
                  height: 36,
                  child: ElevatedButton(
                    onPressed: onReadMore,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D2D2D),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      elevation: 4,
                      shadowColor: const Color(0xFF2D2D2D).withAlpha(64),
                    ),
                    child: Text(
                      'Read More',
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
