import 'package:flutter/material.dart';
import 'package:u_clinic/core/theme/app_colors.dart';
import 'package:u_clinic/core/theme/app_dimensions.dart';
import 'package:u_clinic/core/theme/app_typography.dart';

class DeactivateAccountScreen extends StatelessWidget {
  const DeactivateAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Deactivate Account', style: AppTypography.heading3),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.screenPaddingHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppDimensions.spacingL),
            const Icon(
              Icons.warning_amber_rounded,
              size: 64,
              color: AppColors.warning,
            ),
            const SizedBox(height: AppDimensions.spacingM),
            Text(
              'Are you sure you want to deactivate your account?',
              style: AppTypography.heading3,
            ),
            const SizedBox(height: AppDimensions.spacingM),
            Text(
              'Deactivating your account will disable your profile and remove your name and photo from most things you\'ve shared. Some information may still be visible to others, such as your name in their friends list and messages you sent.',
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: AppDimensions.buttonHeight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                ),
                onPressed: () {
                  // TODO: Implement deactivation logic
                  // For now, just pop back to settings
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  Navigator.pushReplacementNamed(context, '/sign-in');
                },
                child: const Text('Deactivate Account'),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingM),
            SizedBox(
              width: double.infinity,
              height: AppDimensions.buttonHeight,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingXL),
          ],
        ),
      ),
    );
  }
}
