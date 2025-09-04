import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/usecases/auth/sign_in_usecase.dart';
import '../../../domain/entities/user.dart';
import '../../../core/errors/failures.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final SignInUseCase _signInUseCase;

  AuthBloc({
    required AuthRepository authRepository,
    required SignInUseCase signInUseCase,
  }) : _authRepository = authRepository,
       _signInUseCase = signInUseCase,
       super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthSignInRequested>(_onAuthSignInRequested);
    on<AuthSignUpRequested>(_onAuthSignUpRequested);
    on<AuthSignOutRequested>(_onAuthSignOutRequested);
    on<AuthForgotPasswordRequested>(_onAuthForgotPasswordRequested);
    on<AuthOTPVerificationRequested>(_onAuthOTPVerificationRequested);
    on<Auth2FAToggleRequested>(_onAuth2FAToggleRequested);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final isLoggedIn = await _authRepository.isLoggedIn();
      if (isLoggedIn) {
        final result = await _authRepository.getCurrentUser();
        result.fold((failure) => emit(AuthUnauthenticated()), (user) {
          if (user != null) {
            emit(AuthAuthenticated(user: user));
          } else {
            emit(AuthUnauthenticated());
          }
        });
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onAuthSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await _signInUseCase(
      SignInParams(
        email: event.email,
        password: event.password,
        role: event.role,
      ),
    );

    result.fold(
      (failure) => emit(AuthError(message: _mapFailureToMessage(failure))),
      (user) => emit(AuthAuthenticated(user: user)),
    );
  }

  Future<void> _onAuthSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await _authRepository.signUp(
      email: event.email,
      password: event.password,
      firstName: event.firstName,
      lastName: event.lastName,
      studentId: event.studentId,
      department: event.department,
      role: event.role,
    );

    result.fold(
      (failure) => emit(AuthError(message: _mapFailureToMessage(failure))),
      (user) => emit(AuthAuthenticated(user: user)),
    );
  }

  Future<void> _onAuthSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await _authRepository.signOut();
    result.fold(
      (failure) => emit(AuthError(message: _mapFailureToMessage(failure))),
      (_) => emit(AuthUnauthenticated()),
    );
  }

  Future<void> _onAuthForgotPasswordRequested(
    AuthForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await _authRepository.forgotPassword(email: event.email);
    result.fold(
      (failure) => emit(AuthError(message: _mapFailureToMessage(failure))),
      (_) => emit(AuthPasswordResetSent(email: event.email)),
    );
  }

  Future<void> _onAuthOTPVerificationRequested(
    AuthOTPVerificationRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await _authRepository.verifyOtp(
      phoneNumber: event.phoneNumber,
      otp: event.otp,
    );

    result.fold(
      (failure) => emit(AuthError(message: _mapFailureToMessage(failure))),
      (_) {
        // After OTP verification, check if user is authenticated
        add(AuthCheckRequested());
      },
    );
  }

  Future<void> _onAuth2FAToggleRequested(
    Auth2FAToggleRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = event.enable
        ? await _authRepository.enable2FA()
        : await _authRepository.disable2FA();

    result.fold(
      (failure) => emit(AuthError(message: _mapFailureToMessage(failure))),
      (_) => add(AuthCheckRequested()), // Refresh user state
    );
  }

  Future<void> updateProfile(User updatedUser) async {
    final result = await _authRepository.updateProfile(user: updatedUser);

    result.fold((failure) => throw Exception(_mapFailureToMessage(failure)), (
      _,
    ) {
      // Update the current state with the new user data
      emit(AuthAuthenticated(user: updatedUser));
    });
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure) {
      case AuthenticationFailure _:
        return 'Invalid credentials. Please check your email and password.';
      case NetworkFailure _:
        return 'Network error. Please check your internet connection.';
      case ServerFailure _:
        return 'Server error. Please try again later.';
      case TokenExpiredFailure _:
        return 'Session expired. Please sign in again.';
      case UnauthorizedFailure _:
        return 'You are not authorized to access this resource.';
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }
}
