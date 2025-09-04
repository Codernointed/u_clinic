import 'package:flutter/material.dart';
import 'package:u_clinic/core/theme/app_colors.dart';
import 'package:u_clinic/core/theme/app_dimensions.dart';
import 'package:u_clinic/core/theme/app_typography.dart';

class TwoFactorAuthenticationScreen extends StatefulWidget {
  const TwoFactorAuthenticationScreen({super.key});

  @override
  State<TwoFactorAuthenticationScreen> createState() =>
      _TwoFactorAuthenticationScreenState();
}

class _TwoFactorAuthenticationScreenState
    extends State<TwoFactorAuthenticationScreen> {
  bool _isTwoFactorEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Two-Factor Authentication',
          style: AppTypography.heading3,
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.screenPaddingHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppDimensions.spacingL),
            Text(
              'Add an extra layer of security to your account.',
              style: AppTypography.bodyLarge,
            ),
            const SizedBox(height: AppDimensions.spacingM),
            Text(
              'When you enable two-factor authentication, you will be asked for a secure code when you sign in from a new device.',
              style: AppTypography.bodyMedium,
            ),
            const SizedBox(height: AppDimensions.spacingXL),
            SwitchListTile(
              title: Text(
                'Enable Two-Factor Authentication',
                style: AppTypography.bodyLarge,
              ),
              value: _isTwoFactorEnabled,
              onChanged: (bool value) {
                setState(() {
                  _isTwoFactorEnabled = value;
                  // TODO: Implement logic to enable/disable 2FA
                });
              },
              activeColor: AppColors.primary,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }
}
