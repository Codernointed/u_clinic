import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../providers/auth/auth_bloc.dart';
import '../../providers/auth/auth_state.dart';
import '../../../domain/entities/medical_record.dart';
import '../../../domain/repositories/medical_record_repository.dart';
import '../../../data/repositories/working_medical_record_repository.dart';
import '../../../core/services/supabase_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';

class MedicalRecordsScreen extends StatefulWidget {
  const MedicalRecordsScreen({super.key});

  @override
  State<MedicalRecordsScreen> createState() => _MedicalRecordsScreenState();
}

class _MedicalRecordsScreenState extends State<MedicalRecordsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'All';

  final List<String> _filterOptions = [
    'All',
    'Recent',
    'Prescriptions',
    'Lab Results',
  ];

  // Repository for medical records
  late final MedicalRecordRepository _medicalRecordRepository;

  // Data
  List<MedicalRecord> _allRecords = [];
  List<MedicalRecord> _filteredRecords = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _medicalRecordRepository = WorkingMedicalRecordRepository(
      SupabaseService.instance,
    );
    _loadMedicalRecords();
  }

  Future<void> _loadMedicalRecords() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final state = context.read<AuthBloc>().state;
      if (state is AuthAuthenticated) {
        final result = await _medicalRecordRepository.getPatientRecords(
          patientId: state.user.id,
        );

        result.fold(
          (failure) {
            setState(() {
              _error = failure.message;
              _isLoading = false;
            });
          },
          (records) {
            setState(() {
              _allRecords = records;
              _filteredRecords = records;
              _isLoading = false;
            });
          },
        );
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _applyFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
      switch (filter) {
        case 'Recent':
          _filteredRecords = _allRecords
              .where((record) => record.isRecent)
              .toList();
          break;
        case 'Prescriptions':
          _filteredRecords = _allRecords
              .where((record) => record.recordType == 'prescription')
              .toList();
          break;
        case 'Lab Results':
          _filteredRecords = _allRecords
              .where((record) => record.recordType == 'lab_result')
              .toList();
          break;
        default:
          _filteredRecords = _allRecords;
      }
    });
  }

  void _showUploadDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upload Medical Record'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.file_present),
              title: const Text('Choose File'),
              onTap: () {
                Navigator.pop(context);
                _pickFile();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: source);

      if (image != null) {
        await _uploadMedicalRecord(File(image.path), 'image', 'Medical Image');
      }
    } catch (e) {
      _showErrorSnackBar('Error picking image: ${e.toString()}');
    }
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.isNotEmpty) {
        final file = File(result.files.first.path!);
        await _uploadMedicalRecord(file, 'file', result.files.first.name);
      }
    } catch (e) {
      _showErrorSnackBar('Error picking file: ${e.toString()}');
    }
  }

  Future<void> _uploadMedicalRecord(File file, String type, String name) async {
    try {
      final state = context.read<AuthBloc>().state;
      if (state is AuthAuthenticated) {
        // Create a new medical record
        final record = MedicalRecord(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          patientId: state.user.id,
          patientName: state.user.fullName,
          recordType: type == 'image' ? 'medical_image' : 'document',
          recordDate: DateTime.now(),
          title: name,
          description: 'Uploaded $type',
          details: {
            'filePath': file.path,
            'fileSize': file.lengthSync(),
            'uploadDate': DateTime.now().toIso8601String(),
          },
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final result = await _medicalRecordRepository.createRecord(
          record: record,
        );
        result.fold(
          (failure) {
            _showErrorSnackBar('Error uploading record: ${failure.message}');
          },
          (_) {
            _showSuccessSnackBar('Record uploaded successfully!');
            _loadMedicalRecords(); // Refresh the list
          },
        );
      }
    } catch (e) {
      _showErrorSnackBar('Error uploading record: ${e.toString()}');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Medical Records',
          style: AppTypography.heading2.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _exportRecords,
            icon: const Icon(Icons.download, color: AppColors.primary),
            tooltip: 'Export Records',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Prescriptions'),
            Tab(text: 'Lab Results'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildFilterSection(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildPrescriptionsTab(),
                _buildLabResultsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter Records',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _showUploadDialog,
                icon: const Icon(Icons.upload_file),
                label: const Text('Upload'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingS),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _filterOptions.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(width: AppDimensions.spacingS),
              itemBuilder: (context, index) {
                final option = _filterOptions[index];
                final isSelected = _selectedFilter == option;
                return FilterChip(
                  label: Text(option),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedFilter = option;
                    });
                  },
                  backgroundColor: Colors.white,
                  selectedColor: AppColors.primaryLight,
                  labelStyle: AppTypography.bodySmall.copyWith(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                  side: BorderSide(
                    color: isSelected ? AppColors.primary : AppColors.divider,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.spacingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryCards(),
                const SizedBox(height: AppDimensions.spacingL),
                _buildRecentVisits(),
                const SizedBox(height: AppDimensions.spacingL),
                _buildUpcomingAppointments(),
              ],
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildSummaryCards() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: AppDimensions.spacingM,
      mainAxisSpacing: AppDimensions.spacingM,
      childAspectRatio: 1.2,
      children: [
        _buildSummaryCard(
          'Total Visits',
          '12',
          Icons.medical_services,
          AppColors.cardMedicalRecord,
        ),
        _buildSummaryCard(
          'Active Prescriptions',
          '3',
          Icons.medication,
          AppColors.cardPrescription,
        ),
        _buildSummaryCard(
          'Lab Tests',
          '8',
          Icons.science,
          AppColors.cardLabResult,
        ),
        _buildSummaryCard(
          'Next Appointment',
          'Tomorrow',
          Icons.calendar_today,
          AppColors.cardAppointment,
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingM),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.primary, size: 32),
          const SizedBox(height: AppDimensions.spacingS),
          Text(
            value,
            style: AppTypography.heading3.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentVisits() {
    return _buildSection('Recent Visits', Icons.history, [
      _buildVisitCard(
        'Dr. Sarah Johnson',
        'General Practice',
        'Fever and sore throat',
        '2024-01-15',
        'Completed',
      ),
      _buildVisitCard(
        'Dr. Michael Chen',
        'Cardiology',
        'Heart checkup',
        '2024-01-10',
        'Completed',
      ),
      _buildVisitCard(
        'Dr. Emily Davis',
        'Dermatology',
        'Skin rash',
        '2024-01-05',
        'Completed',
      ),
    ]);
  }

  Widget _buildVisitCard(
    String doctorName,
    String department,
    String reason,
    String date,
    String status,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingM),
      padding: const EdgeInsets.all(AppDimensions.spacingM),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctorName,
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      department,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingS,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                ),
                child: Text(
                  status,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingS),
          Text(
            reason,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingS),
          Text(
            'Date: $date',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingAppointments() {
    return _buildSection('Upcoming Appointments', Icons.schedule, [
      _buildAppointmentCard(
        'Dr. Sarah Johnson',
        'General Practice',
        'Follow-up consultation',
        '2024-01-20',
        '10:00 AM',
      ),
    ]);
  }

  Widget _buildAppointmentCard(
    String doctorName,
    String department,
    String reason,
    String date,
    String time,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingM),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.spacingS),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
            ),
            child: const Icon(
              Icons.calendar_today,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: AppDimensions.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctorName,
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  department,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  reason,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '$date at $time',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.primary,
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

  Widget _buildPrescriptionsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection('Active Prescriptions', Icons.medication, [
            _buildPrescriptionCard(
              'Amoxicillin',
              '500mg',
              '3 times daily',
              '7 days',
              '2024-01-15',
              'Active',
            ),
            _buildPrescriptionCard(
              'Ibuprofen',
              '400mg',
              'As needed',
              '30 days',
              '2024-01-10',
              'Active',
            ),
            _buildPrescriptionCard(
              'Vitamin D',
              '1000 IU',
              'Once daily',
              '90 days',
              '2024-01-05',
              'Active',
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildPrescriptionCard(
    String medication,
    String dosage,
    String frequency,
    String duration,
    String startDate,
    String status,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingM),
      padding: const EdgeInsets.all(AppDimensions.spacingM),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                medication,
                style: AppTypography.heading4.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingS,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                ),
                child: Text(
                  status,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingS),
          _buildPrescriptionDetail('Dosage', dosage),
          _buildPrescriptionDetail('Frequency', frequency),
          _buildPrescriptionDetail('Duration', duration),
          _buildPrescriptionDetail('Start Date', startDate),
        ],
      ),
    );
  }

  Widget _buildPrescriptionDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabResultsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection('Recent Lab Results', Icons.science, [
            _buildLabResultCard(
              'Blood Test',
              'Normal',
              '2024-01-15',
              'All values within normal range',
              false,
            ),
            _buildLabResultCard(
              'Urine Analysis',
              'Normal',
              '2024-01-10',
              'No abnormalities detected',
              false,
            ),
            _buildLabResultCard(
              'Cholesterol Test',
              'High',
              '2024-01-05',
              'Total cholesterol: 240 mg/dL (Normal: <200)',
              true,
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildLabResultCard(
    String testName,
    String result,
    String date,
    String notes,
    bool isAbnormal,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingM),
      padding: const EdgeInsets.all(AppDimensions.spacingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(
          color: isAbnormal ? AppColors.warning : AppColors.divider,
        ),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                testName,
                style: AppTypography.heading4.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingS,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isAbnormal
                      ? AppColors.warning.withValues(alpha: 0.1)
                      : AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                ),
                child: Text(
                  result,
                  style: AppTypography.bodySmall.copyWith(
                    color: isAbnormal ? AppColors.warning : AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingS),
          _buildLabResultDetail('Date', date),
          _buildLabResultDetail('Notes', notes),
          if (isAbnormal) ...[
            const SizedBox(height: AppDimensions.spacingS),
            Container(
              padding: const EdgeInsets.all(AppDimensions.spacingS),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: AppColors.warning, size: 16),
                  const SizedBox(width: AppDimensions.spacingS),
                  Expanded(
                    child: Text(
                      'Follow up with your doctor recommended',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.warning,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLabResultDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Column(
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
    );
  }

  Future<void> _exportRecords() async {
    try {
      final state = context.read<AuthBloc>().state;
      if (state is AuthAuthenticated) {
        // Show export options dialog
        final format = await showDialog<String>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Export Records'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.picture_as_pdf),
                  title: const Text('PDF'),
                  onTap: () => Navigator.pop(context, 'pdf'),
                ),
                ListTile(
                  leading: const Icon(Icons.table_chart),
                  title: const Text('CSV'),
                  onTap: () => Navigator.pop(context, 'csv'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
        );

        if (format != null) {
          await _performExport(state.user.id, format);
        }
      }
    } catch (e) {
      _showErrorSnackBar('Error exporting records: ${e.toString()}');
    }
  }

  Future<void> _performExport(String patientId, String format) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      if (format == 'pdf') {
        await _exportToPDF(patientId);
      } else if (format == 'csv') {
        await _exportToCSV(patientId);
      }

      Navigator.pop(context); // Close loading dialog
      _showSuccessSnackBar('Records exported successfully!');
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      _showErrorSnackBar('Error exporting records: ${e.toString()}');
    }
  }

  Future<void> _exportToPDF(String patientId) async {
    // Get patient records
    final result = await _medicalRecordRepository.getPatientRecords(
      patientId: patientId,
    );

    result.fold((failure) => throw Exception(failure.message), (records) async {
      // Create PDF document
      final pdf = pw.Document();

      // Add title page
      pdf.addPage(
        pw.Page(
          build: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(level: 0, child: pw.Text('Medical Records Report')),
              pw.SizedBox(height: 20),
              pw.Text('Patient ID: $patientId'),
              pw.Text('Generated: ${DateTime.now().toString()}'),
              pw.SizedBox(height: 20),
              pw.Divider(),
            ],
          ),
        ),
      );

      // Add records pages
      for (final record in records) {
        pdf.addPage(
          pw.Page(
            build: (context) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Header(level: 1, child: pw.Text(record.title)),
                pw.SizedBox(height: 8),
                pw.Text('Type: ${record.recordType}'),
                pw.Text('Date: ${record.recordDate.toString()}'),
                pw.Text('Description: ${record.description}'),
                if (record.doctorName != null)
                  pw.Text('Doctor: ${record.doctorName}'),
                if (record.department != null)
                  pw.Text('Department: ${record.department}'),
                pw.SizedBox(height: 8),
                pw.Divider(),
              ],
            ),
          ),
        );
      }

      // Save PDF to temporary directory
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/medical_records_$patientId.pdf');
      await file.writeAsBytes(await pdf.save());

      // Open PDF
      await Printing.layoutPdf(
        onLayout: (format) async => file.readAsBytesSync(),
      );
    });
  }

  Future<void> _exportToCSV(String patientId) async {
    // Get patient records
    final result = await _medicalRecordRepository.getPatientRecords(
      patientId: patientId,
    );

    result.fold((failure) => throw Exception(failure.message), (records) async {
      // Create CSV content
      final csv = StringBuffer();
      csv.writeln('Title,Type,Date,Description,Doctor,Department');

      for (final record in records) {
        csv.writeln(
          [
            record.title,
            record.recordType,
            record.recordDate.toString(),
            record.description,
            record.doctorName ?? '',
            record.department ?? '',
          ].map((field) => '"${field.replaceAll('"', '""')}"').join(','),
        );
      }

      // Save CSV to temporary directory
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/medical_records_$patientId.csv');
      await file.writeAsBytes(csv.toString().codeUnits);

      // Show success message with file path
      _showSuccessSnackBar('CSV exported to: ${file.path}');
    });
  }
}
