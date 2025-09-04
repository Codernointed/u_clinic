import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';

class PrescriptionsScreen extends StatelessWidget {
  const PrescriptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: Text(
          'Prescriptions',
          style: AppTypography.heading3.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppDimensions.spacingL),
        itemCount: 4,
        separatorBuilder: (_, __) =>
            const SizedBox(height: AppDimensions.spacingM),
        itemBuilder: (_, index) => Container(
          padding: const EdgeInsets.all(AppDimensions.spacingM),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.cardPrescription,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                ),
                child: const Icon(Icons.medication, color: AppColors.primary),
              ),
              const SizedBox(width: AppDimensions.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Amoxicillin 500mg',
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Take 1 capsule three times daily',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () async {
                  final pdf = pw.Document();
                  pdf.addPage(
                    pw.Page(
                      build: (context) => pw.Padding(
                        padding: const pw.EdgeInsets.all(24),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'UMaT E-Health Prescription',
                              style: pw.TextStyle(
                                fontSize: 20,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.SizedBox(height: 12),
                            pw.Text('Patient: Student User'),
                            pw.Text('Medication: Amoxicillin 500mg'),
                            pw.Text('Dosage: 1 capsule three times daily'),
                            pw.SizedBox(height: 20),
                            pw.Text('Prescriber: Dr. Sarah Johnson'),
                            pw.Text('Department: General Practice'),
                            pw.SizedBox(height: 20),
                            pw.Text('Notes:'),
                            pw.Text(
                              'Take with food and water. Complete full course.',
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                  final bytes = await pdf.save();
                  await Printing.sharePdf(
                    bytes: bytes,
                    filename: 'prescription.pdf',
                  );
                },
                child: const Text('Download'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
