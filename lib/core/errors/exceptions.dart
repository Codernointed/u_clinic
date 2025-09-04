class ServerException implements Exception {
  const ServerException(this.message);
  final String message;
}

class NetworkException implements Exception {
  const NetworkException(this.message);
  final String message;
}

class CacheException implements Exception {
  const CacheException(this.message);
  final String message;
}

class ValidationException implements Exception {
  const ValidationException(this.message);
  final String message;
}

class AuthenticationException implements Exception {
  const AuthenticationException(this.message);
  final String message;
}

class UnauthorizedException implements Exception {
  const UnauthorizedException(this.message);
  final String message;
}

class TokenExpiredException implements Exception {
  const TokenExpiredException(this.message);
  final String message;
}

class AppointmentNotFoundException implements Exception {
  const AppointmentNotFoundException(this.message);
  final String message;
}

class AppointmentConflictException implements Exception {
  const AppointmentConflictException(this.message);
  final String message;
}

class SlotUnavailableException implements Exception {
  const SlotUnavailableException(this.message);
  final String message;
}

class MedicalRecordNotFoundException implements Exception {
  const MedicalRecordNotFoundException(this.message);
  final String message;
}

class InsufficientPermissionException implements Exception {
  const InsufficientPermissionException(this.message);
  final String message;
}

class ConsultationException implements Exception {
  const ConsultationException(this.message);
  final String message;
}

class VideoCallException implements Exception {
  const VideoCallException(this.message);
  final String message;
}

class FileUploadException implements Exception {
  const FileUploadException(this.message);
  final String message;
}

class FileSizeExceededException implements Exception {
  const FileSizeExceededException(this.message);
  final String message;
}

class UnsupportedFileTypeException implements Exception {
  const UnsupportedFileTypeException(this.message);
  final String message;
}
