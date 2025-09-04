class AppConstants {
  // App Info
  static const String appName = 'UMaT E-Health';
  static const String appVersion = '1.0.0';

  // API Configuration
  static const String baseUrl = 'https://api.umat-ehealth.edu.gh';
  static const String apiVersion = 'v1';
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String onboardingKey = 'onboarding_completed';
  static const String biometricKey = 'biometric_enabled';

  // Emergency
  static const String emergencyNumber = '+233-XXX-XXX-XXX';
  static const String clinicAddress = 'UMaT Medical Center, University Campus';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // File Upload
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'gif'];
  static const List<String> allowedDocumentTypes = ['pdf', 'doc', 'docx'];

  // Appointment
  static const int appointmentSlotDuration = 30; // minutes
  static const int maxAdvanceBookingDays = 30;
  static const int minAdvanceBookingHours = 2;

  // Security
  static const int otpExpiryMinutes = 5;
  static const int maxLoginAttempts = 3;
  static const int passwordMinLength = 8;

  // Feature Flags
  static const bool enableBiometric = true;
  static const bool enableVideoCall = true;
  static const bool enablePushNotifications = true;

  // University Specific
  static const String universityName = 'University of Mines and Technology';
  static const String universityCode = 'UMaT';
  static const List<String> departments = [
    'Computer Science',
    'Mining Engineering',
    'Electrical Engineering',
    'Mechanical Engineering',
    'Civil Engineering',
    'Environmental Engineering',
    'Geological Engineering',
    'Geomatic Engineering',
    'Chemical Engineering',
    'Petroleum Engineering',
    'Mathematics',
    'General Studies',
  ];

  static const List<String> staffDepartments = [
    'General Practice',
    'Internal Medicine',
    'Pediatrics',
    'Gynecology',
    'Psychiatry',
    'Dentistry',
    'Nursing',
    'Pharmacy',
    'Laboratory',
    'Administration',
  ];
}
