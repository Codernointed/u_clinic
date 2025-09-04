import 'package:flutter/material.dart';

import 'package:u_clinic/core/theme/app_colors.dart';
import 'package:u_clinic/core/theme/app_dimensions.dart';
import 'package:u_clinic/core/theme/app_typography.dart';
import 'package:u_clinic/presentation/screens/settings/language_screen.dart';
import 'package:u_clinic/presentation/screens/settings/theme_screen.dart';
import 'package:u_clinic/presentation/screens/settings/manage_account_screen.dart';
import 'package:u_clinic/presentation/screens/settings/personal_information_screen.dart';
import 'package:u_clinic/presentation/screens/settings/privacy_policy_screen.dart';
import 'package:u_clinic/presentation/screens/settings/contact_us_screen.dart';
import 'package:u_clinic/presentation/screens/settings/faq_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _promotionalNotifications = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56.0),
        child: AppBar(
          title: Text('Settings', style: AppTypography.heading3),
          automaticallyImplyLeading: false,
          elevation: 0,
          centerTitle: false,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSettingsCategory("Preferences"),
              _buildSettingsTile(
                title: "Language",
                subtitle: "English",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LanguageScreen(),
                    ),
                  );
                },
              ),
              _buildSettingsTile(
                title: "Theme",
                subtitle: "Light",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ThemeScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppDimensions.spacingM),
              _buildSettingsCategory("Notifications"),
              _buildSwitchTile(
                title: "Push Notifications",
                subtitle: "Get notified about new articles and updates",
                value: _pushNotifications,
                onChanged: (value) {
                  setState(() {
                    _pushNotifications = value;
                  });
                },
              ),
              _buildSwitchTile(
                title: "Daily Health Tips",
                subtitle: "Receive daily health tips and reminders",
                value: _promotionalNotifications,
                onChanged: (value) {
                  setState(() {
                    _promotionalNotifications = value;
                  });
                },
              ),
              const SizedBox(height: AppDimensions.spacingM),
              _buildSettingsCategory("Account "),
              _buildSimpleTile(
                title: "Manage Account",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ManageAccountScreen(),
                    ),
                  );
                },
              ),
              _buildSimpleTile(
                title: "Update Personal Information",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PersonalInformationScreen(),
                    ),
                  );
                },
              ),
              _buildSimpleTile(
                title: "Privacy Policy",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PrivacyPolicyScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: AppDimensions.spacingM),
              _buildSettingsCategory("Help & Support"),
              _buildSimpleTile(
                title: "Contact Us",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ContactUsScreen(),
                    ),
                  );
                },
              ),
              _buildSimpleTile(
                title: "FAQ",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FaqScreen()),
                  );
                },
              ),

              const SizedBox(height: AppDimensions.spacingM),
              _buildSimpleTile(
                title: "Logout",
                onTap: () => _showLogoutConfirmationDialog(),
                isDestructive: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Logout'),
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/sign-in',
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildSettingsCategory(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(title, style: AppTypography.heading3),
    );
  }

  Widget _buildSettingsTile({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: AppTypography.bodyLarge),
      subtitle: Text(
        subtitle,
        style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary),
      ),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textPrimary),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: AppTypography.bodyLarge),
      subtitle: Text(
        subtitle,
        style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primary,
    );
  }

  Widget _buildSimpleTile({
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: AppTypography.bodyLarge.copyWith(
          color: isDestructive ? AppColors.error : AppColors.textPrimary,
        ),
      ),
      trailing: isDestructive
          ? null
          : const Icon(Icons.chevron_right, color: AppColors.textPrimary),
      onTap: onTap,
    );
  }
}
