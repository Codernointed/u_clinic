import 'package:dartz/dartz.dart';
import 'package:u_clinic/core/errors/failures.dart';
import 'package:u_clinic/core/services/supabase_service.dart';
import 'package:u_clinic/domain/entities/medical_record.dart';
import 'package:u_clinic/domain/repositories/medical_record_repository.dart';

/// Minimal Medical Records Repository - Basic Implementation
class MinimalSupabaseMedicalRecordRepository
    implements MedicalRecordRepository {
  final SupabaseService _supabaseService;

  MinimalSupabaseMedicalRecordRepository(this._supabaseService);

  @override
  Future<Either<Failure, List<MedicalRecord>>> getPatientRecords({
    required String patientId,
    String? recordType,
    DateTime? fromDate,
    DateTime? toDate,
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
          .map((json) => _parseSimpleMedicalRecord(json))
          .toList();

      print('✅ Loaded ${records.length} medical records');
      return Right(records);
    } catch (e) {
      print('❌ Error loading medical records: $e');
      return Left(ServerFailure('Failed to load medical records: $e'));
    }
  }

  @override
  Future<Either<Failure, List<MedicalRecord>>> getMedicalRecords({
    required String patientId,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int limit = 20,
  }) async {
    return getPatientRecords(
      patientId: patientId,
      fromDate: startDate,
      toDate: endDate,
      page: page,
      limit: limit,
    );
  }

  @override
  Future<Either<Failure, MedicalRecord>> getMedicalRecordById({
    required String recordId,
  }) async {
    final result = await getRecordById(recordId: recordId);
    return result;
  }

  @override
  Future<Either<Failure, MedicalRecord>> getRecordById({
    required String recordId,
  }) async {
    try {
      final response = await _supabaseService
          .from('medical_records')
          .select('*')
          .eq('id', recordId)
          .single();

      final record = _parseSimpleMedicalRecord(response);
      return Right(record);
    } catch (e) {
      print('❌ Error getting medical record: $e');
      return Left(ServerFailure('Failed to get medical record: $e'));
    }
  }

  // Simplified implementations for required abstract methods
  @override
  Future<Either<Failure, List<Prescription>>> getPrescriptions({
    required String patientId,
    bool? activeOnly,
  }) async {
    try {
      // Return empty list for now - can be implemented later
      return Right([]);
    } catch (e) {
      return Left(ServerFailure('Failed to load prescriptions: $e'));
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
      // Return empty list for now - can be implemented later
      return Right([]);
    } catch (e) {
      return Left(ServerFailure('Failed to load lab results: $e'));
    }
  }

  @override
  Future<Either<Failure, MedicalRecord>> createRecord({
    required MedicalRecord record,
  }) async {
    try {
      print('➕ Creating medical record: ${record.title}');

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
      };

      final response = await _supabaseService
          .from('medical_records')
          .insert(recordData)
          .select('*')
          .single();

      final createdRecord = _parseSimpleMedicalRecord(response);
      print('✅ Medical record created successfully');
      return Right(createdRecord);
    } catch (e) {
      print('❌ Error creating medical record: $e');
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
        'doctor_name': updatedRecord.doctorName,
        'department': updatedRecord.department,
        'details': updatedRecord.details,
        'attachments': updatedRecord.attachments,
        'is_active': updatedRecord.isActive,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabaseService
          .from('medical_records')
          .update(updateData)
          .eq('id', recordId)
          .select('*')
          .single();

      final record = _parseSimpleMedicalRecord(response);
      return Right(record);
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

      return Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to delete medical record: $e'));
    }
  }

  // Placeholder implementations for other required methods
  @override
  Future<Either<Failure, String>> uploadFile({
    required String filePath,
    required String recordId,
    required String fileName,
  }) async {
    return Right('https://placeholder.url/$fileName');
  }

  @override
  Future<Either<Failure, List<int>>> downloadFile({
    required String fileUrl,
  }) async {
    return Right([]);
  }

  @override
  Future<Either<Failure, void>> exportRecords({
    required String patientId,
    required String format,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    return Right(null);
  }

  @override
  Future<Either<Failure, List<LabResult>>> getRecentLabResults({
    required String patientId,
    int limit = 5,
  }) async {
    return getLabResults(patientId: patientId);
  }

  @override
  Future<Either<Failure, Map<String, int>>> getRecordStats({
    required String patientId,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    return Right({'total_records': 0, 'recent_records': 0});
  }

  // Helper method to parse medical record from JSON
  MedicalRecord _parseSimpleMedicalRecord(Map<String, dynamic> json) {
    return MedicalRecord(
      id: json['id'] as String,
      patientId: json['patient_id'] as String,
      patientName: json['patient_name'] as String? ?? 'Unknown Patient',
      recordType: json['record_type'] as String,
      recordDate: DateTime.parse(json['created_at'] as String),
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      doctorName: json['doctor_name'] as String?,
      department: json['department'] as String?,
      details: json['details'] as Map<String, dynamic>?,
      attachments: (json['attachments'] as List?)?.cast<String>(),
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }
}
