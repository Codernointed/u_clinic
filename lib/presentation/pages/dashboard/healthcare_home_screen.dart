import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/routes/app_router.dart';
import '../../providers/auth/auth_bloc.dart';
import '../../providers/auth/auth_state.dart';
import '../../widgets/cards/healthcare_service_card.dart';
import '../appointments/appointment_booking_screen.dart';
import '../records/medical_records_screen.dart';
import '../profile/profile_screen.dart';
import '../../../domain/enums/consultation_type.dart';

class HealthcareHomeScreen extends StatefulWidget {
  const HealthcareHomeScreen({super.key});

  @override
  State<HealthcareHomeScreen> createState() => _HealthcareHomeScreenState();
}

class _HealthcareHomeScreenState extends State<HealthcareHomeScreen> {
  int _selectedIndex = 0;

  final List<String> _navLabels = ['Home', 'Records', 'Chat', 'Profile'];
  final List<IconData> _navIcons = [
    Icons.home_outlined,
    Icons.folder_outlined,
    Icons.chat_outlined,
    Icons.person_outlined,
  ];
  final List<IconData> _navActiveIcons = [
    Icons.home,
    Icons.folder,
    Icons.chat,
    Icons.person,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildHomeContent(),
            _buildMedicalRecordsContent(),
            _buildChatContent(),
            _buildProfileContent(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textTertiary,
        backgroundColor: Colors.white,
        elevation: 8,
        items: List.generate(_navLabels.length, (index) {
          return BottomNavigationBarItem(
            icon: Icon(_navIcons[index]),
            activeIcon: Icon(_navActiveIcons[index]),
            label: _navLabels[index],
          );
        }),
      ),
    );
  }

  Widget _buildHomeContent() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        String userName = 'Student';
        if (state is AuthAuthenticated) {
          userName = state.user.firstName;
        }

        return Column(
          children: [
            // App Bar
            Container(
              height: 120,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'UMaT E-Health',
                        style: AppTypography.heading3.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.notifications_outlined,
                              color: Colors.white,
                            ),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.person_outline,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.spacingM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeCard(userName),
                    const SizedBox(height: AppDimensions.spacingL),
                    _buildQuickActions(),
                    const SizedBox(height: AppDimensions.spacingL),
                    _buildUpcomingAppointments(),
                    const SizedBox(height: AppDimensions.spacingL),
                    _buildHealthServices(),
                    const SizedBox(height: AppDimensions.spacingL),
                    _buildEmergencySection(),
                    const SizedBox(
                      height: AppDimensions.spacingL,
                    ), // Extra bottom padding
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildWelcomeCard(String firstName) {
    final now = DateTime.now();
    final greeting = now.hour < 12
        ? 'Good Morning'
        : now.hour < 17
        ? 'Good Afternoon'
        : 'Good Evening';

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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting, $firstName!',
                  style: AppTypography.heading3.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingS),
                Text(
                  'How can we help you today?',
                  style: AppTypography.bodyMedium.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(AppDimensions.spacingM),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
            child: const Icon(Icons.favorite, color: Colors.white, size: 32),
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
          style: AppTypography.heading2.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingM),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                'Book Appointment',
                Icons.calendar_today,
                AppColors.cardAppointment,
                () =>
                    Navigator.pushNamed(context, AppRouter.appointmentBooking),
              ),
            ),
            const SizedBox(width: AppDimensions.spacingM),
            Expanded(
              child: _buildActionCard(
                'E-Consultation',
                Icons.video_call,
                AppColors.cardConsultation,
                () => _showConsultationOptions(),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingM),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                'Medical Records',
                Icons.folder_open,
                AppColors.cardMedicalRecord,
                () => Navigator.pushNamed(context, AppRouter.medicalRecords),
              ),
            ),
            const SizedBox(width: AppDimensions.spacingM),
            Expanded(
              child: _buildActionCard(
                'Emergency',
                Icons.local_hospital,
                AppColors.emergency,
                () => _showEmergencyDialog(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        padding: const EdgeInsets.all(AppDimensions.spacingM),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primary, size: 28),
            const SizedBox(height: AppDimensions.spacingS),
            Text(
              title,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
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
              style: AppTypography.heading2.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.pushNamed(context, AppRouter.appointmentHistory),
              child: Text(
                'View All',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
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
              Container(
                padding: const EdgeInsets.all(AppDimensions.spacingS),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                ),
                child: const Icon(
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
                      'Dr. Sarah Johnson',
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'General Practice',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      'Tomorrow, 10:00 AM',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: AppColors.textTertiary,
                size: 16,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHealthServices() {
    final services = [
      {
        'title': 'Lab Results',
        'description': 'View your test results',
        'icon': Icons.science,
        'color': AppColors.cardLabResult,
        'onTap': () => Navigator.pushNamed(context, AppRouter.medicalRecords),
      },
      {
        'title': 'Prescriptions',
        'description': 'Manage your medications',
        'icon': Icons.medication,
        'color': AppColors.cardPrescription,
        'onTap': () => Navigator.pushNamed(context, AppRouter.medicalRecords),
      },
      {
        'title': 'Health Education',
        'description': 'Learn about health topics',
        'icon': Icons.school,
        'color': AppColors.cardConsultation,
        'onTap': () => Navigator.pushNamed(context, AppRouter.healthEducation),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Health Services',
          style: AppTypography.heading2.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingM),
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: services.length,
            separatorBuilder: (context, index) =>
                const SizedBox(width: AppDimensions.spacingM),
            itemBuilder: (context, index) {
              final service = services[index];
              return HealthcareServiceCard(
                title: service['title'] as String,
                description: service['description'] as String,
                icon: service['icon'] as IconData,
                color: service['color'] as Color,
                onTap: service['onTap'] as VoidCallback,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmergencySection() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingL),
      decoration: BoxDecoration(
        color: AppColors.emergency.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(color: AppColors.emergency.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.spacingM),
            decoration: BoxDecoration(
              color: AppColors.emergency,
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
            child: const Icon(Icons.emergency, color: Colors.white, size: 32),
          ),
          const SizedBox(width: AppDimensions.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Emergency Contact',
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.emergency,
                  ),
                ),
                Text(
                  'Tap to call UMaT clinic',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _showEmergencyDialog(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.emergency,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              ),
            ),
            child: const Text('Call'),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalRecordsContent() {
    return const MedicalRecordsScreen();
  }

  Widget _buildChatContent() {
    return const Center(child: Text('Chat - Coming Soon'));
  }

  Widget _buildProfileContent() {
    return const ProfileScreen();
  }

  void _showConsultationOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('E-Consultation Options'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.video_call, color: AppColors.primary),
              title: const Text('Video Consultation'),
              subtitle: const Text('Face-to-face video call with doctor'),
              onTap: () {
                Navigator.pop(context);
                _startConsultation(ConsultationType.video);
              },
            ),
            ListTile(
              leading: const Icon(Icons.call, color: AppColors.primary),
              title: const Text('Voice Consultation'),
              subtitle: const Text('Audio-only consultation'),
              onTap: () {
                Navigator.pop(context);
                _startConsultation(ConsultationType.voice);
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat, color: AppColors.primary),
              title: const Text('Text Consultation'),
              subtitle: const Text('Chat-based consultation'),
              onTap: () {
                Navigator.pop(context);
                _startConsultation(ConsultationType.text);
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

  void _startConsultation(ConsultationType type) {
    // For demo purposes, navigate to consultation screen
    Navigator.pushNamed(
      context,
      AppRouter.eConsultation,
      arguments: {
        'appointmentId': 'demo-123',
        'doctorName': 'Dr. Sarah Johnson',
        'department': 'General Practice',
        'consultationType': type,
      },
    );
  }

  void _showEmergencyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Emergency Contact'),
        content: const Text(
          'Are you sure you want to call the UMaT clinic emergency line?\n\n📞 +233-123-456-789',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Here you would implement the actual phone call
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Calling emergency line...')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.emergency,
            ),
            child: const Text('Call Now'),
          ),
        ],
      ),
    );
  }
}
