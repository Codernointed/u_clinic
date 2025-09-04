import 'package:dartz/dartz.dart';
import 'package:u_clinic/core/errors/failures.dart';
import 'package:u_clinic/domain/entities/appointment.dart';
import 'package:u_clinic/domain/enums/appointment_status.dart';
import 'package:u_clinic/domain/enums/consultation_type.dart';
import 'package:u_clinic/domain/repositories/appointment_repository.dart';

class SimpleMockAppointmentRepository implements AppointmentRepository {
  // In-memory storage for appointments
  static final List<Appointment> _appointments = [
    // Sample appointments for testing
    Appointment(
      id: 'appointment1',
      patientId: 'patient1',
      patientName: 'John Doe',
      doctorId: 'doctor1',
      doctorName: 'Dr. Smith',
      departmentName: 'Cardiology',
      appointmentDate: DateTime.now(),
      appointmentTime: '09:00 AM',
      consultationType: ConsultationType.inPerson,
      reasonForVisit: 'Heart checkup',
      symptoms: 'Chest pain',
      notes: 'Regular follow-up',
      status: AppointmentStatus.scheduled,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Appointment(
      id: 'appointment2',
      patientId: 'patient2',
      patientName: 'Jane Smith',
      doctorId: 'doctor1',
      doctorName: 'Dr. Smith',
      departmentName: 'Cardiology',
      appointmentDate: DateTime.now(),
      appointmentTime: '10:30 AM',
      consultationType: ConsultationType.video,
      reasonForVisit: 'Consultation',
      symptoms: 'Shortness of breath',
      notes: 'Virtual consultation',
      status: AppointmentStatus.scheduled,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Appointment(
      id: 'appointment3',
      patientId: 'patient3',
      patientName: 'Mike Johnson',
      doctorId: 'doctor2',
      doctorName: 'Dr. Johnson',
      departmentName: 'Neurology',
      appointmentDate: DateTime.now(),
      appointmentTime: '02:00 PM',
      consultationType: ConsultationType.inPerson,
      reasonForVisit: 'Headache evaluation',
      symptoms: 'Severe headaches',
      notes: 'First visit',
      status: AppointmentStatus.scheduled,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  @override
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
  }) async {
    // Simulate a delay
    await Future.delayed(const Duration(seconds: 1));

    // Create new appointment
    final appointment = Appointment(
      id: 'mock_id_${DateTime.now().millisecondsSinceEpoch}',
      patientId: patientId,
      patientName: patientName,
      doctorId: doctorId,
      doctorName: doctorName,
      departmentName: 'General Practice', // Default department for mock
      appointmentDate: appointmentDate,
      appointmentTime: appointmentTime,
      consultationType: consultationType,
      reasonForVisit: reasonForVisit,
      symptoms: symptoms,
      notes: notes,
      status: AppointmentStatus.scheduled,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Store in memory
    _appointments.add(appointment);
    print('📅 Appointment booked and stored: ${appointment.id}');

    return Right(appointment);
  }

  @override
  Future<Either<Failure, Appointment>> updateAppointment({
    required String appointmentId,
    DateTime? appointmentDate,
    String? appointmentTime,
    ConsultationType? consultationType,
    String? reasonForVisit,
    String? symptoms,
    String? notes,
  }) async {
    final index = _appointments.indexWhere((app) => app.id == appointmentId);
    if (index == -1) {
      return Left(ServerFailure('Appointment not found'));
    }

    final existingAppointment = _appointments[index];
    final updatedAppointment = existingAppointment.copyWith(
      appointmentDate: appointmentDate,
      appointmentTime: appointmentTime,
      consultationType: consultationType,
      reasonForVisit: reasonForVisit,
      symptoms: symptoms,
      notes: notes,
      updatedAt: DateTime.now(),
    );

    _appointments[index] = updatedAppointment;
    return Right(updatedAppointment);
  }

  @override
  Future<Either<Failure, void>> cancelAppointment({
    required String appointmentId,
    required String reason,
  }) async {
    final index = _appointments.indexWhere((app) => app.id == appointmentId);
    if (index == -1) {
      return Left(ServerFailure('Appointment not found'));
    }

    final existingAppointment = _appointments[index];
    final cancelledAppointment = existingAppointment.copyWith(
      status: AppointmentStatus.cancelled,
      cancellationReason: reason,
      cancelledAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _appointments[index] = cancelledAppointment;
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> rescheduleAppointment({
    required String appointmentId,
    required DateTime newDate,
    required String newTime,
  }) async {
    final index = _appointments.indexWhere((app) => app.id == appointmentId);
    if (index == -1) {
      return Left(ServerFailure('Appointment not found'));
    }

    final existingAppointment = _appointments[index];
    final rescheduledAppointment = existingAppointment.copyWith(
      appointmentDate: newDate,
      appointmentTime: newTime,
      status: AppointmentStatus.rescheduled,
      updatedAt: DateTime.now(),
    );

    _appointments[index] = rescheduledAppointment;
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> completeAppointment({
    required String appointmentId,
  }) async {
    final index = _appointments.indexWhere((app) => app.id == appointmentId);
    if (index == -1) {
      return Left(ServerFailure('Appointment not found'));
    }

    final existingAppointment = _appointments[index];
    final completedAppointment = existingAppointment.copyWith(
      status: AppointmentStatus.completed,
      updatedAt: DateTime.now(),
    );

    _appointments[index] = completedAppointment;
    return const Right(null);
  }

  @override
  Future<Either<Failure, List<Appointment>>> getPatientAppointments({
    required String patientId,
    AppointmentStatus? status,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    print('🔍 Fetching appointments for patient: $patientId');

    var filteredAppointments = _appointments
        .where((app) => app.patientId == patientId)
        .toList();

    // Filter by status if provided
    if (status != null) {
      filteredAppointments = filteredAppointments
          .where((app) => app.status == status)
          .toList();
    }

    // Filter by date range if provided
    if (fromDate != null) {
      filteredAppointments = filteredAppointments
          .where(
            (app) => app.appointmentDate.isAfter(
              fromDate.subtract(const Duration(days: 1)),
            ),
          )
          .toList();
    }

    if (toDate != null) {
      filteredAppointments = filteredAppointments
          .where(
            (app) => app.appointmentDate.isBefore(
              toDate.add(const Duration(days: 1)),
            ),
          )
          .toList();
    }

    // Sort by appointment date (newest first)
    filteredAppointments.sort(
      (a, b) => b.appointmentDate.compareTo(a.appointmentDate),
    );

    print('📱 Found ${filteredAppointments.length} appointments for patient');
    return Right(filteredAppointments);
  }

  @override
  Future<Either<Failure, List<Appointment>>> getDoctorAppointments({
    required String doctorId,
    required DateTime date,
    AppointmentStatus? status,
  }) async {
    print(
      '🔍 Fetching appointments for doctor: $doctorId on ${date.toString().split(' ')[0]}',
    );

    var filteredAppointments = _appointments
        .where((app) => app.doctorId == doctorId)
        .where(
          (app) =>
              app.appointmentDate.year == date.year &&
              app.appointmentDate.month == date.month &&
              app.appointmentDate.day == date.day,
        )
        .toList();

    // Filter by status if provided
    if (status != null) {
      filteredAppointments = filteredAppointments
          .where((app) => app.status == status)
          .toList();
    }

    // Sort by appointment time
    filteredAppointments.sort(
      (a, b) => a.appointmentTime.compareTo(b.appointmentTime),
    );

    print('📱 Found ${filteredAppointments.length} appointments for doctor');
    return Right(filteredAppointments);
  }

  @override
  Future<Either<Failure, List<Appointment>>> getDepartmentAppointments({
    required String department,
    required DateTime date,
    AppointmentStatus? status,
  }) async {
    var filteredAppointments = _appointments
        .where((app) => app.departmentName == department)
        .where(
          (app) =>
              app.appointmentDate.year == date.year &&
              app.appointmentDate.month == date.month &&
              app.appointmentDate.day == date.day,
        )
        .toList();

    // Filter by status if provided
    if (status != null) {
      filteredAppointments = filteredAppointments
          .where((app) => app.status == status)
          .toList();
    }

    // Sort by appointment time
    filteredAppointments.sort(
      (a, b) => a.appointmentTime.compareTo(b.appointmentTime),
    );

    return Right(filteredAppointments);
  }

  @override
  Future<Either<Failure, Appointment?>> getAppointmentById({
    required String appointmentId,
  }) async {
    final appointment = _appointments
        .where((app) => app.id == appointmentId)
        .firstOrNull;

    return Right(appointment);
  }

  @override
  Future<Either<Failure, List<String>>> getAvailableTimeSlots({
    required String doctorId,
    required DateTime date,
    required ConsultationType consultationType,
  }) async {
    // Get all time slots
    final allTimeSlots = [
      '09:00 AM',
      '09:30 AM',
      '10:00 AM',
      '10:30 AM',
      '11:00 AM',
      '11:30 AM',
      '02:00 PM',
      '02:30 PM',
      '03:00 PM',
      '03:30 PM',
      '04:00 PM',
      '04:30 PM',
    ];

    // Get booked appointments for this doctor on this date
    final bookedAppointments = _appointments
        .where((app) => app.doctorId == doctorId)
        .where(
          (app) =>
              app.appointmentDate.year == date.year &&
              app.appointmentDate.month == date.month &&
              app.appointmentDate.day == date.day,
        )
        .where((app) => app.status != AppointmentStatus.cancelled)
        .map((app) => app.appointmentTime)
        .toList();

    // Return available time slots
    final availableSlots = allTimeSlots
        .where((slot) => !bookedAppointments.contains(slot))
        .toList();

    return Right(availableSlots);
  }

  @override
  Future<Either<Failure, bool>> isTimeSlotAvailable({
    required String doctorId,
    required DateTime date,
    required String time,
  }) async {
    final bookedAppointments = _appointments
        .where((app) => app.doctorId == doctorId)
        .where(
          (app) =>
              app.appointmentDate.year == date.year &&
              app.appointmentDate.month == date.month &&
              app.appointmentDate.day == date.day,
        )
        .where((app) => app.appointmentTime == time)
        .where((app) => app.status != AppointmentStatus.cancelled)
        .toList();

    return Right(bookedAppointments.isEmpty);
  }

  @override
  Future<Either<Failure, Map<String, int>>> getAppointmentStats({
    required String userId,
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    final userAppointments = _appointments
        .where((app) => app.patientId == userId || app.doctorId == userId)
        .where(
          (app) => app.appointmentDate.isAfter(
            fromDate.subtract(const Duration(days: 1)),
          ),
        )
        .where(
          (app) =>
              app.appointmentDate.isBefore(toDate.add(const Duration(days: 1))),
        )
        .toList();

    final stats = <String, int>{};
    for (final appointment in userAppointments) {
      final status = appointment.status.value;
      stats[status] = (stats[status] ?? 0) + 1;
    }

    return Right(stats);
  }

  @override
  Future<Either<Failure, int>> getTotalAppointments({
    required String userId,
    AppointmentStatus? status,
  }) async {
    var userAppointments = _appointments
        .where((app) => app.patientId == userId || app.doctorId == userId)
        .toList();

    if (status != null) {
      userAppointments = userAppointments
          .where((app) => app.status == status)
          .toList();
    }

    return Right(userAppointments.length);
  }

  // Helper method to clear all appointments (for testing)
  static void clearAllAppointments() {
    _appointments.clear();
    print('🗑️ All appointments cleared');
  }

  // Helper method to get all appointments (for debugging)
  static List<Appointment> getAllAppointments() {
    return List.from(_appointments);
  }
}
