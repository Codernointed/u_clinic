import 'package:dartz/dartz.dart';
import '../entities/medical_record.dart';
import '../../core/errors/failures.dart';

abstract class MedicalRecordRepository {
  // Core CRUD operations
  Future<Either<Failure, List<MedicalRecord>>> getPatientRecords({
    required String patientId,
    String? recordType,
    DateTime? fromDate,
    DateTime? toDate,
    int page = 1,
    int limit = 20,
  });

  Future<Either<Failure, MedicalRecord?>> getRecordById({
    required String recordId,
  });

  Future<Either<Failure, MedicalRecord>> createRecord({
    required MedicalRecord record,
  });

  Future<Either<Failure, MedicalRecord>> updateRecord({
    required String recordId,
    required MedicalRecord updatedRecord,
  });

  Future<Either<Failure, void>> deleteRecord({required String recordId});

  // Specialized queries
  Future<Either<Failure, List<Prescription>>> getActivePrescriptions({
    required String patientId,
  });

  Future<Either<Failure, List<LabResult>>> getRecentLabResults({
    required String patientId,
    int limit = 10,
  });

  // Statistics and reporting
  Future<Either<Failure, Map<String, int>>> getRecordStats({
    required String patientId,
    DateTime? fromDate,
    DateTime? toDate,
  });

  Future<Either<Failure, void>> exportRecords({
    required String patientId,
    required String format,
    DateTime? fromDate,
    DateTime? toDate,
  });

  // Legacy methods for backward compatibility
  Future<Either<Failure, List<MedicalRecord>>> getMedicalRecords({
    required String patientId,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int limit = 20,
  }) {
    return getPatientRecords(
      patientId: patientId,
      fromDate: startDate,
      toDate: endDate,
      page: page,
      limit: limit,
    );
  }

  Future<Either<Failure, MedicalRecord>> getMedicalRecordById({
    required String recordId,
  }) {
    return getRecordById(recordId: recordId).then(
      (result) => result.fold(
        (failure) => Left(failure),
        (record) => record != null
            ? Right(record)
            : Left(AuthenticationFailure('Record not found')),
      ),
    );
  }

  Future<Either<Failure, List<Prescription>>> getPrescriptions({
    required String patientId,
    bool? activeOnly,
  }) {
    if (activeOnly == true) {
      return getActivePrescriptions(patientId: patientId);
    }
    return getPatientRecords(
      patientId: patientId,
      recordType: 'prescription',
    ).then(
      (result) => result.fold(
        (failure) => Left(failure),
        (records) => Right(records.whereType<Prescription>().toList()),
      ),
    );
  }

  Future<Either<Failure, List<LabResult>>> getLabResults({
    required String patientId,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return getPatientRecords(
      patientId: patientId,
      recordType: 'lab_result',
      fromDate: startDate,
      toDate: endDate,
    ).then(
      (result) => result.fold(
        (failure) => Left(failure),
        (records) => Right(records.whereType<LabResult>().toList()),
      ),
    );
  }
}
