import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:u_clinic/core/theme/app_colors.dart';
import 'package:u_clinic/core/theme/app_typography.dart';
import 'package:u_clinic/core/theme/app_dimensions.dart';
import 'package:u_clinic/presentation/providers/auth/auth_bloc.dart';
import 'package:u_clinic/presentation/providers/auth/auth_event.dart';
import 'package:u_clinic/presentation/providers/auth/auth_state.dart';
import 'package:u_clinic/presentation/widgets/inputs/custom_text_field.dart';
import 'package:u_clinic/presentation/widgets/buttons/primary_button.dart';
import 'package:u_clinic/core/routes/app_router.dart';
import 'package:u_clinic/domain/enums/user_role.dart';

class HealthcareSignInScreen extends StatefulWidget {
  const HealthcareSignInScreen({super.key});

  @override
  State<HealthcareSignInScreen> createState() => _HealthcareSignInScreenState();
}

class _HealthcareSignInScreenState extends State<HealthcareSignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  UserRole _selectedRole = UserRole.patient;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignIn() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      context.read<AuthBloc>().add(
        AuthSignInRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          role: _selectedRole,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            setState(() {
              _isLoading = false;
            });
            print('✅ Sign in successful! User authenticated.');

            // Navigate based on user role
            _navigateBasedOnRole(_selectedRole);
          } else if (state is AuthError) {
            setState(() {
              _isLoading = false;
            });
            print('❌ Sign in failed: ${state.message}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.spacingL),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Text(
                    'Welcome Back',
                    style: AppTypography.heading1.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppDimensions.spacingS),
                  Text(
                    'Sign in to your account to continue',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppDimensions.spacingXL),

                  // Role Selector
                  Text(
                    'Sign in as:',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingS),
                  Row(
                    children: UserRole.values.map((role) {
                      final isSelected = _selectedRole == role;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedRole = role),
                          child: Container(
                            margin: const EdgeInsets.only(
                              right: AppDimensions.spacingS,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.spacingM,
                              vertical: AppDimensions.spacingS,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radiusM,
                              ),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.divider,
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  _getRoleIcon(role),
                                  color: isSelected
                                      ? AppColors.textLight
                                      : AppColors.textSecondary,
                                  size: 24,
                                ),
                                const SizedBox(height: AppDimensions.spacingXS),
                                Text(
                                  _getRoleDisplayName(role),
                                  style: AppTypography.bodySmall.copyWith(
                                    color: isSelected
                                        ? AppColors.textLight
                                        : AppColors.textSecondary,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppDimensions.spacingL),

                  // Email Field
                  CustomTextField(
                    controller: _emailController,
                    label: 'Email',
                    hintText: _getEmailHint(),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }

                      // Validate based on role
                      switch (_selectedRole) {
                        case UserRole.patient:
                          // Students must use @st.umat.edu.gh emails
                          if (!value.endsWith('@st.umat.edu.gh')) {
                            return 'Students must use @st.umat.edu.gh email addresses';
                          }
                          break;
                        case UserRole.staff:
                        case UserRole.admin:
                          // Staff and admin can use any valid email
                          if (!RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          ).hasMatch(value)) {
                            return 'Please enter a valid email address';
                          }
                          break;
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: AppDimensions.spacingM),

                  // Password Field
                  CustomTextField(
                    controller: _passwordController,
                    label: 'Password',
                    hintText: 'Enter your password',
                    obscureText: !_isPasswordVisible,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppDimensions.spacingM),

                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // TODO: Implement forgot password
                      },
                      child: Text(
                        'Forgot Password?',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingL),

                  // Sign In Button
                  PrimaryButton(
                    onPressed: _isLoading ? null : _handleSignIn,
                    text: _isLoading ? 'Signing In...' : 'Sign In',
                  ),
                  const SizedBox(height: AppDimensions.spacingM),

                  // Sign Up Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            AppRouter.healthcareSignUp,
                          );
                        },
                        child: Text(
                          'Sign Up',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getEmailHint() {
    switch (_selectedRole) {
      case UserRole.patient:
        return 'your.name@st.umat.edu.gh';
      case UserRole.staff:
        return 'staff@umat.edu.gh';
      case UserRole.admin:
        return 'admin@umat.edu.gh';
    }
  }

  void _navigateBasedOnRole(UserRole role) {
    print('🎯 Navigating to ${role.value} dashboard');
    switch (role) {
      case UserRole.patient:
        Navigator.pushReplacementNamed(context, AppRouter.home);
        break;
      case UserRole.staff:
        Navigator.pushReplacementNamed(context, AppRouter.staffDashboard);
        break;
      case UserRole.admin:
        Navigator.pushReplacementNamed(context, AppRouter.adminDashboard);
        break;
    }
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.patient:
        return AppColors.primary;
      case UserRole.staff:
        return AppColors.primary;
      case UserRole.admin:
        return AppColors.primary;
    }
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.patient:
        return Icons.person_outline;
      case UserRole.staff:
        return Icons.medical_services_outlined;
      case UserRole.admin:
        return Icons.admin_panel_settings_outlined;
    }
  }

  String _getRoleDisplayName(UserRole role) {
    switch (role) {
      case UserRole.patient:
        return 'Patient';
      case UserRole.staff:
        return 'Staff';
      case UserRole.admin:
        return 'Admin';
    }
  }
}











