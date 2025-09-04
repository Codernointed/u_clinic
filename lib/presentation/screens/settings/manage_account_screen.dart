import 'package:flutter/material.dart';
import 'package:u_clinic/core/theme/app_colors.dart';
import 'package:u_clinic/core/theme/app_dimensions.dart';
import 'package:u_clinic/core/theme/app_typography.dart';

class ManageAccountScreen extends StatelessWidget {
  const ManageAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Account', style: AppTypography.heading3),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.screenPaddingHorizontal),
        children: [
          const SizedBox(height: AppDimensions.spacingM),
          _buildSectionTitle('Security'),
          const SizedBox(height: AppDimensions.spacingS),
          _buildOptionTile(
            context,
            icon: Icons.lock_outline,
            title: 'Change Password',
            onTap: () => Navigator.pushNamed(context, '/change-password'),
          ),
          _buildOptionTile(
            context,
            icon: Icons.phonelink_lock_outlined,
            title: 'Two-Factor Authentication',
            onTap: () => Navigator.pushNamed(context, '/two-factor-auth'),
          ),

          const SizedBox(height: AppDimensions.spacingXL),
          _buildSectionTitle('Account Actions'),
          const SizedBox(height: AppDimensions.spacingS),
          _buildOptionTile(
            context,
            icon: Icons.power_settings_new,
            title: 'Deactivate Account',
            onTap: () => Navigator.pushNamed(context, '/deactivate-account'),
          ),
          _buildOptionTile(
            context,
            icon: Icons.delete_outline,
            title: 'Delete Account',
            isDestructive: true,
            onTap: () => Navigator.pushNamed(context, '/delete-account'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTypography.heading4.copyWith(color: AppColors.textSecondary),
    );
  }

  Widget _buildOptionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? AppColors.error : AppColors.textPrimary;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.cardBorderRadius),
        side: const BorderSide(color: AppColors.divider, width: 1),
      ),
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingM),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(
          title,
          style: AppTypography.bodyLarge.copyWith(color: color),
        ),
        trailing: Icon(Icons.chevron_right, color: color),
        onTap: onTap,
      ),
    );
  }
}
