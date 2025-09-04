import 'package:equatable/equatable.dart';
import '../enums/appointment_status.dart';
import '../enums/consultation_type.dart';

class Appointment extends Equatable {
  final String id;
  final String patientId;
  final String patientName;
  final String doctorId;
  final String doctorName;
  final String? departmentId;
  final String? departmentName;
  final DateTime appointmentDate;
  final String appointmentTime;
  final ConsultationType consultationType;
  final String reasonForVisit;
  final String? symptoms;
  final String? notes;
  final AppointmentStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;

  const Appointment({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.doctorId,
    required this.doctorName,
    this.departmentId,
    this.departmentName,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.consultationType,
    required this.reasonForVisit,
    this.symptoms,
    this.notes,
    this.status = AppointmentStatus.scheduled,
    required this.createdAt,
    this.updatedAt,
    this.cancelledAt,
    this.cancellationReason,
  });

  Appointment copyWith({
    String? id,
    String? patientId,
    String? patientName,
    String? doctorId,
    String? doctorName,
    String? departmentId,
    String? departmentName,
    DateTime? appointmentDate,
    String? appointmentTime,
    ConsultationType? consultationType,
    String? reasonForVisit,
    String? symptoms,
    String? notes,
    AppointmentStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? cancelledAt,
    String? cancellationReason,
  }) {
    return Appointment(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      departmentId: departmentId ?? this.departmentId,
      departmentName: departmentName ?? this.departmentName,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      appointmentTime: appointmentTime ?? this.appointmentTime,
      consultationType: consultationType ?? this.consultationType,
      reasonForVisit: reasonForVisit ?? this.reasonForVisit,
      symptoms: symptoms ?? this.symptoms,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
    );
  }

  bool get isUpcoming =>
      appointmentDate.isAfter(DateTime.now()) &&
      status == AppointmentStatus.scheduled;

  bool get isToday =>
      appointmentDate.year == DateTime.now().year &&
      appointmentDate.month == DateTime.now().month &&
      appointmentDate.day == DateTime.now().day;

  bool get isPast =>
      appointmentDate.isBefore(DateTime.now()) ||
      status == AppointmentStatus.completed ||
      status == AppointmentStatus.cancelled;

  String get formattedDate =>
      '${appointmentDate.day}/${appointmentDate.month}/${appointmentDate.year}';

  String get formattedDateTime => '$formattedDate at $appointmentTime';

  @override
  List<Object?> get props => [
    id,
    patientId,
    patientName,
    doctorId,
    doctorName,
    departmentId,
    departmentName,
    appointmentDate,
    appointmentTime,
    consultationType,
    reasonForVisit,
    symptoms,
    notes,
    status,
    createdAt,
    updatedAt,
    cancelledAt,
    cancellationReason,
  ];
}
