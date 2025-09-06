import 'package:flutter/material.dart';
import 'package:u_clinic/core/routes/fade_page_route.dart';
import 'package:u_clinic/domain/enums/consultation_type.dart';
import 'package:u_clinic/presentation/pages/dashboard/home_screen.dart';
import 'package:u_clinic/presentation/pages/appointments/appointment_booking_screen.dart';
import 'package:u_clinic/presentation/pages/appointments/appointment_history_screen.dart';
import 'package:u_clinic/presentation/pages/records/medical_records_screen.dart';
import 'package:u_clinic/presentation/pages/records/medical_record_details_screen.dart';
import 'package:u_clinic/presentation/pages/consultation/e_consultation_screen.dart';
import 'package:u_clinic/presentation/pages/consultation/consultation_room_screen.dart';
import 'package:u_clinic/presentation/pages/education/health_education_screen.dart';
import 'package:u_clinic/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:u_clinic/presentation/pages/notifications/notifications_screen.dart';
import 'package:u_clinic/presentation/pages/chat/chat_list_screen.dart';
import 'package:u_clinic/presentation/pages/profile/settings_screen.dart'
    as patient_settings;
import 'package:u_clinic/presentation/screens/settings/change_password_screen.dart';
import 'package:u_clinic/presentation/screens/settings/deactivate_account_screen.dart';
import 'package:u_clinic/presentation/screens/settings/delete_account_screen.dart';
import 'package:u_clinic/presentation/screens/settings/two_factor_authentication_screen.dart';
import 'package:u_clinic/presentation/screens/splash/splash_screen.dart';
import 'package:u_clinic/presentation/screens/article_details_screen.dart';
import 'package:u_clinic/presentation/screens/categories_screen.dart';
import 'package:u_clinic/presentation/screens/inspirations_screen.dart';
import 'package:u_clinic/presentation/pages/auth/healthcare_sign_in_screen.dart';
import 'package:u_clinic/presentation/pages/auth/healthcare_sign_up_screen.dart';
import 'package:u_clinic/presentation/pages/patient/patient_dashboard_screen.dart';
import 'package:u_clinic/presentation/pages/staff/staff_dashboard_screen.dart';
import 'package:u_clinic/presentation/pages/admin/admin_dashboard_screen.dart';
import 'package:u_clinic/presentation/pages/profile/profile_screen.dart';
import 'package:u_clinic/core/services/supabase_service.dart';

class AppRouter {
  // Core routes
  static const String splash = '/';
  static const String onboarding = '/onboarding';

  // Auth routes
  static const String healthcareSignIn = '/healthcare-sign-in';
  static const String healthcareSignUp = '/healthcare-sign-up';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';

  // Patient routes
  static const String patientDashboard = '/patient/dashboard';
  static const String appointmentBooking = '/patient/appointments/book';
  static const String appointmentHistory = '/patient/appointments/history';
  static const String medicalRecords = '/patient/medical-records';
  static const String prescriptions = '/patient/prescriptions';
  static const String consultations = '/patient/consultations';
  static const String labResults = '/patient/lab-results';
  static const String healthEducation = '/health/education';
  static const String notifications = '/notifications';
  static const String appointmentDetails = '/patient/appointments/details';
  static const String settings = '/settings';

  // New route constants for navigation
  static const String eConsultation = '/e-consultation';
  static const String profile = '/profile';
  static const String chatList = '/chat';

  // Staff routes
  static const String staffDashboard = '/staff/dashboard';
  static const String staffSchedule = '/staff/schedule';
  static const String patientManagement = '/staff/patients';
  static const String consultationRoom = '/staff/consultation';

  // Admin routes
  static const String adminDashboard = '/admin/dashboard';
  static const String userManagement = '/admin/users';
  static const String systemAnalytics = '/admin/analytics';
  static const String contentManagement = '/admin/content';

  // Legacy routes (to be removed)
  static const String home = '/home';
  static const String generalAilments = '/general-ailments';
  static const String changePassword = '/change-password';
  static const String twoFactorAuth = '/two-factor-auth';
  static const String deactivateAccount = '/deactivate-account';
  static const String deleteAccount = '/delete-account';
  static const String articleDetails = '/article-details';
  static const String categories = '/categories';
  static const String inspirations = '/inspirations';
  static const String eventLineup = '/event-lineup';
  static const String symptomChecker = '/symptom-checker';
  static const String symptomCheckerSymptoms = '/symptom-checker-symptoms';
  static const String symptomCheckerResults = '/symptom-checker-results';
  static const String symptomCheckerConditionDetails =
      '/symptom-checker-condition-details';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    String? currentRole;
    try {
      // Attempt to read role from auth metadata if available
      final user = SupabaseService.instance.currentUser;
      currentRole = user?.userMetadata?['role'] as String?;
    } catch (_) {}

    switch (settings.name) {
      case splash:
        return FadePageRoute(child: const SplashScreen());
      case onboarding:
        return FadePageRoute(child: const OnboardingScreen());
      case healthcareSignIn:
        return FadePageRoute(child: const HealthcareSignInScreen());
      case healthcareSignUp:
        return FadePageRoute(child: const HealthcareSignUpScreen());
      // case forgotPassword:
      //   return FadePageRoute(child: const ForgotPasswordScreen());
      case patientDashboard:
        if (currentRole == 'staff' || currentRole == 'admin') {
          return FadePageRoute(child: const StaffDashboardScreen());
        }
        return FadePageRoute(child: const PatientDashboardScreen());
      case appointmentBooking:
        return FadePageRoute(child: const AppointmentBookingScreen());
      case appointmentHistory:
        return FadePageRoute(child: const AppointmentHistoryScreen());
      case medicalRecords:
        return FadePageRoute(child: const MedicalRecordsScreen());
      case appointmentDetails:
        final args = settings.arguments as Map<String, dynamic>?;
        final id = args != null ? (args['id']?.toString() ?? '1') : '1';
        return FadePageRoute(child: MedicalRecordDetailsScreen(recordId: id));
      case consultations:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args != null) {
          return FadePageRoute(
            child: EConsultationScreen(
              appointmentId: args['appointmentId'] as String,
              doctorName: args['doctorName'] as String,
              department: args['department'] as String,
              consultationType: args['consultationType'] as ConsultationType,
            ),
          );
        }
        // Fallback for when no arguments are provided
        return FadePageRoute(
          child: EConsultationScreen(
            appointmentId: 'demo-123',
            doctorName: 'Dr. Sarah Johnson',
            department: 'General Practice',
            consultationType: ConsultationType.video,
          ),
        );
      case eConsultation:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args != null) {
          return FadePageRoute(
            child: EConsultationScreen(
              appointmentId: args['appointmentId'] as String,
              doctorName: args['doctorName'] as String,
              department: args['department'] as String,
              consultationType: args['consultationType'] as ConsultationType,
            ),
          );
        }
        // Fallback for when no arguments are provided
        return FadePageRoute(
          child: EConsultationScreen(
            appointmentId: 'demo-123',
            doctorName: 'Dr. Sarah Johnson',
            department: 'General Practice',
            consultationType: ConsultationType.video,
          ),
        );
      case profile:
        return FadePageRoute(child: const ProfileScreen());
      case prescriptions:
        return FadePageRoute(
          child: Scaffold(
            appBar: AppBar(title: const Text('Prescriptions')),
            body: const Center(child: Text('Prescriptions Screen')),
          ),
        );
      case labResults:
        return FadePageRoute(
          child: Scaffold(
            appBar: AppBar(title: const Text('Lab Results')),
            body: const Center(child: Text('Lab Results Screen')),
          ),
        );
      case healthEducation:
        return FadePageRoute(child: const HealthEducationScreen());
      case notifications:
        return FadePageRoute(child: const NotificationsScreen());
      case chatList:
        return FadePageRoute(child: const ChatListScreen());
      case staffDashboard:
        if (currentRole == 'patient') {
          return FadePageRoute(child: const PatientDashboardScreen());
        }
        return FadePageRoute(child: const StaffDashboardScreen());
      case consultationRoom:
        final args = settings.arguments as Map<String, dynamic>?;
        return FadePageRoute(child: ConsultationRoomScreen(arguments: args));
      case adminDashboard:
        return FadePageRoute(child: const AdminDashboardScreen());
      case AppRouter.settings:
        return FadePageRoute(child: const patient_settings.SettingsScreen());
      case home:
        return FadePageRoute(child: const HomeScreen());
      case generalAilments:
        return FadePageRoute(
          child: const Scaffold(
            body: Center(child: Text('General Ailments Screen')),
          ),
        );
      case changePassword:
        return FadePageRoute(child: const ChangePasswordScreen());
      case twoFactorAuth:
        return FadePageRoute(child: const TwoFactorAuthenticationScreen());
      case deactivateAccount:
        return FadePageRoute(child: const DeactivateAccountScreen());
      case deleteAccount:
        return FadePageRoute(child: const DeleteAccountScreen());
      case articleDetails:
        return FadePageRoute(child: const ArticleDetailsScreen());
      case categories:
        return FadePageRoute(child: const CategoriesScreen());
      case inspirations:
        return FadePageRoute(child: const InspirationsScreen());
      case eventLineup:
        return FadePageRoute(
          child: const Scaffold(
            body: Center(child: Text('Event Lineup Screen')),
          ),
        );
      case symptomChecker:
        return FadePageRoute(
          child: const Scaffold(
            body: Center(child: Text('Symptom Checker Screen')),
          ),
        );
      case symptomCheckerSymptoms:
        return FadePageRoute(
          child: const Scaffold(
            body: Center(child: Text('Symptom Checker Symptoms Screen')),
          ),
        );
      case symptomCheckerResults:
        return FadePageRoute(
          child: const Scaffold(
            body: Center(child: Text('Symptom Checker Results Screen')),
          ),
        );
      case symptomCheckerConditionDetails:
        final args = settings.arguments as Map<String, dynamic>;
        final condition = args['condition'] as String;
        return FadePageRoute(
          settings: settings,
          child: Scaffold(
            body: Center(
              child: Text('Symptom Checker Condition Details: $condition'),
            ),
          ),
        );
      // case verifyOtp:
      //   final args = settings.arguments as Map<String, dynamic>;
      //   return FadePageRoute(
      //     settings: settings,
      //     child: VerifyOtpScreen(
      //       phoneNumber: args['phoneNumber'] as String,
      //       isSignIn: args['isSignIn'] as bool,
      //       name: args['name'] as String?,
      //     ),
      // );
      default:
        return FadePageRoute(
          child: Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
