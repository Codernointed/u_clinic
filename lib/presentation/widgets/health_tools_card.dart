import 'package:flutter/material.dart';
import 'package:u_clinic/core/extensions/string_extensions.dart';
import 'package:u_clinic/core/theme/app_typography.dart';

class HealthToolsCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final VoidCallback? onTap;

  const HealthToolsCard({
    super.key,
    required this.title,
    required this.imagePath,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 108,
        height: 144,
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(48.0),
                child: Image.asset(
                  imagePath,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(48.0),
                      ),
                      child: const Icon(
                        Icons.image_not_supported,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: 100,
                height: 32,
                child: Center(
                  child: Text(
                    title.toTitleCase(),
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      height:
                          1.14, // Corresponds to 16px line-height for 14px font size
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
