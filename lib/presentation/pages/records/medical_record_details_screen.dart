import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';

class MedicalRecordDetailsScreen extends StatelessWidget {
  final String recordId;
  const MedicalRecordDetailsScreen({super.key, required this.recordId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Record Details',
          style: AppTypography.heading3.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.spacingL),
        children: [
          Text(
            'Visit summary #$recordId',
            style: AppTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingS),
          Text(
            'Department: General Practice',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingM),
          Text('Doctor Notes', style: AppTypography.bodyLarge),
          const SizedBox(height: AppDimensions.spacingS),
          Text(
            'Patient presented with common cold symptoms. Rest and hydration recommended. Paracetamol prescribed for fever.',
            style: AppTypography.bodyMedium,
          ),
          const SizedBox(height: AppDimensions.spacingL),
          ElevatedButton(
            onPressed: () {},
            child: const Text('Download PDF Summary'),
          ),
        ],
      ),
    );
  }
}
