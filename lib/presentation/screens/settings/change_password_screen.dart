import 'package:flutter/material.dart';
import 'package:u_clinic/core/theme/app_dimensions.dart';
import 'package:u_clinic/core/theme/app_typography.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Change Password', style: AppTypography.heading3),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.screenPaddingHorizontal),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: AppDimensions.spacingL),
              _buildPasswordField(
                controller: _currentPasswordController,
                label: 'Current Password',
              ),
              const SizedBox(height: AppDimensions.spacingM),
              _buildPasswordField(
                controller: _newPasswordController,
                label: 'New Password',
              ),
              const SizedBox(height: AppDimensions.spacingM),
              _buildPasswordField(
                controller: _confirmPasswordController,
                label: 'Confirm New Password',
              ),
              const SizedBox(height: AppDimensions.spacingXXL),
              SizedBox(
                width: double.infinity,
                height: AppDimensions.buttonHeight,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // TODO: Implement password change logic
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Update Password'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.cardBorderRadius),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your $label';
        }
        if (label == 'Confirm New Password' &&
            value != _newPasswordController.text) {
          return 'Passwords do not match';
        }
        return null;
      },
    );
  }
}
