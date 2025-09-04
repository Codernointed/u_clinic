import 'package:flutter/material.dart';
import 'dart:math' as math;

class MythCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final VoidCallback? onTap;
  final Color backgroundColor;
  final double? cardWidth;

  const MythCard({
    super.key,
    required this.title,
    required this.imagePath,
    this.onTap,
    this.backgroundColor = Colors.white,
    this.cardWidth,
  });

  @override
  Widget build(BuildContext context) {
    final double effectiveCardWidth;
    if (cardWidth != null) {
      effectiveCardWidth = cardWidth!;
    } else {
      final screenWidth = MediaQuery.of(context).size.width;
      final double calculatedDefaultWidth = (screenWidth - 52) / 3;
      effectiveCardWidth = math.max(0.0, calculatedDefaultWidth);
    }

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              imagePath,
              width: effectiveCardWidth,
              height: 90, // Increased height
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: effectiveCardWidth,
                  height: 90, // Increased height
                  color: Colors.grey.shade200,
                  child: const Icon(
                    Icons.image_not_supported,
                    color: Colors.grey,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: effectiveCardWidth,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                wordSpacing: -1.0,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
