import 'package:dartz/dartz.dart';
import '../entities/appointment.dart';
import '../enums/appointment_status.dart';
import '../enums/consultation_type.dart';
import '../../core/errors/failures.dart';

abstract class AppointmentRepository {
  // Create and manage appointments
  Future<Either<Failure, Appointment>> bookAppointment({
    required String patientId,
    required String patientName,
    required String doctorId,
    required String doctorName,
    required DateTime appointmentDate,
    required String appointmentTime,
    required ConsultationType consultationType,
    required String reasonForVisit,
    String? symptoms,
    String? notes,
  });

  Future<Either<Failure, Appointment>> updateAppointment({
    required String appointmentId,
    DateTime? appointmentDate,
    String? appointmentTime,
    ConsultationType? consultationType,
    String? reasonForVisit,
    String? symptoms,
    String? notes,
  });

  Future<Either<Failure, void>> cancelAppointment({
    required String appointmentId,
    required String reason,
  });

  Future<Either<Failure, void>> rescheduleAppointment({
    required String appointmentId,
    required DateTime newDate,
    required String newTime,
  });

  Future<Either<Failure, void>> completeAppointment({
    required String appointmentId,
  });

  // Query appointments
  Future<Either<Failure, List<Appointment>>> getPatientAppointments({
    required String patientId,
    AppointmentStatus? status,
    DateTime? fromDate,
    DateTime? toDate,
  });

  Future<Either<Failure, List<Appointment>>> getDoctorAppointments({
    required String doctorId,
    required DateTime date,
    AppointmentStatus? status,
  });

  Future<Either<Failure, Appointment?>> getAppointmentById({
    required String appointmentId,
  });

  // Availability and scheduling
  Future<Either<Failure, List<String>>> getAvailableTimeSlots({
    required String doctorId,
    required DateTime date,
    required ConsultationType consultationType,
  });

  Future<Either<Failure, bool>> isTimeSlotAvailable({
    required String doctorId,
    required DateTime date,
    required String time,
  });

  // Statistics and reporting
  Future<Either<Failure, Map<String, int>>> getAppointmentStats({
    required String userId,
    required DateTime fromDate,
    required DateTime toDate,
  });

  Future<Either<Failure, int>> getTotalAppointments({
    required String userId,
    AppointmentStatus? status,
  });
}
