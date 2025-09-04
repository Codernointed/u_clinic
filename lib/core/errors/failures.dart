import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object> get props => [message];
}

// General failures
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

// Authentication failures
class AuthenticationFailure extends Failure {
  const AuthenticationFailure(super.message);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure(super.message);
}

class TokenExpiredFailure extends Failure {
  const TokenExpiredFailure(super.message);
}

// Appointment failures
class AppointmentNotFoundFailure extends Failure {
  const AppointmentNotFoundFailure(super.message);
}

class AppointmentConflictFailure extends Failure {
  const AppointmentConflictFailure(super.message);
}

class SlotUnavailableFailure extends Failure {
  const SlotUnavailableFailure(super.message);
}

// Medical record failures
class MedicalRecordNotFoundFailure extends Failure {
  const MedicalRecordNotFoundFailure(super.message);
}

class InsufficientPermissionFailure extends Failure {
  const InsufficientPermissionFailure(super.message);
}

// Consultation failures
class ConsultationFailure extends Failure {
  const ConsultationFailure(super.message);
}

class VideoCallFailure extends Failure {
  const VideoCallFailure(super.message);
}

// File upload failures
class FileUploadFailure extends Failure {
  const FileUploadFailure(super.message);
}

class FileSizeExceededFailure extends Failure {
  const FileSizeExceededFailure(super.message);
}

class UnsupportedFileTypeFailure extends Failure {
  const UnsupportedFileTypeFailure(super.message);
}
