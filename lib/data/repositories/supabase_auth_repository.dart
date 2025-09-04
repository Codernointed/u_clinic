import 'package:dartz/dartz.dart';

import 'package:u_clinic/core/errors/failures.dart';
import 'package:u_clinic/core/services/supabase_service.dart';
import 'package:u_clinic/data/models/supabase_user_model.dart';
import 'package:u_clinic/domain/entities/user.dart';
import 'package:u_clinic/domain/enums/user_role.dart';
import 'package:u_clinic/domain/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'dart:developer' as developer;

class SupabaseAuthRepository implements AuthRepository {
  final SupabaseService _supabaseService;

  SupabaseAuthRepository(this._supabaseService);

  @override
  Future<Either<Failure, User>> signIn({
    required String email,
    required String password,
    required UserRole role,
  }) async {
    try {
      developer.log('🔐 Sign in attempt for: $email', name: 'SupabaseAuth');
      print('🔐 Sign in attempt for: $email'); // Terminal log

      final response = await _supabaseService.signInWithEmail(
        email: email,
        password: password,
      );

      developer.log(
        '📧 Sign in response: ${response.user?.id ?? 'null'}',
        name: 'SupabaseAuth',
      );
      print(
        '📧 Sign in response: ${response.user?.id ?? 'null'}',
      ); // Terminal log

      if (response.user == null) {
        developer.log(
          '❌ Sign in failed - no user returned',
          name: 'SupabaseAuth',
        );
        print('❌ Sign in failed - no user returned'); // Terminal log
        return Left(AuthenticationFailure('Sign in failed - no user returned'));
      }

      if (response.session == null) {
        developer.log(
          '❌ Sign in failed - no session returned',
          name: 'SupabaseAuth',
        );
        print('❌ Sign in failed - no session returned'); // Terminal log
        return Left(
          AuthenticationFailure('Sign in failed - no session returned'),
        );
      }

      developer.log(
        '✅ Sign in successful for user: ${response.user!.id}',
        name: 'SupabaseAuth',
      );
      print(
        '✅ Sign in successful for user: ${response.user!.id}',
      ); // Terminal log

      // Get user profile from database
      try {
        final userData = await _supabaseService
            .from('users')
            .select()
            .eq('id', response.user!.id)
            .single();

        developer.log(
          '📊 User profile retrieved: ${userData.toString()}',
          name: 'SupabaseAuth',
        );
        print(
          '📊 User profile retrieved: ${userData.toString()}',
        ); // Terminal log

        final userModel = SupabaseUserModel.fromJson(userData);
        return Right(userModel.toDomain());
      } catch (e) {
        developer.log(
          '⚠️ Failed to get user profile: $e',
          name: 'SupabaseAuth',
        );
        print('⚠️ Failed to get user profile: $e'); // Terminal log

        // Return basic user info if profile doesn't exist
        return Right(
          User(
            id: response.user!.id,
            email: response.user!.email ?? email,
            firstName: response.user!.userMetadata?['first_name'] ?? '',
            lastName: response.user!.userMetadata?['last_name'] ?? '',
            studentId: response.user!.userMetadata?['student_id'] ?? '',
            role: UserRole.patient,
            isActive: true,
            isEmailVerified: response.user!.emailConfirmedAt != null,
            presentingSymptoms: const [],
            medicalConditions: const [],
            allergies: const [],
            medications: const [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
      }
    } catch (e) {
      developer.log('❌ Sign in error: $e', name: 'SupabaseAuth');
      print('❌ Sign in error: $e'); // Terminal log
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
    try {
      developer.log(
        '🚀 Starting sign up process for email: $email',
        name: 'SupabaseAuth',
      );
      print('🚀 Starting sign up process for email: $email'); // Terminal log
      print('👤 Role: ${role.value}'); // Terminal log
      print('📝 First Name: $firstName'); // Terminal log
      print('📝 Last Name: $lastName'); // Terminal log
      print('🆔 Student/Staff ID: $studentId'); // Terminal log
      print('🏢 Department: $department'); // Terminal log

      final response = await _supabaseService.signUpWithEmail(
        email: email,
        password: password,
        userData: {
          'first_name': firstName,
          'last_name': lastName,
          'student_id': studentId,
          'department': department,
          'role': role.value,
        },
      );

      developer.log(
        '📧 Sign up response: ${response.user?.id ?? 'null'}',
        name: 'SupabaseAuth',
      );
      print(
        '📧 Sign up response: ${response.user?.id ?? 'null'}',
      ); // Terminal log

      developer.log(
        '📧 Session: ${response.session?.accessToken != null ? 'present' : 'null'}',
        name: 'SupabaseAuth',
      );
      print(
        '📧 Session: ${response.session?.accessToken != null ? 'present' : 'null'}',
      ); // Terminal log

      developer.log(
        '📧 User metadata: ${response.user?.userMetadata}',
        name: 'SupabaseAuth',
      );
      print('📧 User metadata: ${response.user?.userMetadata}'); // Terminal log

      if (response.user == null) {
        developer.log(
          '❌ Sign up failed - no user returned',
          name: 'SupabaseAuth',
        );
        print('❌ Sign up failed - no user returned'); // Terminal log
        return Left(AuthenticationFailure('Sign up failed - no user returned'));
      }

      // Check if email confirmation is required
      if (response.session == null) {
        developer.log(
          '📧 Email confirmation required for: $email',
          name: 'SupabaseAuth',
        );
        print('📧 Email confirmation required for: $email'); // Terminal log

        // Return success but indicate email confirmation is needed
        return Right(
          User(
            id: response.user!.id,
            email: email,
            role: role,
            firstName: firstName,
            lastName: lastName,
            studentId: studentId,
            department: department,
            phoneNumber: '',
            bloodGroup: '',
            allergies: [],
            medications: [],
            presentingSymptoms: [],
            medicalConditions: [],
            is2FAEnabled: false,
          ),
        );
      }

      developer.log(
        '✅ Sign up successful for user: ${response.user!.id}',
        name: 'SupabaseAuth',
      );
      print(
        '✅ Sign up successful for user: ${response.user!.id}',
      ); // Terminal log

      // Create user profile in database
      try {
        final user = User(
          id: response.user!.id,
          email: email,
          role: role,
          firstName: firstName,
          lastName: lastName,
          studentId: studentId,
          department: department,
          phoneNumber: '',
          bloodGroup: '',
          allergies: [],
          medications: [],
          presentingSymptoms: [],
          medicalConditions: [],
          is2FAEnabled: false,
        );

        final userModel = SupabaseUserModel.fromDomain(user);
        final userData = userModel.toJson();

        developer.log(
          '📊 Creating user profile with data: $userData',
          name: 'SupabaseAuth',
        );
        print('📊 Creating user profile with data: $userData'); // Terminal log

        // Remove fields that don't exist in the database
        userData.remove('bloodType'); // This column doesn't exist
        userData.remove('currentMedications'); // Use 'medications' instead
        userData.remove('twoFactorEnabled'); // Use 'is2FAEnabled' instead

        await _supabaseService.from('users').insert(userData);

        developer.log(
          '✅ User profile created successfully',
          name: 'SupabaseAuth',
        );
        print('✅ User profile created successfully'); // Terminal log

        return Right(user);
      } catch (e) {
        developer.log(
          '⚠️ Failed to create user profile: $e',
          name: 'SupabaseAuth',
        );
        print('⚠️ Failed to create user profile: $e'); // Terminal log

        // Return user without profile if database insert fails
        return Right(
          User(
            id: response.user!.id,
            email: email,
            role: role,
            firstName: firstName,
            lastName: lastName,
            studentId: studentId,
            department: department,
            phoneNumber: '',
            bloodGroup: '',
            allergies: [],
            medications: [],
            presentingSymptoms: [],
            medicalConditions: [],
            is2FAEnabled: false,
          ),
        );
      }
    } catch (e) {
      developer.log('❌ Sign up error: $e', name: 'SupabaseAuth');
      print('❌ Sign up error: $e'); // Terminal log
      return Left(AuthenticationFailure('Sign up failed: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      developer.log('🚪 Signing out user', name: 'SupabaseAuth');
      print('🚪 Signing out user'); // Terminal log

      await _supabaseService.signOut();

      developer.log('✅ Sign out successful', name: 'SupabaseAuth');
      print('✅ Sign out successful'); // Terminal log

      return const Right(null);
    } catch (e) {
      developer.log('❌ Sign out error: $e', name: 'SupabaseAuth');
      print('❌ Sign out error: $e'); // Terminal log
      return Left(AuthenticationFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final currentUser = _supabaseService.currentUser;
      if (currentUser == null) {
        developer.log('👤 No current user found', name: 'SupabaseAuth');
        print('👤 No current user found'); // Terminal log
        return const Right(null);
      }

      developer.log(
        '👤 Current user ID: ${currentUser.id}',
        name: 'SupabaseAuth',
      );
      print('👤 Current user ID: ${currentUser.id}'); // Terminal log

      try {
        final userData = await _supabaseService
            .from('users')
            .select()
            .eq('id', currentUser.id)
            .single();

        developer.log(
          '📊 User profile retrieved: ${userData.toString()}',
          name: 'SupabaseAuth',
        );
        print(
          '📊 User profile retrieved: ${userData.toString()}',
        ); // Terminal log

        final userModel = SupabaseUserModel.fromJson(userData);
        return Right(userModel.toDomain());
      } catch (e) {
        developer.log(
          '⚠️ Failed to get user profile: $e',
          name: 'SupabaseAuth',
        );
        print('⚠️ Failed to get user profile: $e'); // Terminal log

        // Return basic user info if profile doesn't exist
        return Right(
          User(
            id: currentUser.id,
            email: currentUser.email ?? '',
            firstName: currentUser.userMetadata?['first_name'] ?? '',
            lastName: currentUser.userMetadata?['last_name'] ?? '',
            studentId: currentUser.userMetadata?['student_id'] ?? '',
            role: UserRole.patient,
            isActive: true,
            isEmailVerified: currentUser.emailConfirmedAt != null,
            presentingSymptoms: const [],
            medicalConditions: const [],
            allergies: const [],
            medications: const [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
      }
    } catch (e) {
      developer.log('❌ Get current user error: $e', name: 'SupabaseAuth');
      print('❌ Get current user error: $e'); // Terminal log
      return Left(AuthenticationFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> updateProfile({required User user}) async {
    try {
      developer.log(
        '📝 Updating user profile for: ${user.id}',
        name: 'SupabaseAuth',
      );
      print('📝 Updating user profile for: ${user.id}'); // Terminal log

      final currentUser = _supabaseService.currentUser;
      if (currentUser == null) {
        developer.log(
          '❌ No current user to update profile',
          name: 'SupabaseAuth',
        );
        print('❌ No current user to update profile'); // Terminal log
        return Left(AuthenticationFailure('No current user to update profile'));
      }

      final userModel = SupabaseUserModel.fromDomain(user);
      final userData = userModel.toJson();

      developer.log('📊 Updating user data: $userData', name: 'SupabaseAuth');
      print('📊 Updating user data: $userData'); // Terminal log

      await _supabaseService
          .from('users')
          .update(userData)
          .eq('id', currentUser.id);

      developer.log(
        '✅ User profile updated successfully',
        name: 'SupabaseAuth',
      );
      print('✅ User profile updated successfully'); // Terminal log

      return Right(user);
    } catch (e) {
      developer.log('❌ Update profile error: $e', name: 'SupabaseAuth');
      print('❌ Update profile error: $e'); // Terminal log
      return Left(AuthenticationFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> forgotPassword({required String email}) async {
    try {
      developer.log('🔑 Forgot password for: $email', name: 'SupabaseAuth');
      print('🔑 Forgot password for: $email'); // Terminal log

      await _supabaseService.resetPassword(email);

      developer.log('✅ Password reset email sent', name: 'SupabaseAuth');
      print('✅ Password reset email sent'); // Terminal log

      return const Right(null);
    } catch (e) {
      developer.log('❌ Forgot password error: $e', name: 'SupabaseAuth');
      print('❌ Forgot password error: $e'); // Terminal log
      return Left(AuthenticationFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      developer.log('🔑 Resetting password with token', name: 'SupabaseAuth');
      print('🔑 Resetting password with token'); // Terminal log

      // Supabase handles this through the reset password flow
      // The token is typically handled in the web interface
      developer.log(
        '⚠️ Password reset requires web interface',
        name: 'SupabaseAuth',
      );
      print('⚠️ Password reset requires web interface'); // Terminal log

      return const Right(null);
    } catch (e) {
      developer.log('❌ Reset password error: $e', name: 'SupabaseAuth');
      print('❌ Reset password error: $e'); // Terminal log
      return Left(AuthenticationFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> verifyOtp({
    required String phoneNumber,
    required String otp,
  }) async {
    try {
      developer.log('📱 Verifying OTP for: $phoneNumber', name: 'SupabaseAuth');
      print('📱 Verifying OTP for: $phoneNumber'); // Terminal log

      // OTP verification not implemented yet
      developer.log(
        '⚠️ OTP verification not implemented',
        name: 'SupabaseAuth',
      );
      print('⚠️ OTP verification not implemented'); // Terminal log

      return const Right(null);
    } catch (e) {
      developer.log('❌ Verify OTP error: $e', name: 'SupabaseAuth');
      print('❌ Verify OTP error: $e'); // Terminal log
      return Left(AuthenticationFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resendOtp({required String phoneNumber}) async {
    try {
      developer.log('📱 Resending OTP for: $phoneNumber', name: 'SupabaseAuth');
      print('📱 Resending OTP for: $phoneNumber'); // Terminal log

      // OTP resend not implemented yet
      developer.log('⚠️ OTP resend not implemented', name: 'SupabaseAuth');
      print('⚠️ OTP resend not implemented'); // Terminal log

      return const Right(null);
    } catch (e) {
      developer.log('❌ Resend OTP error: $e', name: 'SupabaseAuth');
      print('❌ Resend OTP error: $e'); // Terminal log
      return Left(AuthenticationFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> enable2FA() async {
    try {
      developer.log('🔐 Enabling 2FA', name: 'SupabaseAuth');
      print('🔐 Enabling 2FA'); // Terminal log

      // 2FA not implemented yet
      developer.log('⚠️ 2FA not implemented', name: 'SupabaseAuth');
      print('⚠️ 2FA not implemented'); // Terminal log

      return const Right(null);
    } catch (e) {
      developer.log('❌ Enable 2FA error: $e', name: 'SupabaseAuth');
      print('❌ Enable 2FA error: $e'); // Terminal log
      return Left(AuthenticationFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> disable2FA() async {
    try {
      developer.log('🔐 Disabling 2FA', name: 'SupabaseAuth');
      print('🔐 Disabling 2FA'); // Terminal log

      // 2FA not implemented yet
      developer.log('⚠️ 2FA not implemented', name: 'SupabaseAuth');
      print('⚠️ 2FA not implemented'); // Terminal log

      return const Right(null);
    } catch (e) {
      developer.log('❌ Disable 2FA error: $e', name: 'SupabaseAuth');
      print('❌ Disable 2FA error: $e'); // Terminal log
      return Left(AuthenticationFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> verify2FA({required String code}) async {
    try {
      developer.log('🔐 Verifying 2FA code', name: 'SupabaseAuth');
      print('🔐 Verifying 2FA code'); // Terminal log

      // 2FA not implemented yet
      developer.log('⚠️ 2FA not implemented', name: 'SupabaseAuth');
      print('⚠️ 2FA not implemented'); // Terminal log

      return const Right(null);
    } catch (e) {
      developer.log('❌ Verify 2FA error: $e', name: 'SupabaseAuth');
      print('❌ Verify 2FA error: $e'); // Terminal log
      return Left(AuthenticationFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      developer.log('🔐 Changing password', name: 'SupabaseAuth');
      print('🔐 Changing password'); // Terminal log

      final currentUser = _supabaseService.currentUser;
      if (currentUser == null) {
        developer.log(
          '❌ No current user to change password',
          name: 'SupabaseAuth',
        );
        print('❌ No current user to change password'); // Terminal log
        return Left(
          AuthenticationFailure('No current user to change password'),
        );
      }

      // Supabase handles password change through auth
      await _supabaseService.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      developer.log('✅ Password changed successfully', name: 'SupabaseAuth');
      print('✅ Password changed successfully'); // Terminal log

      return const Right(null);
    } catch (e) {
      developer.log('❌ Change password error: $e', name: 'SupabaseAuth');
      print('❌ Change password error: $e'); // Terminal log
      return Left(AuthenticationFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> refreshToken() async {
    try {
      developer.log('🔄 Refreshing token', name: 'SupabaseAuth');
      print('🔄 Refreshing token'); // Terminal log

      // Supabase handles token refresh automatically
      final session = _supabaseService.client.auth.currentSession;
      if (session != null) {
        developer.log(
          '✅ Token refresh handled by Supabase',
          name: 'SupabaseAuth',
        );
        print('✅ Token refresh handled by Supabase'); // Terminal log
        return Right(session.accessToken);
      } else {
        developer.log('❌ No session to refresh', name: 'SupabaseAuth');
        print('❌ No session to refresh'); // Terminal log
        return Left(AuthenticationFailure('No session to refresh'));
      }
    } catch (e) {
      developer.log('❌ Refresh token error: $e', name: 'SupabaseAuth');
      print('❌ Refresh token error: $e'); // Terminal log
      return Left(AuthenticationFailure(e.toString()));
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      final isAuthenticated = _supabaseService.isAuthenticated;
      developer.log('🔍 Is logged in: $isAuthenticated', name: 'SupabaseAuth');
      print('🔍 Is logged in: $isAuthenticated'); // Terminal log
      return isAuthenticated;
    } catch (e) {
      developer.log('❌ Check login status error: $e', name: 'SupabaseAuth');
      print('❌ Check login status error: $e'); // Terminal log
      return false;
    }
  }

  @override
  Future<void> clearAuthData() async {
    try {
      developer.log('🧹 Clearing auth data', name: 'SupabaseAuth');
      print('🧹 Clearing auth data'); // Terminal log

      // Sign out to clear auth data
      await _supabaseService.signOut();

      developer.log('✅ Auth data cleared', name: 'SupabaseAuth');
      print('✅ Auth data cleared'); // Terminal log
    } catch (e) {
      developer.log('❌ Clear auth data error: $e', name: 'SupabaseAuth');
      print('❌ Clear auth data error: $e'); // Terminal log
    }
  }
}
