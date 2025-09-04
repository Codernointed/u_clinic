import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../entities/appointment.dart';
import '../../repositories/appointment_repository.dart';
import '../../enums/consultation_type.dart';
import '../../../core/errors/failures.dart';
import '../usecase.dart';

class BookAppointmentUseCase
    implements UseCase<Appointment, BookAppointmentParams> {
  final AppointmentRepository repository;

  BookAppointmentUseCase(this.repository);

  @override
  Future<Either<Failure, Appointment>> call(
    BookAppointmentParams params,
  ) async {
    return await repository.bookAppointment(
      patientId: params.patientId,
      patientName: params.patientName,
      doctorId: params.doctorId,
      doctorName: params.doctorName,
      appointmentDate: params.appointmentDate,
      appointmentTime: params.appointmentTime,
      consultationType: params.consultationType,
      reasonForVisit: params.reasonForVisit,
      symptoms: params.symptoms,
      notes: params.notes,
    );
  }
}

class BookAppointmentParams extends Equatable {
  final String patientId;
  final String patientName;
  final String doctorId;
  final String doctorName;
  final DateTime appointmentDate;
  final String appointmentTime;
  final ConsultationType consultationType;
  final String reasonForVisit;
  final String? symptoms;
  final String? notes;

  const BookAppointmentParams({
    required this.patientId,
    required this.patientName,
    required this.doctorId,
    required this.doctorName,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.consultationType,
    required this.reasonForVisit,
    this.symptoms,
    this.notes,
  });

  @override
  List<Object?> get props => [
    patientId,
    patientName,
    doctorId,
    doctorName,
    appointmentDate,
    appointmentTime,
    consultationType,
    reasonForVisit,
    symptoms,
    notes,
  ];
}
