import '../config/app_config.dart';

class SupabaseConstants {
  // Supabase Project Configuration
  static String get supabaseUrl => AppConfig.supabaseUrl;
  static String get supabaseAnonKey => AppConfig.supabaseAnonKey;
  
  // Database Table Names
  static const String usersTable = 'users';
  static const String appointmentsTable = 'appointments';
  static const String medicalRecordsTable = 'medical_records';
  static const String prescriptionsTable = 'prescriptions';
  static const String labResultsTable = 'lab_results';
  static const String doctorsTable = 'doctors';
  static const String departmentsTable = 'departments';
  static const String notificationsTable = 'notifications';
  static const String healthEducationTable = 'health_education';
  
  // Storage Buckets
  static const String medicalDocumentsBucket = 'medical_documents';
  static const String profileImagesBucket = 'profile_images';
  static const String prescriptionImagesBucket = 'prescription_images';
  
  // Row Level Security Policies
  static const String rlsEnabled = 'ENABLE ROW LEVEL SECURITY';
  
  // Authentication Settings
  static const String authRedirectUrl = 'io.supabase.flutter://login-callback/';
  static const String authCallbackUrl = 'io.supabase.flutter://login-callback/';
  
  // Real-time Channels
  static const String appointmentsChannel = 'appointments';
  static const String notificationsChannel = 'notifications';
  static const String medicalRecordsChannel = 'medical_records';
  
  // Validation
  static bool get isConfigured => AppConfig.isConfigurationValid;
  
  // Error Messages
  static String get configurationErrorMessage => 
      'Supabase is not properly configured. Please check your credentials in AppConfig.';
}
