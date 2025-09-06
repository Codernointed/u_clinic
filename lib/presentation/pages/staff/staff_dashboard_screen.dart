import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/routes/app_router.dart';
import '../../../core/services/notification_service.dart';
import '../../../domain/repositories/appointment_repository.dart';
import '../../../data/repositories/supabase_appointment_repository.dart';
import '../../../domain/enums/appointment_status.dart';
import '../../../presentation/providers/auth/auth_bloc.dart';
import '../../../presentation/providers/auth/auth_state.dart';
import '../chat/chat_list_screen.dart';
import '../notifications/notifications_screen.dart';

class StaffDashboardScreen extends StatefulWidget {
  const StaffDashboardScreen({super.key});

  @override
  State<StaffDashboardScreen> createState() => _StaffDashboardScreenState();
}

class _StaffDashboardScreenState extends State<StaffDashboardScreen> {
  int _index = 0;
  late final AppointmentRepository _appointmentRepository;
  List<dynamic> _todayAppointments = [];
  bool _isLoading = true;
  int _unreadNotifications = 0;

  @override
  void initState() {
    super.initState();
    _appointmentRepository = context.read<SupabaseAppointmentRepository>();
    _loadTodayAppointments();
    _initializeNotifications();
  }

  void _initializeNotifications() async {
    await notificationService.initialize();
    setState(() {
      _unreadNotifications = notificationService.unreadCount;
    });
    
    // Listen to notification updates
    notificationService.notificationsStream.listen((notifications) {
      if (mounted) {
        setState(() {
          _unreadNotifications = notifications.where((n) => !n.isRead).length;
        });
      }
    });
  }

  Future<void> _loadTodayAppointments() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final state = context.read<AuthBloc>().state;
      if (state is AuthAuthenticated) {
        // For staff, we'll show all appointments for today
        // In a real app, you'd filter by the staff member's department or assigned patients
        final result = await _appointmentRepository.getDoctorAppointments(
          doctorId: state.user.id,
          date: DateTime.now(),
        );

        result.fold(
          (failure) {
            print('❌ Failed to load appointments: ${failure.message}');
            setState(() {
              _todayAppointments = [];
              _isLoading = false;
            });
          },
          (appointments) {
            print('✅ Loaded ${appointments.length} appointments for today');
            setState(() {
              _todayAppointments = appointments;
              _isLoading = false;
            });
          },
        );
      }
    } catch (e) {
      print('❌ Error loading appointments: $e');
      setState(() {
        _todayAppointments = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.secondary],
            ),
          ),
        ),
        title: Text(
          _index == 0
              ? 'Today\'s Schedule'
              : _index == 1
              ? 'Patients'
              : _index == 2
              ? 'Consultation Room'
              : 'Profile',
          style: AppTypography.heading3.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationsScreen(),
                    ),
                  );
                },
              ),
              if (_unreadNotifications > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: AppColors.emergency,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$_unreadNotifications',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.home_outlined, color: Colors.white),
            tooltip: 'Staff Home',
            onPressed: () => Navigator.pushReplacementNamed(
              context,
              AppRouter.staffDashboard,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: IndexedStack(
        index: _index,
        children: [
          _StaffScheduleView(
            appointments: _todayAppointments,
            isLoading: _isLoading,
            onRefresh: _loadTodayAppointments,
          ),
          const _PatientManagementView(),
          const _StaffConsultationRoomView(),
          const _StaffProfileView(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        currentIndex: _index,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textTertiary,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Schedule',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups_outlined),
            activeIcon: Icon(Icons.groups),
            label: 'Patients',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.video_call_outlined),
            activeIcon: Icon(Icons.video_call),
            label: 'Consult',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _StaffScheduleView extends StatelessWidget {
  final List<dynamic> appointments;
  final bool isLoading;
  final VoidCallback onRefresh;

  const _StaffScheduleView({
    required this.appointments,
    required this.isLoading,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final completedCount = appointments
        .where((app) => app.status == AppointmentStatus.completed)
        .length;
    final remainingCount = appointments
        .where((app) => app.status == AppointmentStatus.scheduled)
        .length;

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: Column(
        children: [
          // Statistics Cards
          Container(
            padding: const EdgeInsets.all(AppDimensions.spacingL),
            child: Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Today\'s Patients',
                    value: appointments.length.toString(),
                    icon: Icons.people,
                    color: AppColors.cardConsultation,
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingM),
                Expanded(
                  child: _StatCard(
                    title: 'Completed',
                    value: completedCount.toString(),
                    icon: Icons.check_circle,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingM),
                Expanded(
                  child: _StatCard(
                    title: 'Remaining',
                    value: remainingCount.toString(),
                    icon: Icons.schedule,
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
          ),
          // Schedule List
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : appointments.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 64,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(height: AppDimensions.spacingM),
                        Text(
                          'No appointments today',
                          style: AppTypography.heading4.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.spacingS),
                        Text(
                          'You\'re all caught up!',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacingL,
                    ),
                    children: [
                      Text(
                        'Today\'s Appointments',
                        style: AppTypography.heading4.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingM),
                      ...appointments
                          .map(
                            (appointment) => _ScheduleTile(
                              time: '${appointment.appointmentTime}',
                              patient: appointment.patientName,
                              type: appointment.consultationType.value,
                              status: appointment.status.value,
                              avatar:
                                  'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400&h=400&fit=crop&crop=face',
                              reason: appointment.reasonForVisit,
                              symptoms: appointment.symptoms,
                              appointment:
                                  appointment, // Pass the appointment object
                            ),
                          )
                          .toList(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppDimensions.cardHeight,
      padding: const EdgeInsets.all(AppDimensions.spacingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTypography.heading3.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ScheduleTile extends StatelessWidget {
  final String time;
  final String patient;
  final String type;
  final String status;
  final String avatar;
  final String? reason;
  final String? symptoms;
  final dynamic appointment; // Add appointment data

  const _ScheduleTile({
    required this.time,
    required this.patient,
    required this.type,
    required this.status,
    required this.avatar,
    this.reason,
    this.symptoms,
    this.appointment, // Add appointment parameter
  });

  Color get _statusColor {
    switch (status) {
      case 'completed':
        return AppColors.success;
      case 'current':
        return AppColors.warning;
      default:
        return AppColors.primary;
    }
  }

  String get _statusText {
    switch (status) {
      case 'completed':
        return 'Completed';
      case 'current':
        return 'In Progress';
      default:
        return 'Start';
    }
  }

  void _startConsultation(BuildContext context) {
    // Navigate to consultation room with appointment details
    Navigator.pushNamed(
      context,
      AppRouter.consultationRoom,
      arguments: {
        'appointment': appointment,
        'patientName': patient,
        'appointmentTime': time,
        'reason': reason,
        'symptoms': symptoms,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingM),
      padding: const EdgeInsets.all(AppDimensions.spacingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: status == 'current'
            ? Border.all(color: AppColors.warning, width: 2)
            : null,
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: Image.network(
              avatar,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 50,
                height: 50,
                color: AppColors.cardAppointment,
                child: const Icon(Icons.person, color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patient,
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  type,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                if (reason != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Reason: $reason',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (symptoms != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Symptoms: $symptoms',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: _statusColor),
                    const SizedBox(width: 4),
                    Text(
                      time,
                      style: AppTypography.bodySmall.copyWith(
                        color: _statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (status == 'completed')
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              ),
              child: Text(
                'Completed',
                style: AppTypography.caption.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            ElevatedButton(
              onPressed: status == 'current' || status == 'scheduled'
                  ? () => _startConsultation(context)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _statusColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                minimumSize: Size.zero,
              ),
              child: Text(_statusText),
            ),
        ],
      ),
    );
  }
}

class _PatientManagementView extends StatefulWidget {
  const _PatientManagementView();

  @override
  State<_PatientManagementView> createState() => _PatientManagementViewState();
}

class _PatientManagementViewState extends State<_PatientManagementView> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final patients = [
      {
        'name': 'John Mensah',
        'id': 'UMaT/2025/001',
        'department': 'Engineering',
        'lastVisit': '2 days ago',
        'status': 'Active',
        'avatar':
            'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400&h=400&fit=crop&crop=face',
      },
      {
        'name': 'Ama Konadu',
        'id': 'UMaT/2025/002',
        'department': 'Medicine',
        'lastVisit': '1 week ago',
        'status': 'Follow-up',
        'avatar':
            'https://images.unsplash.com/photo-1494790108755-2616b332b893?w=400&h=400&fit=crop&crop=face',
      },
      {
        'name': 'Kwesi Boateng',
        'id': 'UMaT/2025/003',
        'department': 'Business',
        'lastVisit': '3 days ago',
        'status': 'Active',
        'avatar':
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=400&fit=crop&crop=face',
      },
      {
        'name': 'Akosua Frimpong',
        'id': 'UMaT/2025/004',
        'department': 'Engineering',
        'lastVisit': '1 day ago',
        'status': 'New',
        'avatar':
            'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=400&h=400&fit=crop&crop=face',
      },
      {
        'name': 'Kofi Asante',
        'id': 'UMaT/2025/005',
        'department': 'Science',
        'lastVisit': '5 days ago',
        'status': 'Active',
        'avatar':
            'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400&h=400&fit=crop&crop=face',
      },
    ];

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppDimensions.spacingL),
          color: Colors.white,
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search patients by name or ID',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.filter_list),
                    onPressed: () {},
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.spacingM),
              Row(
                children: [
                  _FilterChip(
                    label: 'All',
                    isSelected: _selectedFilter == 'All',
                    onSelected: () => setState(() => _selectedFilter = 'All'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Active',
                    isSelected: _selectedFilter == 'Active',
                    onSelected: () =>
                        setState(() => _selectedFilter = 'Active'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Follow-up',
                    isSelected: _selectedFilter == 'Follow-up',
                    onSelected: () =>
                        setState(() => _selectedFilter = 'Follow-up'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'New',
                    isSelected: _selectedFilter == 'New',
                    onSelected: () => setState(() => _selectedFilter = 'New'),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(AppDimensions.spacingL),
            itemCount: patients.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: AppDimensions.spacingS),
            itemBuilder: (_, i) => _PatientCard(patient: patients[i]),
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) => onSelected(),
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
      backgroundColor: AppColors.surfaceLight,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }
}

class _PatientCard extends StatelessWidget {
  final Map<String, String> patient;

  const _PatientCard({required this.patient});

  Color get _statusColor {
    switch (patient['status']) {
      case 'New':
        return AppColors.success;
      case 'Follow-up':
        return AppColors.warning;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: Image.network(
              patient['avatar']!,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 50,
                height: 50,
                color: AppColors.cardAppointment,
                child: const Icon(Icons.person, color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        patient['name']!,
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusS,
                        ),
                      ),
                      child: Text(
                        patient['status']!,
                        style: AppTypography.caption.copyWith(
                          color: _statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  patient['id']!,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.school_outlined,
                      size: 14,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      patient['department']!,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.access_time_outlined,
                      size: 14,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      patient['lastVisit']!,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.spacingS),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () =>
                Navigator.pushNamed(context, AppRouter.medicalRecords),
          ),
        ],
      ),
    );
  }
}

class _StaffConsultationRoomView extends StatelessWidget {
  const _StaffConsultationRoomView();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spacingL),
      child: Column(
        children: [
          // Current Session Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimensions.spacingL),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.secondary],
              ),
              borderRadius: BorderRadius.circular(AppDimensions.radiusL),
            ),
            child: Column(
              children: [
                const Icon(Icons.video_call, size: 48, color: Colors.white),
                const SizedBox(height: AppDimensions.spacingM),
                Text(
                  'Consultation Room',
                  style: AppTypography.heading3.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingS),
                Text(
                  'Ready to start secure consultations',
                  style: AppTypography.bodyMedium.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.spacingL),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusM,
                        ),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.videocam),
                        SizedBox(width: 8),
                        Text('Start Video Session'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.spacingL),

          // Quick Actions
          Row(
            children: [
              Expanded(
                child: _ConsultationActionCard(
                  icon: Icons.chat,
                  title: 'Text Chat',
                  subtitle: 'Message patients',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ChatListScreen()),
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.spacingM),
              Expanded(
                child: _ConsultationActionCard(
                  icon: Icons.phone,
                  title: 'Voice Call',
                  subtitle: 'Audio consultation',
                  onTap: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingL),

          // Session History
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimensions.spacingL),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recent Sessions',
                  style: AppTypography.heading4.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingM),
                _SessionHistoryTile(
                  patient: 'John Mensah',
                  time: '2 hours ago',
                  duration: '15 mins',
                  type: 'Video',
                ),
                _SessionHistoryTile(
                  patient: 'Ama Konadu',
                  time: '1 day ago',
                  duration: '20 mins',
                  type: 'Voice',
                ),
                _SessionHistoryTile(
                  patient: 'Kwesi Boateng',
                  time: '2 days ago',
                  duration: '12 mins',
                  type: 'Chat',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ConsultationActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ConsultationActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.spacingL),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.cardConsultation,
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              ),
              child: Icon(icon, color: AppColors.primary, size: 24),
            ),
            const SizedBox(height: AppDimensions.spacingS),
            Text(
              title,
              style: AppTypography.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
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
}

class _SessionHistoryTile extends StatelessWidget {
  final String patient;
  final String time;
  final String duration;
  final String type;

  const _SessionHistoryTile({
    required this.patient,
    required this.time,
    required this.duration,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingS),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.cardAppointment,
              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
            ),
            child: Icon(
              type == 'Video'
                  ? Icons.videocam
                  : type == 'Voice'
                  ? Icons.phone
                  : Icons.chat,
              color: AppColors.primary,
              size: 16,
            ),
          ),
          const SizedBox(width: AppDimensions.spacingS),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patient,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '$time • $duration',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
            ),
            child: Text(
              type,
              style: AppTypography.caption.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StaffProfileView extends StatelessWidget {
  const _StaffProfileView();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spacingL),
      child: Column(
        children: [
          // Profile Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimensions.spacingL),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.secondary],
              ),
              borderRadius: BorderRadius.circular(AppDimensions.radiusL),
            ),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: Image.network(
                    'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=400&h=400&fit=crop&crop=face',
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 80,
                      height: 80,
                      color: Colors.white.withOpacity(0.2),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingM),
                Text(
                  'Dr. Emmanuel Mensah',
                  style: AppTypography.heading3.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'General Practitioner',
                  style: AppTypography.bodyMedium.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                Text(
                  'staff@umat.edu.gh',
                  style: AppTypography.bodySmall.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingM),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _ProfileStat(label: 'Patients', value: '142'),
                    Container(
                      width: 1,
                      height: 30,
                      color: Colors.white.withOpacity(0.3),
                    ),
                    _ProfileStat(label: 'Sessions', value: '89'),
                    Container(
                      width: 1,
                      height: 30,
                      color: Colors.white.withOpacity(0.3),
                    ),
                    _ProfileStat(label: 'Experience', value: '8 yrs'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.spacingL),

          // Quick Actions
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimensions.spacingL),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Actions',
                  style: AppTypography.heading4.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingM),
                _StaffProfileTile(
                  icon: Icons.calendar_today,
                  title: 'My Schedule',
                  subtitle: 'View and manage appointments',
                  onTap: () =>
                      Navigator.pushNamed(context, AppRouter.staffSchedule),
                ),
                _StaffProfileTile(
                  icon: Icons.groups,
                  title: 'Patient Records',
                  subtitle: 'Access patient information',
                  onTap: () =>
                      Navigator.pushNamed(context, AppRouter.patientManagement),
                ),
                _StaffProfileTile(
                  icon: Icons.video_call,
                  title: 'Start Consultation',
                  subtitle: 'Begin video/voice session',
                  onTap: () {},
                ),
                _StaffProfileTile(
                  icon: Icons.assessment,
                  title: 'Reports',
                  subtitle: 'View session analytics',
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.spacingL),

          // Settings
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimensions.spacingL),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Settings',
                  style: AppTypography.heading4.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingM),
                _StaffProfileTile(
                  icon: Icons.person_outline,
                  title: 'Profile Settings',
                  subtitle: 'Update personal information',
                  onTap: () => Navigator.pushNamed(context, AppRouter.settings),
                ),
                _StaffProfileTile(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  subtitle: 'Manage notification preferences',
                  onTap: () =>
                      Navigator.pushNamed(context, AppRouter.notifications),
                ),
                _StaffProfileTile(
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  subtitle: 'Get assistance and documentation',
                  onTap: () {},
                ),
                _StaffProfileTile(
                  icon: Icons.logout,
                  title: 'Sign Out',
                  subtitle: 'Logout from staff portal',
                  onTap: () => Navigator.pushReplacementNamed(
                    context,
                    AppRouter.healthcareSignIn,
                  ),
                  isDestructive: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.heading3.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
}

class _StaffProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  const _StaffProfileTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDestructive
              ? AppColors.error.withOpacity(0.1)
              : AppColors.cardConsultation,
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        ),
        child: Icon(
          icon,
          color: isDestructive ? AppColors.error : AppColors.primary,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: AppTypography.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
          color: isDestructive ? AppColors.error : null,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: isDestructive ? AppColors.error : AppColors.textTertiary,
      ),
      onTap: onTap,
    );
  }
}
