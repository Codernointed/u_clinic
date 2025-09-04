import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';
import '../../enums/user_role.dart';
import '../../../core/errors/failures.dart';
import '../usecase.dart';

class SignInUseCase implements UseCase<User, SignInParams> {
  final AuthRepository repository;

  SignInUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(SignInParams params) async {
    return await repository.signIn(
      email: params.email,
      password: params.password,
      role: params.role,
    );
  }
}

class SignInParams extends Equatable {
  final String email;
  final String password;
  final UserRole role;

  const SignInParams({
    required this.email,
    required this.password,
    required this.role,
  });

  @override
  List<Object> get props => [email, password, role];
}
