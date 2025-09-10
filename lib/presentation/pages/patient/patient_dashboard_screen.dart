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
import '../../../presentation/widgets/cards/healthcare_service_card.dart';
import '../../../presentation/widgets/cards/health_tip_card.dart';
import '../notifications/notifications_screen.dart';

class PatientDashboardScreen extends StatefulWidget {
  const PatientDashboardScreen({super.key});

  @override
  State<PatientDashboardScreen> createState() => _PatientDashboardScreenState();
}

class _PatientDashboardScreenState extends State<PatientDashboardScreen> {
  late final AppointmentRepository _appointmentRepository;
  List<dynamic> _upcomingAppointments = [];
  bool _isLoadingAppointments = true;
  int _unreadNotifications = 0;

  @override
  void initState() {
    super.initState();
    _appointmentRepository = context.read<SupabaseAppointmentRepository>();
    _loadUpcomingAppointments();
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

  Future<void> _loadUpcomingAppointments() async {
    try {
      setState(() {
        _isLoadingAppointments = true;
      });

      final state = context.read<AuthBloc>().state;
      if (state is AuthAuthenticated) {
        final result = await _appointmentRepository.getPatientAppointments(
          patientId: state.user.id,
          status: AppointmentStatus.scheduled,
        );

        result.fold(
          (failure) {
            print('❌ Failed to load appointments: ${failure.message}');
            setState(() {
              _upcomingAppointments = [];
              _isLoadingAppointments = false;
            });
          },
          (appointments) {
            print('✅ Loaded ${appointments.length} upcoming appointments');
            setState(() {
              _upcomingAppointments = appointments;
              _isLoadingAppointments = false;
            });
          },
        );
      }
    } catch (e) {
      print('❌ Error loading appointments: $e');
      setState(() {
        _upcomingAppointments = [];
        _isLoadingAppointments = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthAuthenticated) {
              return CustomScrollView(
                slivers: [
                  _buildAppBar(context, state.user.firstName),
                  SliverPadding(
                    padding: const EdgeInsets.all(AppDimensions.spacingM),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildWelcomeCard(state.user.firstName),
                        const SizedBox(height: AppDimensions.spacingL),
                        _buildQuickActions(),
                        const SizedBox(height: AppDimensions.spacingL),
                        _buildUpcomingAppointments(),
                        const SizedBox(height: AppDimensions.spacingL),
                        _buildHealthServices(),
                        const SizedBox(height: AppDimensions.spacingL),
                        _buildHealthTips(),
                        const SizedBox(height: AppDimensions.spacingL),
                        _buildEmergencySection(),
                      ]),
                    ),
                  ),
                ],
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, String firstName) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.secondary],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.spacingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Welcome back,',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textLight,
                    ),
                  ),
                  Text(
                    firstName,
                    style: AppTypography.heading2.copyWith(
                      color: AppColors.textLight,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      actions: [
        Stack(
          children: [
            IconButton(
              icon: const Icon(
                Icons.notifications_outlined,
                color: Colors.white,
              ),
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
          icon: const Icon(Icons.person_outline, color: Colors.white),
          onPressed: () => Navigator.pushNamed(context, AppRouter.profile),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildWelcomeCard(String firstName) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingL),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.cardAppointment, AppColors.cardConsultation],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardAppointment.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How are you feeling today?',
                  style: AppTypography.heading4.copyWith(
                    color: AppColors.textLight,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingS),
                Text(
                  'Book an appointment or chat with a healthcare provider',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(AppDimensions.spacingM),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
            child: const Icon(
              Icons.health_and_safety,
              color: Colors.white,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: AppTypography.heading4.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingM),
        Row(
          children: [
            Expanded(
              child: HealthcareServiceCard(
                title: 'Book Appointment',
                description: 'Schedule a consultation',
                icon: Icons.calendar_today_outlined,
                color: AppColors.cardAppointment,
                onTap: () =>
                    Navigator.pushNamed(context, AppRouter.appointmentBooking),
              ),
            ),
            const SizedBox(width: AppDimensions.spacingM),
            Expanded(
              child: HealthcareServiceCard(
                title: 'E-Consultation',
                description: 'Video or chat consultation',
                icon: Icons.video_call_outlined,
                color: AppColors.cardConsultation,
                onTap: () =>
                    Navigator.pushNamed(context, AppRouter.eConsultation),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUpcomingAppointments() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Upcoming Appointments',
              style: AppTypography.heading4.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRouter.appointmentHistory);
              },
              child: Text(
                'View All',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingM),
        if (_isLoadingAppointments)
          const Center(child: CircularProgressIndicator())
        else if (_upcomingAppointments.isEmpty)
          Container(
            padding: const EdgeInsets.all(AppDimensions.spacingL),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 48,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(height: AppDimensions.spacingM),
                Text(
                  'No upcoming appointments',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textTertiary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingS),
                Text(
                  'Book your first appointment to get started',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textTertiary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.spacingM),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    AppRouter.appointmentBooking,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Book Appointment'),
                ),
              ],
            ),
          )
        else
          ..._upcomingAppointments
              .take(3)
              .map(
                (appointment) => Padding(
                  padding: const EdgeInsets.only(
                    bottom: AppDimensions.spacingS,
                  ),
                  child: _buildAppointmentCard(appointment),
                ),
              )
              .toList(),
      ],
    );
  }

  String _formatAppointmentDate(DateTime date) {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final appointmentDate = DateTime(date.year, date.month, date.day);

    if (appointmentDate.isAtSameMomentAs(
      DateTime(now.year, now.month, now.day),
    )) {
      return 'Today';
    } else if (appointmentDate.isAtSameMomentAs(tomorrow)) {
      return 'Tomorrow';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Widget _buildAppointmentCard(dynamic appointment) {
    final isToday =
        _formatAppointmentDate(appointment.appointmentDate) == 'Today';
    final isCurrentTime = _isAppointmentTimeNow(appointment);
    final bool isJoinable = appointment.status == AppointmentStatus.scheduled;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.doctorName ?? 'Doctor',
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingS),
                    Text(
                      appointment.department ?? 'General Practice',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingS),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatAppointmentDate(appointment.appointmentDate),
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.spacingM),
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          appointment.appointmentTime,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (isToday && isCurrentTime)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacingS,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                  ),
                  child: Text(
                    'LIVE',
                    style: AppTypography.caption.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          if (isJoinable) ...[
            const SizedBox(height: AppDimensions.spacingM),
            const Divider(),
            const SizedBox(height: AppDimensions.spacingS),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _joinVideoCall(appointment),
                    icon: const Icon(Icons.video_call, color: Colors.white),
                    label: const Text('Join Video Call'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppDimensions.spacingS,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingS),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _joinChat(appointment),
                    icon: const Icon(Icons.chat, color: AppColors.primary),
                    label: const Text('Chat Only'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(
                        vertical: AppDimensions.spacingS,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  bool _isAppointmentTimeNow(dynamic appointment) {
    final now = DateTime.now();
    final appointmentTime = appointment.appointmentTime;

    if (appointmentTime == null) return false;

    // Parse appointment time (assuming format like "14:30:00")
    final timeParts = appointmentTime.split(':');
    if (timeParts.length < 2) return false;

    final appointmentHour = int.tryParse(timeParts[0]) ?? 0;
    final appointmentMinute = int.tryParse(timeParts[1]) ?? 0;

    // Check if current time is within 30 minutes before or after appointment time
    final appointmentDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      appointmentHour,
      appointmentMinute,
    );

    final difference = now.difference(appointmentDateTime).abs();
    return difference.inMinutes <= 30;
  }

  void _joinVideoCall(dynamic appointment) {
    final channelName = 'consultation_${appointment.id}';

    Navigator.pushNamed(
      context,
      AppRouter.consultationRoom,
      arguments: {
        'appointment': appointment,
        'patientName': 'You', // Patient is joining
        'appointmentTime': appointment.appointmentTime,
        'reason': appointment.reasonForVisit,
        'symptoms': appointment.symptoms,
        'isPatient': true,
      },
    );

    print('🎥 Patient joining video call channel: $channelName');
  }

  void _joinChat(dynamic appointment) {
    // Navigate to chat screen for this appointment
    Navigator.pushNamed(context, AppRouter.eConsultation);

    print('💬 Patient joining chat for appointment: ${appointment.id}');
  }

  Widget _buildHealthServices() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Health Services',
          style: AppTypography.heading4.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingM),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              HealthcareServiceCard(
                title: 'Lab Results',
                description: 'View your test results',
                icon: Icons.science_outlined,
                color: AppColors.cardLabResult,
                onTap: () {},
              ),
              const SizedBox(width: AppDimensions.spacingM),
              HealthcareServiceCard(
                title: 'Prescriptions',
                description: 'Manage medications',
                icon: Icons.medication_outlined,
                color: AppColors.cardPrescription,
                onTap: () {},
              ),
              const SizedBox(width: AppDimensions.spacingM),
              HealthcareServiceCard(
                title: 'Health Education',
                description: 'Learn about health',
                icon: Icons.school_outlined,
                color: AppColors.cardMedicalRecord,
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHealthTips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Health Tips',
          style: AppTypography.heading4.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingM),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              HealthTipCard(
                title: 'Stay Hydrated',
                description: 'Drink 8 glasses of water daily',
                category: 'Wellness',
              ),
              const SizedBox(width: AppDimensions.spacingM),
              HealthTipCard(
                title: 'Exercise Regularly',
                description: '30 minutes of daily activity',
                category: 'Fitness',
              ),
              const SizedBox(width: AppDimensions.spacingM),
              HealthTipCard(
                title: 'Get Enough Sleep',
                description: '7-9 hours of quality sleep',
                category: 'Sleep',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmergencySection() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingL),
      decoration: BoxDecoration(
        color: AppColors.cardEmergency,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: AppColors.emergency.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.spacingS),
            decoration: BoxDecoration(
              color: AppColors.emergency,
              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
            ),
            child: const Icon(Icons.emergency, color: Colors.white, size: 24),
          ),
          const SizedBox(width: AppDimensions.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Emergency Contact',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Call for immediate assistance',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Handle emergency call
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.emergency,
              foregroundColor: Colors.white,
            ),
            child: const Text('Call'),
          ),
        ],
      ),
    );
  }
}
