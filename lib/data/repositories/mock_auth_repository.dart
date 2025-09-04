import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/user.dart';
import '../../domain/enums/user_role.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../core/errors/failures.dart';

class MockAuthRepository implements AuthRepository {
  // Simulate a simple in-memory database
  static final Map<String, User> _users = {
    'student@umat.edu.gh': User(
      id: '1',
      email: 'student@umat.edu.gh',
      role: UserRole.patient,
      firstName: 'Christian',
      lastName: 'Enimil',
      studentId: 'UMAT2024001',
      phoneNumber: '+233-24-123-4567',
      dateOfBirth: DateTime(2000, 5, 15),
      bloodGroup: 'O+',
      allergies: ['Penicillin', 'Peanuts'],
      medications: ['Vitamin D', 'Iron supplements'],
      presentingSymptoms: ['Fatigue', 'Headaches'],
      medicalConditions: ['Anemia', 'Seasonal allergies'],
      emergencyContactName: 'Jane Doe',
      emergencyContactPhone: '+233-24-987-6543',
      department: 'Computer Science',
      yearOfStudy: 3,
      isEmailVerified: true,
      is2FAEnabled: false,
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
      updatedAt: DateTime.now(),
    ),
    'staff@umat.edu.gh': User(
      id: '2',
      email: 'staff@umat.edu.gh',
      role: UserRole.staff,
      firstName: 'Dr. Serwaa',
      lastName: 'Adu',
      staffId: 'STAFF001',
      phoneNumber: '+233-24-555-1234',
      dateOfBirth: DateTime(1985, 8, 20),
      bloodGroup: 'A+',
      allergies: [],
      medications: [],
      presentingSymptoms: [],
      medicalConditions: [],
      department: 'General Practice',
      isEmailVerified: true,
      is2FAEnabled: true,
      createdAt: DateTime.now().subtract(const Duration(days: 1095)),
      updatedAt: DateTime.now(),
    ),
    'admin@umat.edu.gh': User(
      id: '3',
      email: 'admin@umat.edu.gh',
      role: UserRole.admin,
      firstName: 'Admin',
      lastName: 'User',
      staffId: 'ADMIN001',
      phoneNumber: '+233-24-999-8888',
      dateOfBirth: DateTime(1980, 3, 10),
      bloodGroup: 'B+',
      allergies: [],
      medications: [],
      presentingSymptoms: [],
      medicalConditions: [],
      department: 'Administration',
      isEmailVerified: true,
      is2FAEnabled: true,
      createdAt: DateTime.now().subtract(const Duration(days: 1825)),
      updatedAt: DateTime.now(),
    ),
  };

  static final Map<String, String> _passwords = {
    'student@umat.edu.gh': 'password123',
    'staff@umat.edu.gh': 'password123',
    'admin@umat.edu.gh': 'password123',
  };

  static final Map<String, String> _sessions = {};
  static User? _currentUser;

  @override
  Future<Either<Failure, User>> signIn({
    required String email,
    required String password,
    required UserRole role,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    try {
      // Validate credentials
      if (!_users.containsKey(email)) {
        return Left(AuthenticationFailure('User not found'));
      }

      if (_passwords[email] != password) {
        return Left(AuthenticationFailure('Invalid password'));
      }

      final user = _users[email]!;

      // Check if role matches
      if (user.role != role) {
        return Left(AuthenticationFailure('Invalid role for this user'));
      }

      // Generate session token
      final sessionToken = _generateSessionToken();
      _sessions[sessionToken] = user.id;
      _currentUser = user;

      if (kDebugMode) {
        print('User signed in: ${user.email} with role: ${user.role.value}');
        print('Session token: $sessionToken');
      }

      return Right(user);
    } catch (e) {
      return Left(AuthenticationFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String studentId,
    required String department,
    required UserRole role,
  }) async {
    print('🚀 Mock: Starting sign up process for email: $email');
    print('👤 Mock: Role: ${role.value}');
    print('📝 Mock: First Name: $firstName');
    print('📝 Mock: Last Name: $lastName');
    print('🆔 Mock: Student/Staff ID: $studentId');
    print('🏢 Mock: Department: $department');

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1000));

    // Check if user already exists
    if (_users.containsKey(email)) {
      print('❌ Mock: User already exists with email: $email');
      return Left(AuthenticationFailure('User already exists with this email'));
    }

    // Create new user based on role
    final newUser = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      email: email,
      role: role,
      firstName: firstName,
      lastName: lastName,
      studentId: role == UserRole.patient ? studentId : '',
      staffId: role != UserRole.patient ? studentId : '',
      phoneNumber: '',
      dateOfBirth: DateTime(2000, 1, 1), // Default date
      bloodGroup: '',
      allergies: [],
      medications: [],
      presentingSymptoms: [],
      medicalConditions: [],
      department: department,
      yearOfStudy: role == UserRole.patient ? 1 : null,
      isEmailVerified: true, // Mock users are verified
      is2FAEnabled: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _users[email] = newUser;
    _passwords[email] = password;
    _currentUser = newUser;

    print('✅ Mock: User created successfully with ID: ${newUser.id}');
    return Right(newUser);
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    try {
    _currentUser = null;
      _sessions.clear();

      if (kDebugMode) {
        print('User signed out');
      }

    return const Right(null);
    } catch (e) {
      return Left(AuthenticationFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> forgotPassword({required String email}) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      if (!_users.containsKey(email)) {
        return Left(AuthenticationFailure('User not found'));
      }

      // In a real app, this would send a password reset email
      if (kDebugMode) {
        print('Password reset email sent to: $email');
      }

    return const Right(null);
    } catch (e) {
      return Left(AuthenticationFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));

    try {
      // In a real app, this would validate the token
      if (kDebugMode) {
        print('Password reset with token: $token');
      }

    return const Right(null);
    } catch (e) {
      return Left(AuthenticationFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> verifyOtp({
    required String phoneNumber,
    required String otp,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 400));

    try {
      // Mock OTP validation
    if (otp == '123456') {
        if (kDebugMode) {
          print('OTP verified for: $phoneNumber');
        }
      return const Right(null);
    } else {
        return Left(AuthenticationFailure('Invalid OTP'));
      }
    } catch (e) {
      return Left(AuthenticationFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resendOtp({required String phoneNumber}) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      if (kDebugMode) {
        print('OTP resent to: $phoneNumber');
      }

    return const Right(null);
    } catch (e) {
      return Left(AuthenticationFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> enable2FA() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 400));

    try {
    if (_currentUser != null) {
        _currentUser = _currentUser!.copyWith(
          is2FAEnabled: true,
          updatedAt: DateTime.now(),
        );

        // Update in database
        _users[_currentUser!.email] = _currentUser!;

        if (kDebugMode) {
          print('2FA enabled for: ${_currentUser!.email}');
        }

        return const Right(null);
      } else {
        return Left(AuthenticationFailure('No user logged in'));
      }
    } catch (e) {
      return Left(AuthenticationFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> disable2FA() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 400));

    try {
    if (_currentUser != null) {
        _currentUser = _currentUser!.copyWith(
          is2FAEnabled: false,
          updatedAt: DateTime.now(),
        );

        // Update in database
        _users[_currentUser!.email] = _currentUser!;

        if (kDebugMode) {
          print('2FA disabled for: ${_currentUser!.email}');
        }

        return const Right(null);
      } else {
        return Left(AuthenticationFailure('No user logged in'));
      }
    } catch (e) {
      return Left(AuthenticationFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> verify2FA({required String code}) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      // Mock 2FA validation
    if (code == '123456') {
        if (kDebugMode) {
          print('2FA code verified');
        }
      return const Right(null);
    } else {
        return Left(AuthenticationFailure('Invalid 2FA code'));
      }
    } catch (e) {
      return Left(AuthenticationFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 200));

    try {
    return Right(_currentUser);
    } catch (e) {
      return Left(AuthenticationFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateProfile({required User user}) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      // Update user in our mock database
      _users[user.email] = user.copyWith(updatedAt: DateTime.now());

      // Update current user if it's the same user
      if (_currentUser?.id == user.id) {
    _currentUser = user;
      }

      if (kDebugMode) {
        print('User profile updated: ${user.email}');
      }

    return const Right(null);
    } catch (e) {
      return Left(AuthenticationFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));

    try {
      if (_currentUser == null) {
        return Left(AuthenticationFailure('No user logged in'));
      }

      // Validate current password
      if (_passwords[_currentUser!.email] != currentPassword) {
        return Left(AuthenticationFailure('Current password is incorrect'));
      }

      // Update password
      _passwords[_currentUser!.email] = newPassword;

      if (kDebugMode) {
        print('Password changed for: ${_currentUser!.email}');
      }

    return const Right(null);
    } catch (e) {
      return Left(AuthenticationFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> refreshToken() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      final newToken = _generateSessionToken();
      if (kDebugMode) {
        print('Token refreshed: $newToken');
      }

      return Right(newToken);
    } catch (e) {
      return Left(AuthenticationFailure(e.toString()));
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 100));

    return _currentUser != null && _sessions.isNotEmpty;
  }

  @override
  Future<void> clearAuthData() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 100));

    _currentUser = null;
    _sessions.clear();

    if (kDebugMode) {
      print('Auth data cleared');
    }
  }

  // Helper methods
  String _generateSessionToken() {
    return DateTime.now().millisecondsSinceEpoch.toString() +
        (1000 + (DateTime.now().millisecond % 9000)).toString();
  }

  // Mock data getters for testing
  static List<User> getAllUsers() => _users.values.toList();
  static User? getUserByEmail(String email) => _users[email];
  static bool hasActiveSessions() => _sessions.isNotEmpty;

  // Clear sessions (for testing)
  static void clearSessions() {
    _sessions.clear();
  }
}
