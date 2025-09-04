class AppConfig {
  // App Information
  static const String appName = 'UMaT E-Health';
  static const String appVersion = '1.0.0';
  static const String appDescription =
      'Interactive E-Health Application for Universities';

  // Supabase Configuration - UMaT E-Health Fresh Project
  static const String supabaseUrl = 'https://ioilwqmrstcmrbtcpzbf.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlvaWx3cW1yc3RjbXJidGNwemJmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY5MjIzOTcsImV4cCI6MjA3MjQ5ODM5N30.UzdhKIXCjChZaux0l0pNigYmpQKtJqz7ZP-5ydrLFgk';

  // Example Supabase URLs (replace with your actual values):
  // supabaseUrl: https://abcdefghijklmnop.supabase.co
  // supabaseAnonKey: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

  // App Settings
  static const bool enableDebugMode = true;
  static const bool enableAnalytics = false;
  static const bool enableCrashReporting = false;

  // API Configuration
  static const int apiTimeoutSeconds = 30;
  static const int maxRetryAttempts = 3;

  // File Upload Configuration
  static const int maxFileSizeMB = 10;
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'gif'];
  static const List<String> allowedDocumentTypes = [
    'pdf',
    'doc',
    'docx',
    'txt',
  ];

  // Notification Configuration
  static const int maxNotificationHistory = 100;
  static const int notificationTimeoutSeconds = 5;

  // Security Configuration
  static const bool enableBiometricAuth = false;
  static const bool enableAutoLock = true;
  static const int autoLockTimeoutMinutes = 5;

  // Database Configuration
  static const int maxQueryResults = 1000;
  static const int paginationLimit = 20;

  // Real-time Configuration
  static const bool enableRealTimeUpdates = true;
  static const int realTimeReconnectDelayMs = 1000;

  // Validation Rules
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const int minNameLength = 2;
  static const int maxNameLength = 50;

  // Error Messages
  static const String networkErrorMessage =
      'Network error. Please check your connection.';
  static const String authenticationErrorMessage =
      'Authentication failed. Please try again.';
  static const String serverErrorMessage =
      'Server error. Please try again later.';
  static const String unknownErrorMessage = 'An unknown error occurred.';

  // Success Messages
  static const String profileUpdateSuccessMessage =
      'Profile updated successfully!';
  static const String appointmentBookedSuccessMessage =
      'Appointment booked successfully!';
  static const String recordSavedSuccessMessage = 'Record saved successfully!';

  // URLs
  static const String privacyPolicyUrl = 'https://umate.edu.gh/privacy-policy';
  static const String termsOfServiceUrl =
      'https://umate.edu.gh/terms-of-service';
  static const String supportEmail = 'support@umate.edu.gh';
  static const String emergencyPhone = '+233-XXX-XXX-XXX';

  // Feature Flags
  static const bool enableVideoCalls = true;
  static const bool enableVoiceCalls = true;
  static const bool enableTextChat = true;
  static const bool enableFileSharing = true;
  static const bool enableOfflineMode = false;
  static const bool enablePushNotifications = true;
  static const bool enableEmailNotifications = true;
  static const bool enableSMSSNotifications = false;

  // Development Settings
  static const bool enableMockData = false;
  static const bool enablePerformanceMonitoring = true;
  static const bool enableErrorReporting = true;

  // Testing Configuration
  static const bool enableTestMode = false;
  static const String testUserEmail = 'test@umate.edu.gh';
  static const String testUserPassword = 'testpassword123';

  // Environment Detection
  static bool get isDevelopment => enableDebugMode;
  static bool get isProduction => !enableDebugMode;
  static bool get isTestMode => enableTestMode;

  // Validation Methods
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static bool isValidPhone(String phone) {
    return RegExp(r'^\+?[\d\s\-\(\)]+$').hasMatch(phone);
  }

  static bool isValidPassword(String password) {
    return password.length >= minPasswordLength &&
        password.length <= maxPasswordLength;
  }

  static bool isValidName(String name) {
    return name.length >= minNameLength &&
        name.length <= maxNameLength &&
        RegExp(r'^[a-zA-Z\s]+$').hasMatch(name);
  }

  static bool isValidStudentId(String studentId) {
    return RegExp(r'^[A-Z]{2}\d{4}$').hasMatch(studentId);
  }

  // Configuration Validation
  static bool get isConfigurationValid {
    return supabaseUrl != 'YOUR_SUPABASE_URL_HERE' &&
        supabaseAnonKey != 'YOUR_SUPABASE_ANON_KEY_HERE' &&
        supabaseUrl.isNotEmpty &&
        supabaseAnonKey.isNotEmpty;
  }

  // Get Configuration Summary
  static Map<String, dynamic> get configurationSummary {
    return {
      'appName': appName,
      'appVersion': appVersion,
      'environment': isDevelopment ? 'development' : 'production',
      'supabaseConfigured': isConfigurationValid,
      'features': {
        'videoCalls': enableVideoCalls,
        'voiceCalls': enableVoiceCalls,
        'textChat': enableTextChat,
        'fileSharing': enableFileSharing,
        'offlineMode': enableOfflineMode,
        'pushNotifications': enablePushNotifications,
        'realTimeUpdates': enableRealTimeUpdates,
      },
      'security': {
        'biometricAuth': enableBiometricAuth,
        'autoLock': enableAutoLock,
        'twoFactorAuth': true,
      },
      'validation': {
        'minPasswordLength': minPasswordLength,
        'maxPasswordLength': maxPasswordLength,
        'minNameLength': minNameLength,
        'maxNameLength': maxNameLength,
      },
    };
  }
}
