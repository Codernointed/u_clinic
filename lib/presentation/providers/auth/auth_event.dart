import 'package:equatable/equatable.dart';
import '../../../domain/enums/user_role.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthSignInRequested extends AuthEvent {
  final String email;
  final String password;
  final UserRole role;

  const AuthSignInRequested({
    required this.email,
    required this.password,
    required this.role,
  });

  @override
  List<Object> get props => [email, password, role];
}

class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String studentId;
  final String department;
  final UserRole role;

  const AuthSignUpRequested({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.studentId,
    required this.department,
    required this.role,
  });

  @override
  List<Object> get props => [
    email,
    password,
    firstName,
    lastName,
    studentId,
    department,
    role,
  ];
}

class AuthSignOutRequested extends AuthEvent {}

class AuthForgotPasswordRequested extends AuthEvent {
  final String email;

  const AuthForgotPasswordRequested({required this.email});

  @override
  List<Object> get props => [email];
}

class AuthOTPVerificationRequested extends AuthEvent {
  final String phoneNumber;
  final String otp;

  const AuthOTPVerificationRequested({
    required this.phoneNumber,
    required this.otp,
  });

  @override
  List<Object> get props => [phoneNumber, otp];
}

class Auth2FAToggleRequested extends AuthEvent {
  final bool enable;

  const Auth2FAToggleRequested({required this.enable});

  @override
  List<Object> get props => [enable];
}
