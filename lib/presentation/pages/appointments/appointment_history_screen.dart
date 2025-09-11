import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:u_clinic/core/routes/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/entities/appointment.dart';
import '../../../domain/repositories/appointment_repository.dart';
import '../../../data/repositories/supabase_appointment_repository.dart';
import '../../../presentation/providers/auth/auth_bloc.dart';
import '../../../presentation/providers/auth/auth_state.dart';

class AppointmentHistoryScreen extends StatefulWidget {
  const AppointmentHistoryScreen({super.key});

  @override
  State<AppointmentHistoryScreen> createState() =>
      _AppointmentHistoryScreenState();
}

class _AppointmentHistoryScreenState extends State<AppointmentHistoryScreen> {
  late final AppointmentRepository _appointmentRepository;
  List<Appointment> _appointments = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _appointmentRepository = context.read<SupabaseAppointmentRepository>();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final state = context.read<AuthBloc>().state;
      if (state is AuthAuthenticated) {
        final result = await _appointmentRepository.getPatientAppointments(
          patientId: state.user.id,
        );

        result.fold(
          (failure) {
            setState(() {
              _error = failure.message;
              _isLoading = false;
            });
          },
          (appointments) {
            setState(() {
              _appointments = appointments;
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
          'Appointments',
          style: AppTypography.heading3.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadAppointments,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error loading appointments',
              style: AppTypography.bodyLarge.copyWith(color: Colors.red),
            ),
            const SizedBox(height: AppDimensions.spacingM),
            ElevatedButton(
              onPressed: _loadAppointments,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppDimensions.spacingM),
            Text(
              'No appointments found',
              style: AppTypography.heading3.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingS),
            Text(
              'Book your first appointment to get started',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingL),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRouter.appointmentBooking);
              },
              child: const Text('Book Appointment'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAppointments,
      child: ListView.separated(
        padding: const EdgeInsets.all(AppDimensions.spacingL),
        itemCount: _appointments.length,
        separatorBuilder: (_, __) =>
            const SizedBox(height: AppDimensions.spacingM),
        itemBuilder: (context, index) {
          final appointment = _appointments[index];
          return _buildAppointmentCard(appointment);
        },
      ),
    );
  }

  Widget _buildAppointmentCard(Appointment appointment) {
    final isUpcoming = appointment.isUpcoming;
    final isToday = appointment.isToday;
    final isLiveWindow = _isAppointmentTimeNow(appointment);

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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isUpcoming ? AppColors.primary : AppColors.textSecondary,
              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
            ),
            child: Icon(
              isUpcoming ? Icons.calendar_today : Icons.check_circle,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: AppDimensions.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: AppDimensions.spacingS,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      isUpcoming ? 'Upcoming' : 'Completed',
                      style: AppTypography.bodySmall.copyWith(
                        color: isUpcoming
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '• ${appointment.departmentName ?? 'General'}',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (isToday)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'TODAY',
                          style: AppTypography.bodySmall.copyWith(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    if (isLiveWindow)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'LIVE',
                          style: AppTypography.bodySmall.copyWith(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  appointment.doctorName,
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  appointment.formattedDateTime,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                if (appointment.reasonForVisit.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Reason: ${appointment.reasonForVisit}',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    AppRouter.appointmentDetails,
                    arguments: {'id': appointment.id},
                  );
                },
                child: const Text('Details'),
              ),
              if (isUpcoming) ...[
                const SizedBox(height: 4),
                ElevatedButton.icon(
                  onPressed: () => _joinVideoCall(appointment),
                  icon: const Icon(Icons.videocam, size: 18, color: Colors.white),
                  label: const Text('Join'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 32),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: const StadiumBorder(),
                    textStyle: AppTypography.bodySmall,
                  ),
                ),
                const SizedBox(height: 4),
                TextButton(
                  onPressed: () => _cancelAppointment(appointment),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                    minimumSize: const Size(0, 32),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: const Text('Cancel'),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  bool _isAppointmentTimeNow(Appointment appointment) {
    // Within ±30 minutes of scheduled time on the same day
    final now = DateTime.now();
    final isSameDay = appointment.appointmentDate.year == now.year &&
        appointment.appointmentDate.month == now.month &&
        appointment.appointmentDate.day == now.day;
    if (!isSameDay) return false;

    final timeParts = appointment.appointmentTime.split(':');
    if (timeParts.length < 2) return false;

    final appointmentHour = int.tryParse(timeParts[0]) ?? 0;
    final appointmentMinute = int.tryParse(timeParts[1]) ?? 0;
    final appointmentDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      appointmentHour,
      appointmentMinute,
    );
    final diff = now.difference(appointmentDateTime).abs();
    return diff.inMinutes <= 30;
  }

  void _joinVideoCall(Appointment appointment) {
    final channelName = 'consultation_${appointment.id}';
    Navigator.pushNamed(
      context,
      AppRouter.consultationRoom,
      arguments: {
        'appointment': appointment,
        'patientName': 'You',
        'appointmentTime': appointment.appointmentTime,
        'reason': appointment.reasonForVisit,
        'symptoms': appointment.symptoms,
        'isPatient': true,
      },
    );
    // ignore: avoid_print
    print('🎥 Patient joining video call channel: $channelName');
  }

  Future<void> _cancelAppointment(Appointment appointment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Appointment'),
        content: Text(
          'Are you sure you want to cancel your appointment with ${appointment.doctorName} on ${appointment.formattedDate}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Cancel Appointment'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final result = await _appointmentRepository.cancelAppointment(
          appointmentId: appointment.id,
          reason: 'Cancelled by patient',
        );

        result.fold(
          (failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Error cancelling appointment: ${failure.message}',
                ),
                backgroundColor: Colors.red,
              ),
            );
          },
          (_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Appointment cancelled successfully'),
                backgroundColor: Colors.green,
              ),
            );
            _loadAppointments(); // Refresh the list
          },
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error cancelling appointment: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
