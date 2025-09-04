import 'package:flutter/material.dart';
import 'package:u_clinic/core/theme/app_colors.dart';
import 'package:u_clinic/core/theme/app_dimensions.dart';
import 'package:u_clinic/core/theme/app_typography.dart';

class AppSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  const AppSearchBar({super.key, this.controller, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        height: 38,
        decoration: BoxDecoration(
          // color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(AppDimensions.cardBorderRadius),
        ),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          decoration: InputDecoration(
            fillColor: AppColors.surfaceLight,
            hintText: 'Search',
            hintStyle: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            suffixIcon: Padding(
              padding: const EdgeInsets.all(AppDimensions.spacingS),
              child: Icon(Icons.search, color: AppColors.textSecondary),
            ),
            suffixIconConstraints: const BoxConstraints(
              maxHeight: 40,
              maxWidth: 40,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              vertical: AppDimensions.spacingS,
              horizontal: AppDimensions.spacingM,
            ),
          ),
        ),
      ),
    );
  }
}
