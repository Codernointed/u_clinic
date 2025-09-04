import 'package:flutter/material.dart';
import 'package:u_clinic/core/theme/app_typography.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeMoreTap;

  const SectionHeader({super.key, required this.title, this.onSeeMoreTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTypography.heading3),
        if (onSeeMoreTap != null)
          GestureDetector(
            onTap: onSeeMoreTap,
            child: Row(
              children: [
                Text(
                  'See all',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.normal,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.arrow_forward_ios, size: 10),
              ],
            ),
          ),
      ],
    );
  }
}
