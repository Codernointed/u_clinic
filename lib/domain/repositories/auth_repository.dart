import 'package:dartz/dartz.dart';
import '../entities/user.dart';
import '../enums/user_role.dart';
import '../../core/errors/failures.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> signIn({
    required String email,
    required String password,
    required UserRole role,
  });

  Future<Either<Failure, User>> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String studentId,
    required String department,
    required UserRole role,
  });

  Future<Either<Failure, void>> signOut();

  Future<Either<Failure, void>> forgotPassword({required String email});

  Future<Either<Failure, void>> resetPassword({
    required String token,
    required String newPassword,
  });

  Future<Either<Failure, void>> verifyOtp({
    required String phoneNumber,
    required String otp,
  });

  Future<Either<Failure, void>> resendOtp({required String phoneNumber});

  Future<Either<Failure, void>> enable2FA();

  Future<Either<Failure, void>> disable2FA();

  Future<Either<Failure, void>> verify2FA({required String code});

  Future<Either<Failure, User?>> getCurrentUser();

  Future<Either<Failure, void>> updateProfile({required User user});

  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<Either<Failure, String>> refreshToken();

  Future<bool> isLoggedIn();

  Future<void> clearAuthData();
}
