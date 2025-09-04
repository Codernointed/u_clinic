import 'package:dartz/dartz.dart';
import 'package:u_clinic/core/errors/failures.dart';
import 'package:u_clinic/core/services/supabase_service.dart';
import 'package:u_clinic/domain/entities/medical_record.dart';
import 'package:u_clinic/domain/repositories/medical_record_repository.dart';

/// Working Medical Records Repository - Matches Entity Structure
class WorkingMedicalRecordRepository implements MedicalRecordRepository {
  final SupabaseService _supabaseService;

  WorkingMedicalRecordRepository(this._supabaseService);

  @override
  Future<Either<Failure, List<MedicalRecord>>> getMedicalRecords({
    required String patientId,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      print('📋 Loading medical records for patient: $patientId');

      final response = await _supabaseService
          .from('medical_records')
          .select('*')
          .eq('patient_id', patientId)
          .order('created_at', ascending: false)
          .limit(limit);

      final records = (response as List)
          .map((json) => _mapJsonToMedicalRecord(json))
          .toList();

      print('✅ Found ${records.length} medical records');
      return Right(records);
    } catch (e) {
      print('❌ Error loading medical records: $e');
      return Left(ServerFailure('Failed to fetch medical records: $e'));
    }
  }

  @override
  Future<Either<Failure, List<MedicalRecord>>> getPatientRecords({
    required String patientId,
    String? recordType,
    DateTime? fromDate,
    DateTime? toDate,
    int page = 1,
    int limit = 20,
  }) async {
    return getMedicalRecords(
      patientId: patientId,
      startDate: fromDate,
      endDate: toDate,
      page: page,
      limit: limit,
    );
  }

  @override
  Future<Either<Failure, MedicalRecord>> getMedicalRecordById({
    required String recordId,
  }) async {
    try {
      final response = await _supabaseService
          .from('medical_records')
          .select('*')
          .eq('id', recordId)
          .single();

      final record = _mapJsonToMedicalRecord(response);
      return Right(record);
    } catch (e) {
      return Left(ServerFailure('Failed to fetch medical record: $e'));
    }
  }

  @override
  Future<Either<Failure, MedicalRecord?>> getRecordById({
    required String recordId,
  }) async {
    final result = await getMedicalRecordById(recordId: recordId);
    return result.fold((failure) => Left(failure), (record) => Right(record));
  }

  @override
  Future<Either<Failure, MedicalRecord>> createRecord({
    required MedicalRecord record,
  }) async {
    try {
      final recordData = {
        'patient_id': record.patientId,
        'patient_name': record.patientName,
        'record_type': record.recordType,
        'title': record.title,
        'description': record.description,
        'doctor_name': record.doctorName,
        'department': record.department,
        'details': record.details,
        'attachments': record.attachments,
        'is_active': record.isActive,
        'created_at': record.createdAt.toIso8601String(),
        'updated_at': record.updatedAt?.toIso8601String(),
      };

      final response = await _supabaseService
          .from('medical_records')
          .insert(recordData)
          .select()
          .single();

      final createdRecord = _mapJsonToMedicalRecord(response);
      return Right(createdRecord);
    } catch (e) {
      return Left(ServerFailure('Failed to create medical record: $e'));
    }
  }

  @override
  Future<Either<Failure, MedicalRecord>> updateRecord({
    required String recordId,
    required MedicalRecord updatedRecord,
  }) async {
    try {
      final updateData = {
        'title': updatedRecord.title,
        'description': updatedRecord.description,
        'details': updatedRecord.details,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabaseService
          .from('medical_records')
          .update(updateData)
          .eq('id', recordId)
          .select()
          .single();

      final updated = _mapJsonToMedicalRecord(response);
      return Right(updated);
    } catch (e) {
      return Left(ServerFailure('Failed to update medical record: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteRecord({required String recordId}) async {
    try {
      await _supabaseService
          .from('medical_records')
          .delete()
          .eq('id', recordId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to delete medical record: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Prescription>>> getPrescriptions({
    required String patientId,
    bool? activeOnly,
  }) async {
    try {
      var query = _supabaseService
          .from('prescriptions')
          .select('*')
          .eq('patient_id', patientId);

      if (activeOnly == true) {
        query = query.eq('status', 'active');
      }

      final response = await query;
      final prescriptions = (response as List)
          .map((json) => _mapJsonToPrescription(json))
          .toList();
      return Right(prescriptions);
    } catch (e) {
      return Left(ServerFailure('Failed to fetch prescriptions: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Prescription>>> getActivePrescriptions({
    required String patientId,
  }) async {
    return getPrescriptions(patientId: patientId, activeOnly: true);
  }

  @override
  Future<Either<Failure, List<LabResult>>> getLabResults({
    required String patientId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final response = await _supabaseService
          .from('lab_results')
          .select('*')
          .eq('patient_id', patientId);

      final labResults = (response as List)
          .map((json) => _mapJsonToLabResult(json))
          .toList();
      return Right(labResults);
    } catch (e) {
      return Left(ServerFailure('Failed to fetch lab results: $e'));
    }
  }

  @override
  Future<Either<Failure, List<LabResult>>> getRecentLabResults({
    required String patientId,
    int limit = 10,
  }) async {
    return getLabResults(patientId: patientId);
  }

  @override
  Future<Either<Failure, void>> exportRecords({
    required String patientId,
    required String format,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    // Placeholder implementation
    return const Right(null);
  }

  @override
  Future<Either<Failure, Map<String, int>>> getRecordStats({
    required String patientId,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final response = await _supabaseService
          .from('medical_records')
          .select('id')
          .eq('patient_id', patientId);

      final totalRecords = (response as List).length;
      return Right({
        'total_records': totalRecords,
        'recent_records': totalRecords,
      });
    } catch (e) {
      return Left(ServerFailure('Failed to get record stats: $e'));
    }
  }

  // Helper methods
  MedicalRecord _mapJsonToMedicalRecord(Map<String, dynamic> json) {
    return MedicalRecord(
      id: json['id'] as String,
      patientId: json['patient_id'] as String,
      patientName: json['patient_name'] as String? ?? '',
      recordType: json['record_type'] as String,
      recordDate: DateTime.parse(
        json['created_at'] as String,
      ), // Use created_at as recordDate
      title: json['title'] as String,
      description: json['description'] as String,
      doctorName: json['doctor_name'] as String? ?? '',
      department: json['department'] as String? ?? '',
      details: json['details'] as Map<String, dynamic>? ?? {},
      attachments:
          (json['attachments'] as List<dynamic>?)?.cast<String>() ?? [],
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Prescription _mapJsonToPrescription(Map<String, dynamic> json) {
    return Prescription(
      id: json['id'] as String,
      patientId: json['patient_id'] as String,
      patientName: json['patient_name'] as String? ?? '',
      recordDate: DateTime.parse(json['created_at'] as String),
      title: json['medication_name'] as String,
      description: json['instructions'] as String,
      medicationName: json['medication_name'] as String,
      dosage: json['dosage'] as String,
      frequency: json['frequency'] as String,
      duration: json['duration'] as String,
      instructions: json['instructions'] as String,
      doctorName: json['doctor_name'] as String? ?? '',
      department: json['department'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  LabResult _mapJsonToLabResult(Map<String, dynamic> json) {
    return LabResult(
      id: json['id'] as String,
      patientId: json['patient_id'] as String,
      patientName: json['patient_name'] as String? ?? '',
      recordDate: DateTime.parse(json['created_at'] as String),
      title: json['test_name'] as String,
      description: json['interpretation'] as String? ?? '',
      testName: json['test_name'] as String,
      result: json['results'] as String,
      doctorName: json['doctor_name'] as String? ?? '',
      department: json['department'] as String? ?? '',
      interpretation: json['interpretation'] as String?,
      recommendations: json['recommendations'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }
}
