import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/medical_record.dart';
import '../../domain/repositories/medical_record_repository.dart';
import '../../core/errors/failures.dart';

class MockMedicalRecordRepository implements MedicalRecordRepository {
  // Simulate in-memory database for medical records
  static final Map<String, MedicalRecord> _medicalRecords = {};
  static int _nextId = 1;

  // Initialize with some mock data
  static void _initializeMockData() {
    if (_medicalRecords.isEmpty) {
      // Mock prescriptions
      _medicalRecords['1'] = Prescription(
        id: '1',
        patientId: '1',
        patientName: 'Christian Enimil',
        recordDate: DateTime.now().subtract(const Duration(days: 15)),
        title: 'Vitamin D Supplement',
        description: 'Daily vitamin D supplement for bone health',
        medicationName: 'Vitamin D3',
        dosage: '1000 IU',
        frequency: 'Once daily',
        duration: '3 months',
        instructions: 'Take with food',
        expiryDate: DateTime.now().add(const Duration(days: 75)),
        refillsRemaining: 2,
        requiresRefill: false,
        doctorName: 'Dr. Sarah Johnson',
        department: 'General Practice',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now().subtract(const Duration(days: 15)),
      );

      _medicalRecords['2'] = Prescription(
        id: '2',
        patientId: '1',
        patientName: 'Pat Twumasi',
        recordDate: DateTime.now().subtract(const Duration(days: 30)),
        title: 'Iron Supplement',
        description: 'Iron supplement for anemia treatment',
        medicationName: 'Ferrous Sulfate',
        dosage: '325 mg',
        frequency: 'Twice daily',
        duration: '6 months',
        instructions: 'Take on empty stomach',
        expiryDate: DateTime.now().add(const Duration(days: 150)),
        refillsRemaining: 1,
        requiresRefill: true,
        doctorName: 'Dr. Sarah Johnson',
        department: 'General Practice',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(days: 30)),
      );

      // Mock lab results
      _medicalRecords['3'] = LabResult(
        id: '3',
        patientId: '1',
        patientName: 'Patricia Twum',
        recordDate: DateTime.now().subtract(const Duration(days: 7)),
        title: 'Complete Blood Count',
        description: 'Routine blood work results',
        testName: 'Hemoglobin',
        result: '11.5',
        normalRange: '12.0-15.5',
        unit: 'g/dL',
        isAbnormal: true,
        interpretation: 'Slightly below normal range',
        recommendations: 'Continue iron supplementation',
        doctorName: 'Dr. Sarah Johnson',
        department: 'Laboratory',
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        updatedAt: DateTime.now().subtract(const Duration(days: 7)),
      );

      _medicalRecords['4'] = LabResult(
        id: '4',
        patientId: '1',
        patientName: 'Christian Gyamfi',
        recordDate: DateTime.now().subtract(const Duration(days: 7)),
        title: 'Complete Blood Count',
        description: 'Routine blood work results',
        testName: 'White Blood Cells',
        result: '7.2',
        normalRange: '4.5-11.0',
        unit: 'K/μL',
        isAbnormal: false,
        interpretation: 'Within normal range',
        recommendations: 'No action needed',
        doctorName: 'Dr. Sarah Johnson',
        department: 'Laboratory',
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        updatedAt: DateTime.now().subtract(const Duration(days: 7)),
      );

      // Mock general medical records
      _medicalRecords['5'] = MedicalRecord(
        id: '5',
        patientId: '1',
        patientName: 'Christian Enimil',
        recordType: 'appointment',
        recordDate: DateTime.now().subtract(const Duration(days: 20)),
        title: 'Annual Check-up',
        description: 'Routine annual physical examination',
        doctorName: 'Dr. Sarah Johnson',
        department: 'General Practice',
        details: {
          'blood_pressure': '120/80',
          'heart_rate': '72',
          'temperature': '98.6',
          'weight': '70 kg',
          'height': '175 cm',
        },
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        updatedAt: DateTime.now().subtract(const Duration(days: 20)),
      );

      _nextId = 6;
    }
  }

  MockMedicalRecordRepository() {
    _initializeMockData();
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
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 400));

    try {
      var records = _medicalRecords.values.where(
        (record) => record.patientId == patientId,
      );

      // Filter by record type if provided
      if (recordType != null) {
        records = records.where((record) => record.recordType == recordType);
      }

      // Filter by date range if provided
      if (fromDate != null) {
        records = records.where(
          (record) => record.recordDate.isAfter(
            fromDate.subtract(const Duration(days: 1)),
          ),
        );
      }

      if (toDate != null) {
        records = records.where(
          (record) =>
              record.recordDate.isBefore(toDate.add(const Duration(days: 1))),
        );
      }

      // Sort by date (newest first)
      final sortedRecords = records.toList()
        ..sort((a, b) => b.recordDate.compareTo(a.recordDate));

      // Apply pagination
      final startIndex = (page - 1) * limit;
      final paginatedRecords = sortedRecords
          .skip(startIndex)
          .take(limit)
          .toList();

      return Right(paginatedRecords);
    } catch (e) {
      return Left(AuthenticationFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MedicalRecord?>> getRecordById({
    required String recordId,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 200));

    try {
      final record = _medicalRecords[recordId];
      return Right(record);
    } catch (e) {
      return Left(AuthenticationFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MedicalRecord>> createRecord({
    required MedicalRecord record,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));

    try {
      // Generate new ID
      final newRecord = record.copyWith(
        id: _generateRecordId(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save to database
      _medicalRecords[newRecord.id] = newRecord;

      if (kDebugMode) {
        print('Medical record created: ${newRecord.id} - ${newRecord.title}');
        print('Total records: ${_medicalRecords.length}');
      }

      return Right(newRecord);
    } catch (e) {
      return Left(AuthenticationFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MedicalRecord>> updateRecord({
    required String recordId,
    required MedicalRecord updatedRecord,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final existingRecord = _medicalRecords[recordId];
      if (existingRecord == null) {
        return Left(AuthenticationFailure('Record not found'));
      }

      // Update record
      final record = updatedRecord.copyWith(updatedAt: DateTime.now());

      // Save updated record
      _medicalRecords[recordId] = record;

      if (kDebugMode) {
        print('Medical record updated: $recordId');
      }

      return Right(record);
    } catch (e) {
      return Left(AuthenticationFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteRecord({required String recordId}) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 400));

    try {
      if (!_medicalRecords.containsKey(recordId)) {
        return Left(AuthenticationFailure('Record not found'));
      }

      // Delete record
      _medicalRecords.remove(recordId);

      if (kDebugMode) {
        print('Medical record deleted: $recordId');
      }

      return const Right(null);
    } catch (e) {
      return Left(AuthenticationFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Prescription>>> getActivePrescriptions({
    required String patientId,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      final prescriptions = _medicalRecords.values
          .where(
            (record) =>
                record.patientId == patientId &&
                record.recordType == 'prescription' &&
                record is Prescription &&
                record.isActive,
          )
          .cast<Prescription>()
          .toList();

      // Sort by expiry date (closest first)
      prescriptions.sort((a, b) {
        if (a.expiryDate == null && b.expiryDate == null) return 0;
        if (a.expiryDate == null) return 1;
        if (b.expiryDate == null) return -1;
        return a.expiryDate!.compareTo(b.expiryDate!);
      });

      return Right(prescriptions);
    } catch (e) {
      return Left(AuthenticationFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<LabResult>>> getRecentLabResults({
    required String patientId,
    int limit = 10,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      final labResults = _medicalRecords.values
          .where(
            (record) =>
                record.patientId == patientId &&
                record.recordType == 'lab_result' &&
                record is LabResult,
          )
          .cast<LabResult>()
          .toList();

      // Sort by date (newest first) and limit results
      labResults.sort((a, b) => b.recordDate.compareTo(a.recordDate));

      return Right(labResults.take(limit).toList());
    } catch (e) {
      return Left(AuthenticationFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, int>>> getRecordStats({
    required String patientId,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 400));

    try {
      var records = _medicalRecords.values.where(
        (record) => record.patientId == patientId,
      );

      // Filter by date range if provided
      if (fromDate != null) {
        records = records.where(
          (record) => record.recordDate.isAfter(
            fromDate.subtract(const Duration(days: 1)),
          ),
        );
      }

      if (toDate != null) {
        records = records.where(
          (record) =>
              record.recordDate.isBefore(toDate.add(const Duration(days: 1))),
        );
      }

      final stats = <String, int>{
        'total': records.length,
        'appointments': records
            .where((r) => r.recordType == 'appointment')
            .length,
        'prescriptions': records
            .where((r) => r.recordType == 'prescription')
            .length,
        'lab_results': records
            .where((r) => r.recordType == 'lab_result')
            .length,
        'recent': records.where((r) => r.isRecent).length,
        'this_year': records.where((r) => r.isThisYear).length,
      };

      return Right(stats);
    } catch (e) {
      return Left(AuthenticationFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> exportRecords({
    required String patientId,
    required String format,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1000));

    try {
      // In a real app, this would generate and return a file
      if (kDebugMode) {
        print('Exporting records for patient: $patientId in $format format');
        if (fromDate != null) print('From: $fromDate');
        if (toDate != null) print('To: $toDate');
      }

      return const Right(null);
    } catch (e) {
      return Left(AuthenticationFailure(e.toString()));
    }
  }

  // Helper methods
  String _generateRecordId() {
    return 'REC${DateTime.now().millisecondsSinceEpoch}_${_nextId++}';
  }

  // Mock data getters for testing
  static List<MedicalRecord> getAllRecords() => _medicalRecords.values.toList();
  static int getTotalRecordCount() => _medicalRecords.length;
  static void clearRecords() => _medicalRecords.clear();
  static void resetMockData() {
    _medicalRecords.clear();
    _nextId = 1;
    _initializeMockData();
  }

  // Implement missing methods required by interface
  @override
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

  @override
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

  @override
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

  @override
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
