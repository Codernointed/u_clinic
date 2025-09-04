import 'package:flutter/material.dart';
import 'package:u_clinic/core/theme/app_colors.dart';
import 'package:u_clinic/core/theme/app_dimensions.dart';
import 'package:u_clinic/core/theme/app_typography.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Delete Account', style: AppTypography.heading3),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.screenPaddingHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppDimensions.spacingL),
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: AppDimensions.spacingM),
            Text(
              'Are you absolutely sure?',
              style: AppTypography.heading3,
            ),
            const SizedBox(height: AppDimensions.spacingM),
            Text(
              'This action is irreversible. All your data, including your profile, health records, and activity, will be permanently deleted. You will not be able to recover your account.',
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingXL),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Enter your password to confirm',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    AppDimensions.cardBorderRadius,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingXXL),
            SizedBox(
              width: double.infinity,
              height: AppDimensions.buttonHeight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                ),
                onPressed: () {
                  // TODO: Implement deletion logic with password verification
                  if (_passwordController.text.isNotEmpty) {
                    // Basic check
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    Navigator.pushReplacementNamed(context, '/sign-in');
                  }
                },
                child: const Text('Permanently Delete Account'),
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
          ],
        ),
      ),
    );
  }
}
