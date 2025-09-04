import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:u_clinic/core/theme/app_colors.dart';
import 'package:u_clinic/core/theme/app_dimensions.dart';
import 'package:u_clinic/core/theme/app_typography.dart';
import 'package:u_clinic/presentation/widgets/inputs/custom_text_field.dart';
import 'package:u_clinic/presentation/widgets/buttons/primary_button.dart';
import 'package:u_clinic/presentation/providers/auth/auth_bloc.dart';
import 'package:u_clinic/presentation/providers/auth/auth_event.dart';
import 'package:u_clinic/presentation/providers/auth/auth_state.dart';
import 'package:u_clinic/core/routes/app_router.dart';
import 'package:u_clinic/domain/enums/user_role.dart';

class HealthcareSignUpScreen extends StatefulWidget {
  const HealthcareSignUpScreen({super.key});

  @override
  State<HealthcareSignUpScreen> createState() => _HealthcareSignUpScreenState();
}

class _HealthcareSignUpScreenState extends State<HealthcareSignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _departmentController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  UserRole _selectedRole = UserRole.patient;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _studentIdController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  void _handleSignUp() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      print('🚀 Starting sign up process...');
      print('📧 Email: ${_emailController.text.trim()}');
      print('👤 Role: ${_selectedRole.value}');
      print('📝 First Name: ${_firstNameController.text.trim()}');
      print('📝 Last Name: ${_lastNameController.text.trim()}');
      print('🆔 Student ID: ${_studentIdController.text.trim()}');
      print('🏢 Department: ${_departmentController.text.trim()}');

      context.read<AuthBloc>().add(
        AuthSignUpRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          studentId: _studentIdController.text.trim(),
          department: _departmentController.text.trim(),
          role: _selectedRole,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: Text(
          'Create Account',
          style: AppTypography.heading3.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            setState(() {
              _isLoading = false;
            });
            print('✅ Sign up successful! User authenticated.');

            // Navigate based on user role
            _navigateBasedOnRole(_selectedRole);
          } else if (state is AuthError) {
            setState(() {
              _isLoading = false;
            });
            print('❌ Sign up failed: ${state.message}');
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create your UMaT E-Health account',
                    style: AppTypography.heading2.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingS),
                  Text(
                    'Choose your role and provide your information',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingXL),

                  // Role Selector
                  Text(
                    'Sign up as:',
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

                  // Personal Information
                  Text(
                    'Personal Information',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingM),

                  // First Name
                  CustomTextField(
                    controller: _firstNameController,
                    label: 'First Name',
                    hintText: 'Enter your first name',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your first name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppDimensions.spacingM),

                  // Last Name
                  CustomTextField(
                    controller: _lastNameController,
                    label: 'Last Name',
                    hintText: 'Enter your last name',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your last name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppDimensions.spacingM),

                  // Student ID (for students) or Staff ID (for staff/admin)
                  if (_selectedRole == UserRole.patient)
                    CustomTextField(
                      controller: _studentIdController,
                      label: 'Student ID',
                      hintText: 'Enter your student ID',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your student ID';
                        }
                        return null;
                      },
                    )
                  else
                    CustomTextField(
                      controller: _studentIdController,
                      label: 'Staff ID',
                      hintText: 'Enter your staff ID',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your staff ID';
                        }
                        return null;
                      },
                    ),
                  const SizedBox(height: AppDimensions.spacingM),

                  // Department
                  CustomTextField(
                    controller: _departmentController,
                    label: 'Department',
                    hintText: _getDepartmentHint(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your department';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppDimensions.spacingL),

                  // Account Information
                  Text(
                    'Account Information',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingM),

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
                    hintText: 'Create a strong password',
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
                        return 'Please enter a password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppDimensions.spacingM),

                  // Confirm Password Field
                  CustomTextField(
                    controller: _confirmPasswordController,
                    label: 'Confirm Password',
                    hintText: 'Re-enter your password',
                    obscureText: !_isConfirmPasswordVisible,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordVisible =
                              !_isConfirmPasswordVisible;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppDimensions.spacingXL),

                  // Sign Up Button
                  PrimaryButton(
                    onPressed: _isLoading ? null : _handleSignUp,
                    text: _isLoading ? 'Creating Account...' : 'Create Account',
                  ),
                  const SizedBox(height: AppDimensions.spacingM),

                  // Sign In Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(
                            context,
                            AppRouter.healthcareSignIn,
                          );
                        },
                        child: Text(
                          'Sign In',
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

  String _getDepartmentHint() {
    switch (_selectedRole) {
      case UserRole.patient:
        return 'e.g., Computer Science, Engineering';
      case UserRole.staff:
        return 'e.g., IT Department, Administration';
      case UserRole.admin:
        return 'e.g., System Administration';
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
        return 'Student';
      case UserRole.staff:
        return 'Staff';
      case UserRole.admin:
        return 'Admin';
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
}
