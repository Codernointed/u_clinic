import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../providers/auth/auth_bloc.dart';
import '../../providers/auth/auth_state.dart';
import '../../widgets/inputs/custom_text_field.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _symptomsController = TextEditingController();
  final _conditionsController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _medicationsController = TextEditingController();

  List<String> _symptoms = [];
  List<String> _conditions = [];
  List<String> _allergies = [];
  List<String> _medications = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final state = context.read<AuthBloc>().state;
    if (state is AuthAuthenticated) {
      final user = state.user;
      _symptoms = user.presentingSymptoms;
      _conditions = user.medicalConditions;
      _allergies = user.allergies;
      _medications = user.medications;
    }
  }

  @override
  void dispose() {
    _symptomsController.dispose();
    _conditionsController.dispose();
    _allergiesController.dispose();
    _medicationsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: AppTypography.heading2.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _saveProfile,
            icon: const Icon(Icons.save, color: AppColors.primary),
          ),
        ],
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticated) {
            return _buildProfileContent(state.user);
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildProfileContent(user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spacingM),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(user),
            const SizedBox(height: AppDimensions.spacingL),
            _buildPersonalInformation(user),
            const SizedBox(height: AppDimensions.spacingL),
            _buildMedicalInformation(),
            const SizedBox(height: AppDimensions.spacingL),
            _buildEmergencyContacts(user),
            const SizedBox(height: AppDimensions.spacingL),
            _buildAcademicInfo(user),
            const SizedBox(height: AppDimensions.spacingL),
            _buildSecuritySettings(user),
            const SizedBox(height: AppDimensions.spacingXL),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(user) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingL),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryLight, AppColors.primary],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(Icons.person, size: 40, color: Colors.white),
          ),
          const SizedBox(width: AppDimensions.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName,
                  style: AppTypography.heading3.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  user.displayId,
                  style: AppTypography.bodyMedium.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                Text(
                  user.role.value.toUpperCase(),
                  style: AppTypography.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInformation(user) {
    return _buildSection('Personal Information', Icons.person_outline, [
      _buildInfoRow('Full Name', user.fullName),
      _buildInfoRow('Email', user.email),
      _buildInfoRow('Phone', user.phoneNumber ?? 'Not provided'),
      _buildInfoRow(
        'Date of Birth',
        user.dateOfBirth?.toString().split(' ')[0] ?? 'Not provided',
      ),
      _buildInfoRow('Blood Group', user.bloodGroup ?? 'Not provided'),
    ]);
  }

  Widget _buildMedicalInformation() {
    return _buildSection('Medical Information', Icons.medical_services, [
      _buildListInput(
        'Current Symptoms',
        'Add symptoms you\'re experiencing',
        _symptoms,
        _symptomsController,
        (value) => _addSymptom(value),
        (index) => _removeSymptom(index),
      ),
      const SizedBox(height: AppDimensions.spacingM),
      _buildListInput(
        'Medical Conditions',
        'Add chronic conditions or diagnoses',
        _conditions,
        _conditionsController,
        (value) => _addCondition(value),
        (index) => _removeCondition(index),
      ),
      const SizedBox(height: AppDimensions.spacingM),
      _buildListInput(
        'Allergies',
        'Add known allergies',
        _allergies,
        _allergiesController,
        (value) => _addAllergy(value),
        (index) => _removeAllergy(index),
      ),
      const SizedBox(height: AppDimensions.spacingM),
      _buildListInput(
        'Current Medications',
        'Add medications you\'re taking',
        _medications,
        _medicationsController,
        (value) => _addMedication(value),
        (index) => _removeMedication(index),
      ),
    ]);
  }

  Widget _buildEmergencyContacts(user) {
    return _buildSection('Emergency Contacts', Icons.emergency, [
      _buildInfoRow(
        'Emergency Contact Name',
        user.emergencyContactName ?? 'Not provided',
      ),
      _buildInfoRow(
        'Emergency Contact Phone',
        user.emergencyContactPhone ?? 'Not provided',
      ),
      _buildEmergencyButton(),
    ]);
  }

  Widget _buildAcademicInfo(user) {
    return _buildSection('Academic/Professional Information', Icons.school, [
      _buildInfoRow('Department', user.department ?? 'Not specified'),
      if (user.yearOfStudy != null)
        _buildInfoRow('Year of Study', 'Year ${user.yearOfStudy}'),
      _buildInfoRow('Student/Staff ID', user.displayId),
    ]);
  }

  Widget _buildSecuritySettings(user) {
    return _buildSection('Security & Privacy', Icons.security, [
      _buildSwitchRow('Two-Factor Authentication', user.is2FAEnabled),
      _buildSwitchRow('Email Notifications', true),
      _buildSwitchRow('SMS Notifications', false),
      _buildSwitchRow('Push Notifications', true),
    ]);
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Container(
        padding: const EdgeInsets.all(AppDimensions.spacingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 24),
              const SizedBox(width: AppDimensions.spacingS),
              Text(
                title,
                style: AppTypography.heading3.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingM),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingS),
      child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
                    ),
                  ),
                ],
              ),
    );
  }

  Widget _buildListInput(
    String label,
    String hint,
    List<String> items,
    TextEditingController controller,
    Function(String) onAdd,
    Function(int) onRemove,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingS),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: controller,
                hintText: hint,
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    onAdd(value);
                    controller.clear();
                  }
                },
              ),
            ),
            const SizedBox(width: AppDimensions.spacingS),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  onAdd(controller.text);
                  controller.clear();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                ),
              ),
              child: const Icon(Icons.add, size: 20),
            ),
          ],
        ),
        if (items.isNotEmpty) ...[
          const SizedBox(height: AppDimensions.spacingS),
          Wrap(
            spacing: AppDimensions.spacingS,
            runSpacing: AppDimensions.spacingS,
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Chip(
                label: Text(item),
                backgroundColor: AppColors.primaryLight,
                labelStyle: AppTypography.bodySmall.copyWith(
                  color: AppColors.primary,
                ),
                deleteIcon: Icon(
                  Icons.close,
                  size: 16,
                  color: AppColors.primary,
                ),
                onDeleted: () => onRemove(index),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildSwitchRow(String label, bool value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingS),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          Switch(
            value: value,
            onChanged: (newValue) {
              // Handle switch changes
            },
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyButton() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: AppDimensions.spacingM),
      child: ElevatedButton.icon(
        onPressed: () {
          // Handle emergency call
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Emergency call initiated...'),
              backgroundColor: AppColors.emergency,
            ),
          );
        },
        icon: const Icon(Icons.emergency, color: Colors.white),
        label: const Text('Call Emergency'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.emergency,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingM),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          ),
        ),
      ),
    );
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              const Center(child: CircularProgressIndicator()),
        );

        // Get current user
        final state = context.read<AuthBloc>().state;
        if (state is AuthAuthenticated) {
          final currentUser = state.user;

          // Update user with new data
          final updatedUser = currentUser.copyWith(
            presentingSymptoms: _symptoms,
            medicalConditions: _conditions,
            allergies: _allergies,
            medications: _medications,
            updatedAt: DateTime.now(),
          );

          // Update profile in repository
          final authBloc = context.read<AuthBloc>();
          await authBloc.updateProfile(updatedUser);

          // Close loading dialog
          Navigator.pop(context);

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile saved successfully!'),
              backgroundColor: Colors.green,
            ),
          );

          // Refresh the UI
          setState(() {});
        }
      } catch (e) {
        // Close loading dialog
        Navigator.pop(context);

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving profile: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _addSymptom(String symptom) {
    if (symptom.trim().isNotEmpty) {
      setState(() {
        _symptoms.add(symptom.trim());
      });
      _symptomsController.clear();
    }
  }

  void _addCondition(String condition) {
    if (condition.trim().isNotEmpty) {
      setState(() {
        _conditions.add(condition.trim());
      });
      _conditionsController.clear();
    }
  }

  void _addAllergy(String allergy) {
    if (allergy.trim().isNotEmpty) {
      setState(() {
        _allergies.add(allergy.trim());
      });
      _allergiesController.clear();
    }
  }

  void _addMedication(String medication) {
    if (medication.trim().isNotEmpty) {
      setState(() {
        _medications.add(medication.trim());
      });
      _medicationsController.clear();
    }
  }

  void _removeSymptom(int index) {
    setState(() {
      _symptoms.removeAt(index);
    });
  }

  void _removeCondition(int index) {
    setState(() {
      _conditions.removeAt(index);
    });
  }

  void _removeAllergy(int index) {
    setState(() {
      _allergies.removeAt(index);
    });
  }

  void _removeMedication(int index) {
    setState(() {
      _medications.removeAt(index);
    });
  }
}
