import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:u_clinic/core/theme/app_colors.dart';
import 'package:u_clinic/core/theme/app_dimensions.dart';
import 'package:u_clinic/core/theme/app_typography.dart';
import 'package:u_clinic/domain/entities/appointment.dart';
import 'package:u_clinic/domain/enums/appointment_status.dart';
import 'package:u_clinic/domain/enums/consultation_type.dart';
import 'package:u_clinic/domain/repositories/appointment_repository.dart';
import 'package:u_clinic/presentation/providers/auth/auth_bloc.dart';
import 'package:u_clinic/presentation/providers/auth/auth_state.dart';

import 'package:u_clinic/presentation/widgets/inputs/custom_text_field.dart';
import 'package:u_clinic/data/repositories/supabase_appointment_repository.dart';
import 'package:u_clinic/core/services/supabase_service.dart';

class AppointmentBookingScreen extends StatefulWidget {
  const AppointmentBookingScreen({super.key});

  @override
  State<AppointmentBookingScreen> createState() =>
      _AppointmentBookingScreenState();
}

class _AppointmentBookingScreenState extends State<AppointmentBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  final _symptomsController = TextEditingController();
  final _notesController = TextEditingController();

  // Real Supabase implementation
  late final AppointmentRepository _appointmentRepository;

  // Real data from database
  List<Map<String, dynamic>> _departments = [];
  Map<String, List<Map<String, dynamic>>> _doctorsByDepartment = {};
  List<String> _availableTimeSlots = [];

  bool _isLoadingDepartments = true;
  bool _isLoadingDoctors = false;

  String _selectedDepartmentId = '';
  String _selectedDepartmentName = '';
  String _selectedDoctorId = '';
  String _selectedDoctorName = '';
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String _selectedTime = '';
  ConsultationType _selectedConsultationType = ConsultationType.inPerson;

  // Default time slots (can be overridden by doctor availability)
  final List<String> _defaultTimeSlots = [
    '09:00 AM',
    '09:30 AM',
    '10:00 AM',
    '10:30 AM',
    '11:00 AM',
    '11:30 AM',
    '02:00 PM',
    '02:30 PM',
    '03:00 PM',
    '03:30 PM',
    '04:00 PM',
    '04:30 PM',
  ];

  @override
  void initState() {
    super.initState();
    _appointmentRepository = context.read<SupabaseAppointmentRepository>();
    _availableTimeSlots = List.from(_defaultTimeSlots);
    _loadDepartments();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _symptomsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // Load departments from database
  Future<void> _loadDepartments() async {
    try {
      setState(() {
        _isLoadingDepartments = true;
      });

      // Load all doctors directly since we're not using departments
      final response = await SupabaseService.instance
          .from('doctors')
          .select('id, title, specialization, qualification')
          .limit(50);

      final doctors = List<Map<String, dynamic>>.from(response);

      setState(() {
        _doctorsByDepartment['all'] = doctors;
        _isLoadingDepartments = false;
      });

      print('✅ Loaded ${doctors.length} doctors');
    } catch (e) {
      print('❌ Error loading doctors: $e');
      setState(() {
        _isLoadingDepartments = false;
      });
    }
  }

  // Load doctors for selected department
  Future<void> _loadDoctorsForDepartment(String departmentId) async {
    try {
      setState(() {
        _isLoadingDoctors = true;
      });

      final response = await SupabaseService.instance
          .from('doctors')
          .select('id, title, specialization, qualification')
          .limit(50);

      final doctors = List<Map<String, dynamic>>.from(response);

      setState(() {
        _doctorsByDepartment[departmentId] = doctors;
        _isLoadingDoctors = false;
      });

      print('✅ Loaded ${doctors.length} doctors for department');
    } catch (e) {
      print('❌ Error loading doctors: $e');
      setState(() {
        _isLoadingDoctors = false;
      });
    }
  }

  // Load available time slots for selected doctor and date
  Future<void> _loadAvailableTimeSlots(String doctorId, DateTime date) async {
    try {
      // Get existing appointments for the date
      // TODO: Implement doctor schedule checking in future version

      final appointmentsResponse = await SupabaseService.instance
          .from('appointments')
          .select('appointment_time')
          .eq('doctor_id', doctorId)
          .eq('appointment_date', date.toIso8601String().split('T')[0])
          .inFilter('status', ['scheduled', 'confirmed', 'in_progress']);

      // Process doctor's schedule and filter out booked slots
      final bookedTimes = appointmentsResponse
          .map((apt) => apt['appointment_time'] as String)
          .toSet();

      final availableSlots = _defaultTimeSlots
          .where((slot) => !bookedTimes.contains(slot))
          .toList();

      setState(() {
        _availableTimeSlots = availableSlots;
      });

      print('✅ Found ${availableSlots.length} available time slots');
    } catch (e) {
      print('❌ Error loading time slots: $e');
      setState(() {
        _availableTimeSlots = List.from(_defaultTimeSlots);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Book Appointment',
          style: AppTypography.heading2.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.spacingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProgressIndicator(),
              const SizedBox(height: AppDimensions.spacingL),
              _buildDepartmentSelection(),
              const SizedBox(height: AppDimensions.spacingL),
              _buildConsultationTypeSelection(),
              const SizedBox(height: AppDimensions.spacingL),
              _buildDateSelection(),
              const SizedBox(height: AppDimensions.spacingL),
              _buildAppointmentDetails(),
              const SizedBox(height: AppDimensions.spacingL),
               _buildTimeSelection(),
              const SizedBox(height: AppDimensions.spacingL),
              _buildBookingButton(),
              const SizedBox(height: AppDimensions.spacingXL),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          _buildProgressStep('Doctor', 1, _selectedDoctorId.isNotEmpty),
          _buildProgressLine(_selectedDoctorId.isNotEmpty),
          _buildProgressStep(
            'Schedule',
            2,
            _selectedDate != DateTime.now().add(const Duration(days: 1)) ||
                _selectedTime.isNotEmpty,
          ),
          _buildProgressLine(
            _selectedDate != DateTime.now().add(const Duration(days: 1)) ||
                _selectedTime.isNotEmpty,
          ),
          _buildProgressStep('Type', 3, _selectedConsultationType != null),
          _buildProgressLine(_selectedConsultationType != null),
          _buildProgressStep('Confirm', 4, false),
        ],
      ),
    );
  }

  Widget _buildProgressStep(String label, int step, bool isCompleted) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isCompleted ? AppColors.primary : AppColors.divider,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                step.toString(),
                style: AppTypography.bodySmall.copyWith(
                  color: isCompleted ? Colors.white : AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingS),
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: isCompleted ? AppColors.primary : AppColors.textSecondary,
              fontWeight: isCompleted ? FontWeight.w600 : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressLine(bool isCompleted) {
    return Container(
      height: 2,
      width: 20,
      color: isCompleted ? AppColors.primary : AppColors.divider,
    );
  }

  Widget _buildDepartmentSelection() {
    return _buildSection('Select Doctor', Icons.person, [
      Text(
        'Choose your preferred doctor for the appointment',
        style: AppTypography.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      const SizedBox(height: AppDimensions.spacingM),
      _isLoadingDepartments
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _doctorsByDepartment['all']?.length ?? 0,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: AppDimensions.spacingS),
              itemBuilder: (context, index) {
                final doctors = _doctorsByDepartment['all'] ?? [];
                if (doctors.isEmpty) return const SizedBox.shrink();

                final doctor = doctors[index];
                final doctorId = doctor['id'] as String;
                final doctorName = doctor['title'] as String;
                final specialization = doctor['specialization'] as String?;
                final qualification = doctor['qualification'] as String?;

                final isSelected = _selectedDoctorId == doctorId;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDoctorId = doctorId;
                      _selectedDoctorName = doctorName;
                      _selectedTime = '';
                    });
                    _loadAvailableTimeSlots(doctorId, _selectedDate);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(AppDimensions.spacingM),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primaryLight : Colors.white,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusM,
                      ),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.divider,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Icon(
                            Icons.person,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.spacingM),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                doctorName,
                                style: AppTypography.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                specialization ?? 'General Practice',
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              if (qualification != null)
                                Text(
                                  qualification,
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check_circle,
                            color: AppColors.primary,
                            size: 24,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    ]);
  }

  Widget _buildDoctorSelection() {
    if (_selectedDepartmentId.isEmpty) return const SizedBox.shrink();

    final doctors = _doctorsByDepartment[_selectedDepartmentId] ?? [];

    return _buildSection('Select Doctor', Icons.person, [
      Text(
        'Choose your preferred doctor from the $_selectedDepartmentName department',
        style: AppTypography.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      const SizedBox(height: AppDimensions.spacingM),
      _isLoadingDoctors
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(AppDimensions.spacingL),
                child: CircularProgressIndicator(),
              ),
            )
          : ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: doctors.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: AppDimensions.spacingS),
              itemBuilder: (context, index) {
                final doctor = doctors[index];
                final doctorId = doctor['id'] as String;
                final doctorName = doctor['title'] as String;
                final specialization = doctor['specialization'] as String?;
                final qualification = doctor['qualification'] as String?;

                final isSelected = _selectedDoctorId == doctorId;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDoctorId = doctorId;
                      _selectedDoctorName = doctorName;
                      _selectedTime = ''; // Reset time selection
                    });
                    _loadAvailableTimeSlots(doctorId, _selectedDate);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(AppDimensions.spacingM),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primaryLight : Colors.white,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusM,
                      ),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.divider,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Icon(
                            Icons.person,
                            color: AppColors.primary,
                            size: 24,
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
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                specialization ?? 'General Practice',
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              if (qualification != null)
                                Text(
                                  qualification,
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check_circle,
                            color: AppColors.primary,
                            size: 24,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    ]);
  }

  Widget _buildConsultationTypeSelection() {
    return _buildSection('Consultation Type', Icons.video_call, [
      Text(
        'Choose how you would like to consult with your doctor',
        style: AppTypography.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      const SizedBox(height: AppDimensions.spacingM),
      Row(
        children: [
          Expanded(
            child: _buildConsultationTypeCard(
              ConsultationType.inPerson,
              'In-Person',
              Icons.person,
              'Visit the clinic for a physical examination',
            ),
          ),
          const SizedBox(width: AppDimensions.spacingM),
          Expanded(
            child: _buildConsultationTypeCard(
              ConsultationType.video,
              'Video Call',
              Icons.video_call,
              'Consult via video call from anywhere',
            ),
          ),
        ],
      ),
      const SizedBox(height: AppDimensions.spacingM),
      _buildConsultationTypeCard(
        ConsultationType.voice,
        'Voice Call',
        Icons.call,
        'Consult via voice call',
      ),
    ]);
  }

  Widget _buildConsultationTypeCard(
    ConsultationType type,
    String title,
    IconData icon,
    String description,
  ) {
    final isSelected = _selectedConsultationType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedConsultationType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.spacingM),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: 32,
            ),
            const SizedBox(height: AppDimensions.spacingS),
            Text(
              title,
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacingS),
            Text(
              description,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelection() {
    return _buildSection('Select Date', Icons.calendar_today, [
      Text(
        'Choose your preferred appointment date',
        style: AppTypography.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      const SizedBox(height: AppDimensions.spacingM),
      Container(
        padding: const EdgeInsets.all(AppDimensions.spacingM),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: AppColors.primary, size: 24),
            const SizedBox(width: AppDimensions.spacingM),
            Expanded(
              child: Text(
                '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                style: AppTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () => _selectDate(context),
              child: const Text('Change Date'),
            ),
          ],
        ),
      ),
    ]);
  }

  Widget _buildTimeSelection() {
    return _buildSection('Select Time', Icons.access_time, [
      Text(
        'Choose your preferred appointment time',
        style: AppTypography.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      const SizedBox(height: AppDimensions.spacingM),
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: AppDimensions.spacingM,
          mainAxisSpacing: AppDimensions.spacingM,
          childAspectRatio: 2.5,
        ),
        itemCount: _availableTimeSlots.length,
        itemBuilder: (context, index) {
          final time = _availableTimeSlots[index];
          final isSelected = _selectedTime == time;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedTime = time;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(AppDimensions.spacingS),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.divider,
                ),
              ),
              child: Center(
                child: Text(
                  time,
                  style: AppTypography.bodySmall.copyWith(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        },
      ),
    ]);
  }

  Widget _buildAppointmentDetails() {
    return _buildSection('Appointment Details', Icons.edit_note, [
      CustomTextField(
        controller: _reasonController,
        hintText: 'Reason for visit',
        label: 'Reason for Visit *',
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter the reason for your visit';
          }
          return null;
        },
      ),
      const SizedBox(height: AppDimensions.spacingM),
      CustomTextField(
        controller: _symptomsController,
        hintText: 'Describe your symptoms (optional)',
        label: 'Symptoms',
      ),
      const SizedBox(height: AppDimensions.spacingM),
      CustomTextField(
        controller: _notesController,
        hintText: 'Additional notes or concerns (optional)',
        label: 'Additional Notes',
      ),
    ]);
  }

  Widget _buildBookingButton() {
    final canBook =
        _selectedDoctorId.isNotEmpty &&
        _selectedTime.isNotEmpty &&
        _reasonController.text.isNotEmpty;

    // Debug information
    print('🔍 Booking button debug:');
    print(
      '  - Doctor ID: "${_selectedDoctorId}" (${_selectedDoctorId.isNotEmpty})',
    );
    print('  - Time: "${_selectedTime}" (${_selectedTime.isNotEmpty})');
    print(
      '  - Reason: "${_reasonController.text}" (${_reasonController.text.isNotEmpty})',
    );
    print('  - Can book: $canBook');

    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: canBook ? _bookAppointment : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingL),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          ),
        ),
        child: Text(
          'Book Appointment',
          style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
    );
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _selectedTime = ''; // Reset time selection
      });
    }
  }

  void _bookAppointment() {
    if (_formKey.currentState!.validate()) {
      // Show confirmation dialog
      _showConfirmationDialog();
    }
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Appointment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildConfirmationRow('Department', _selectedDepartmentName),
            _buildConfirmationRow('Doctor', _selectedDoctorName),
            _buildConfirmationRow(
              'Date',
              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
            ),
            _buildConfirmationRow('Time', _selectedTime),
            _buildConfirmationRow(
              'Type',
              _selectedConsultationType.value
                  .replaceAll('_', ' ')
                  .toUpperCase(),
            ),
            _buildConfirmationRow('Reason', _reasonController.text),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _confirmBooking();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
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
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmBooking() async {
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

          // Create appointment (not used but kept for reference)

          // Book appointment through repository
          final result = await _appointmentRepository.bookAppointment(
            patientId: currentUser.id,
            patientName: currentUser.fullName,
            doctorId: _selectedDoctorId,
            doctorName: _selectedDoctorName,
            appointmentDate: _selectedDate,
            appointmentTime: _selectedTime,
            consultationType: _selectedConsultationType,
            reasonForVisit: _reasonController.text,
            symptoms: _symptomsController.text.isNotEmpty
                ? _symptomsController.text
                : null,
            notes: _notesController.text.isNotEmpty
                ? _notesController.text
                : null,
          );

          // Close loading dialog
          Navigator.pop(context);

          // Handle the result
          result.fold(
            (failure) {
              // Show error message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Error booking appointment: ${failure.message}',
                  ),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            },
            (bookedAppointment) {
              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Appointment booked successfully for ${bookedAppointment.formattedDateTime}!',
                  ),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 4),
                ),
              );

              // Navigate back to home screen
              Navigator.pop(context);
            },
          );
        }
      } catch (e) {
        // Close loading dialog
        Navigator.pop(context);

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error booking appointment: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
