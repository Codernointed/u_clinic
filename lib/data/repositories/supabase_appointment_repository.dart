import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../core/services/supabase_service.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/enums/appointment_status.dart';
import '../../domain/enums/consultation_type.dart';
import '../../domain/repositories/appointment_repository.dart';

class SupabaseAppointmentRepository implements AppointmentRepository {
  final SupabaseService _supabaseService;

  SupabaseAppointmentRepository(this._supabaseService);

  // Resolve a provided identifier (doctor table id or user id) to the
  // Get all doctor IDs associated with a user (handles multiple doctor records)
  Future<List<String>> _getAllDoctorIdsForUser(String doctorIdOrUserId) async {
    try {
      // Try as doctors.id first
      final byId = await _supabaseService
          .from('doctors')
          .select('id')
          .eq('id', doctorIdOrUserId)
          .maybeSingle();
      if (byId != null && byId['id'] != null) {
        return [byId['id'] as String];
      }

      // Try as users.id → map to all doctors.id for this user
      final byUser = await _supabaseService
          .from('doctors')
          .select('id')
          .eq('user_id', doctorIdOrUserId);

      if (byUser.isNotEmpty) {
        return byUser.map((e) => e['id'] as String).toList();
      }

      // Fall back to provided id if no mapping found
      return [doctorIdOrUserId];
    } catch (e) {
      // On any error, fall back to provided id
      return [doctorIdOrUserId];
    }
  }

  // canonical doctors.id used in the appointments table
  Future<String> _resolveDoctorId(String doctorIdOrUserId) async {
    try {
      // Try as doctors.id first
      final byId = await _supabaseService
          .from('doctors')
          .select('id')
          .eq('id', doctorIdOrUserId)
          .maybeSingle();
      if (byId != null && byId['id'] != null) {
        return byId['id'] as String;
      }

      // Try as users.id → map to doctors.id
      final byUser = await _supabaseService
          .from('doctors')
          .select('id')
          .eq('user_id', doctorIdOrUserId)
          .limit(1)
          .maybeSingle();
      if (byUser != null && byUser['id'] != null) {
        return byUser['id'] as String;
      }

      // Fall back to provided id if no mapping found
      return doctorIdOrUserId;
    } catch (e) {
      // On any error, fall back to provided id
      return doctorIdOrUserId;
    }
  }

  // Helper method to convert JSON to Appointment entity
  Appointment _fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] as String,
      patientId: json['patient_id'] as String,
      patientName: json['patient_name'] as String,
      doctorId: json['doctor_id'] as String,
      doctorName: json['doctor_name'] as String,
      appointmentDate: DateTime.parse(json['appointment_date'] as String),
      appointmentTime: json['appointment_time'] as String,
      consultationType: ConsultationType.values.firstWhere(
        (e) => e.value == json['consultation_type'],
        orElse: () => ConsultationType.inPerson,
      ),
      reasonForVisit: json['reason_for_visit'] ?? json['reason'] ?? '',
      symptoms: json['symptoms'] as String?,
      notes: json['notes'] as String?,
      status: AppointmentStatus.values.firstWhere(
        (e) => e.value == json['status'],
        orElse: () => AppointmentStatus.scheduled,
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      cancelledAt: json['cancelled_at'] != null
          ? DateTime.parse(json['cancelled_at'] as String)
          : null,
      cancellationReason: json['cancellation_reason'] as String?,
    );
  }

  // Deprecated serializer kept for reference; no longer used

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
    try {
      print(
        '📅 Booking appointment for patient: $patientName with doctor: $doctorName',
      );
      // Ensure we store doctors.id (not users.id)
      final resolvedDoctorId = await _resolveDoctorId(doctorId);

      final appointmentData = {
        'patient_id': patientId,
        'patient_name': patientName,
        'doctor_id': resolvedDoctorId,
        'doctor_name': doctorName,
        'appointment_date': appointmentDate.toIso8601String().split('T')[0],
        'appointment_time': appointmentTime,
        'consultation_type': consultationType.value,
        'reason_for_visit': reasonForVisit,
        'symptoms': symptoms,
        'notes': notes,
        'status': AppointmentStatus.scheduled.value,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabaseService
          .from('appointments')
          .insert(appointmentData)
          .select()
          .single();

      print('✅ Appointment booked successfully: ${response['id']}');

      final appointment = _fromJson(response);
      return Right(appointment);
    } catch (e) {
      print('❌ Error booking appointment: $e');
      return Left(ServerFailure('Failed to book appointment: $e'));
    }
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
    try {
      print('📝 Updating appointment: $appointmentId');

      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (appointmentDate != null)
        updateData['appointment_date'] = appointmentDate
            .toIso8601String()
            .split('T')[0];
      if (appointmentTime != null)
        updateData['appointment_time'] = appointmentTime;
      if (consultationType != null)
        updateData['consultation_type'] = consultationType.value;
      if (notes != null) updateData['notes'] = notes;
      if (symptoms != null) updateData['symptoms'] = symptoms;
      if (reasonForVisit != null) updateData['reason'] = reasonForVisit;

      final response = await _supabaseService
          .from('appointments')
          .update(updateData)
          .eq('id', appointmentId)
          .select()
          .single();

      print('✅ Appointment updated successfully');

      final appointment = _fromJson(response);
      return Right(appointment);
    } catch (e) {
      print('❌ Error updating appointment: $e');
      return Left(ServerFailure('Failed to update appointment: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> cancelAppointment({
    required String appointmentId,
    required String reason,
  }) async {
    try {
      print('❌ Cancelling appointment: $appointmentId');

      await _supabaseService
          .from('appointments')
          .update({
            'status': AppointmentStatus.cancelled.value,
            'cancelled_at': DateTime.now().toIso8601String(),
            'cancellation_reason': reason,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', appointmentId);

      print('✅ Appointment cancelled successfully');
      return const Right(null);
    } catch (e) {
      print('❌ Error cancelling appointment: $e');
      return Left(ServerFailure('Failed to cancel appointment: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> rescheduleAppointment({
    required String appointmentId,
    required DateTime newDate,
    required String newTime,
  }) async {
    try {
      print('📅 Rescheduling appointment: $appointmentId to $newDate $newTime');

      await _supabaseService
          .from('appointments')
          .update({
            'appointment_date': newDate.toIso8601String().split('T')[0],
            'appointment_time': newTime,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', appointmentId);

      print('✅ Appointment rescheduled successfully');
      return const Right(null);
    } catch (e) {
      print('❌ Error rescheduling appointment: $e');
      return Left(ServerFailure('Failed to reschedule appointment: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> completeAppointment({
    required String appointmentId,
  }) async {
    try {
      print('✅ Completing appointment: $appointmentId');

      await _supabaseService
          .from('appointments')
          .update({
            'status': AppointmentStatus.completed.value,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', appointmentId);

      print('✅ Appointment completed successfully');
      return const Right(null);
    } catch (e) {
      print('❌ Error completing appointment: $e');
      return Left(ServerFailure('Failed to complete appointment: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Appointment>>> getPatientAppointments({
    required String patientId,
    AppointmentStatus? status,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      print('🔍 Fetching appointments for patient: $patientId');

      var query = _supabaseService
          .from('appointments')
          .select()
          .eq('patient_id', patientId);

      if (fromDate != null) {
        query = query.gte(
          'appointment_date',
          fromDate.toIso8601String().split('T')[0],
        );
      }

      if (toDate != null) {
        query = query.lte(
          'appointment_date',
          toDate.toIso8601String().split('T')[0],
        );
      }

      if (status != null) {
        query = query.eq('status', status.value);
      }

      final response = await query.order('appointment_date', ascending: false);

      print('📱 Found ${response.length} appointments for patient');

      final appointments = response.map((json) => _fromJson(json)).toList();
      return Right(appointments);
    } catch (e) {
      print('❌ Error fetching patient appointments: $e');
      return Left(ServerFailure('Failed to fetch patient appointments: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Appointment>>> getDoctorAppointments({
    required String doctorId,
    required DateTime date,
    AppointmentStatus? status,
  }) async {
    try {
      final dateStr = date.toIso8601String().split('T')[0];
      print('🔍 Fetching appointments for doctor: $doctorId on $dateStr');

      // Get all doctor IDs associated with this user
      final doctorIds = await _getAllDoctorIdsForUser(doctorId);
      print('🔍 Found ${doctorIds.length} doctor IDs for user: $doctorIds');

      var query = _supabaseService
          .from('appointments')
          .select()
          .inFilter('doctor_id', doctorIds)
          // Show ALL appointments assigned to this doctor (past, present, future)
          // Only exclude completed and cancelled appointments
          .neq('status', AppointmentStatus.completed.value)
          .neq('status', AppointmentStatus.cancelled.value);

      if (status != null) {
        query = query.eq('status', status.value);
      }

      final response = await query
          .order('appointment_date', ascending: true)
          .order('appointment_time', ascending: true);

      print('📱 Found ${response.length} appointments for doctor');

      final appointments = response.map((json) => _fromJson(json)).toList();
      return Right(appointments);
    } catch (e) {
      print('❌ Error fetching doctor appointments: $e');
      return Left(ServerFailure('Failed to fetch doctor appointments: $e'));
    }
  }

  @override
  Future<Either<Failure, Appointment?>> getAppointmentById({
    required String appointmentId,
  }) async {
    try {
      print('🔍 Fetching appointment by ID: $appointmentId');

      final response = await _supabaseService
          .from('appointments')
          .select()
          .eq('id', appointmentId)
          .maybeSingle();

      if (response == null) {
        print('📱 Appointment not found');
        return const Right(null);
      }

      print('📱 Found appointment');

      final appointment = _fromJson(response);
      return Right(appointment);
    } catch (e) {
      print('❌ Error fetching appointment by ID: $e');
      return Left(ServerFailure('Failed to fetch appointment: $e'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getAvailableTimeSlots({
    required String doctorId,
    required DateTime date,
    required ConsultationType consultationType,
  }) async {
    try {
      final dateStr = date.toIso8601String().split('T')[0];
      print(
        '🔍 Getting available time slots for doctor: $doctorId on $dateStr',
      );
      final resolvedDoctorId = await _resolveDoctorId(doctorId);

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
      final response = await _supabaseService
          .from('appointments')
          .select('appointment_time')
          .eq('doctor_id', resolvedDoctorId)
          .eq('appointment_date', dateStr)
          .neq('status', AppointmentStatus.cancelled.value);

      final bookedTimes = response
          .map((json) => json['appointment_time'] as String)
          .toList();
      final availableSlots = allTimeSlots
          .where((slot) => !bookedTimes.contains(slot))
          .toList();

      print('📱 Found ${availableSlots.length} available time slots');

      return Right(availableSlots);
    } catch (e) {
      print('❌ Error getting available time slots: $e');
      return Left(ServerFailure('Failed to get available time slots: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> isTimeSlotAvailable({
    required String doctorId,
    required DateTime date,
    required String time,
  }) async {
    try {
      final dateStr = date.toIso8601String().split('T')[0];
      print(
        '🔍 Checking if time slot is available: $doctorId on $dateStr at $time',
      );
      final resolvedDoctorId = await _resolveDoctorId(doctorId);

      final response = await _supabaseService
          .from('appointments')
          .select('id')
          .eq('doctor_id', resolvedDoctorId)
          .eq('appointment_time', time)
          .eq('appointment_date', dateStr)
          .neq('status', AppointmentStatus.cancelled.value);

      final isAvailable = response.isEmpty;
      print('📱 Time slot available: $isAvailable');

      return Right(isAvailable);
    } catch (e) {
      print('❌ Error checking time slot availability: $e');
      return Left(ServerFailure('Failed to check time slot availability: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, int>>> getAppointmentStats({
    required String userId,
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    try {
      print('📊 Getting appointment stats for user: $userId');

      var query = _supabaseService
          .from('appointments')
          .select('status')
          .or('patient_id.eq.$userId,doctor_id.eq.$userId')
          .gte('appointment_date', fromDate.toIso8601String().split('T')[0])
          .lte('appointment_date', toDate.toIso8601String().split('T')[0]);

      final response = await query;

      final total = response.length;
      final completed = response
          .where((json) => json['status'] == AppointmentStatus.completed.value)
          .length;
      final cancelled = response
          .where((json) => json['status'] == AppointmentStatus.cancelled.value)
          .length;
      final scheduled = response
          .where((json) => json['status'] == AppointmentStatus.scheduled.value)
          .length;

      final stats = {
        'total': total,
        'completed': completed,
        'cancelled': cancelled,
        'scheduled': scheduled,
      };

      print('📊 Appointment stats: $stats');

      return Right(stats);
    } catch (e) {
      print('❌ Error getting appointment stats: $e');
      return Left(ServerFailure('Failed to get appointment stats: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> getTotalAppointments({
    required String userId,
    AppointmentStatus? status,
  }) async {
    try {
      print('📊 Getting total appointments for user: $userId');

      var query = _supabaseService
          .from('appointments')
          .select('id')
          .or('patient_id.eq.$userId,doctor_id.eq.$userId');

      if (status != null) {
        query = query.eq('status', status.value);
      }

      final response = await query;

      final total = response.length;
      print('📊 Total appointments: $total');

      return Right(total);
    } catch (e) {
      print('❌ Error getting total appointments: $e');
      return Left(ServerFailure('Failed to get total appointments: $e'));
    }
  }
}
