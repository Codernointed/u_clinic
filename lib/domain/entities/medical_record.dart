import 'package:equatable/equatable.dart';

class MedicalRecord extends Equatable {
  final String id;
  final String patientId;
  final String patientName;
  final String
  recordType; // 'appointment', 'prescription', 'lab_result', 'vaccination'
  final DateTime recordDate;
  final String title;
  final String description;
  final String? doctorName;
  final String? department;
  final Map<String, dynamic>? details;
  final List<String>? attachments;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const MedicalRecord({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.recordType,
    required this.recordDate,
    required this.title,
    required this.description,
    this.doctorName,
    this.department,
    this.details,
    this.attachments,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  MedicalRecord copyWith({
    String? id,
    String? patientId,
    String? patientName,
    String? recordType,
    DateTime? recordDate,
    String? title,
    String? description,
    String? doctorName,
    String? department,
    Map<String, dynamic>? details,
    List<String>? attachments,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MedicalRecord(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      recordType: recordType ?? this.recordType,
      recordDate: recordDate ?? this.recordDate,
      title: title ?? this.title,
      description: description ?? this.description,
      doctorName: doctorName ?? this.doctorName,
      department: department ?? this.department,
      details: details ?? this.details,
      attachments: attachments ?? this.attachments,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isRecent =>
      recordDate.isAfter(DateTime.now().subtract(const Duration(days: 30)));

  bool get isThisYear => recordDate.year == DateTime.now().year;

  String get formattedDate =>
      '${recordDate.day}/${recordDate.month}/${recordDate.year}';

  String get formattedDateTime =>
      '${formattedDate} at ${recordDate.hour.toString().padLeft(2, '0')}:${recordDate.minute.toString().padLeft(2, '0')}';

  @override
  List<Object?> get props => [
    id,
    patientId,
    patientName,
    recordType,
    recordDate,
    title,
    description,
    doctorName,
    department,
    details,
    attachments,
    isActive,
    createdAt,
    updatedAt,
  ];
}

class Prescription extends MedicalRecord {
  final String medicationName;
  final String dosage;
  final String frequency;
  final String duration;
  final String? instructions;
  final DateTime? expiryDate;
  final int refillsRemaining;
  final bool requiresRefill;

  const Prescription({
    required super.id,
    required super.patientId,
    required super.patientName,
    required super.recordDate,
    required super.title,
    required super.description,
    required this.medicationName,
    required this.dosage,
    required this.frequency,
    required this.duration,
    this.instructions,
    this.expiryDate,
    this.refillsRemaining = 0,
    this.requiresRefill = false,
    super.doctorName,
    super.department,
    super.details,
    super.attachments,
    super.isActive,
    required super.createdAt,
    super.updatedAt,
  }) : super(recordType: 'prescription');

  @override
  Prescription copyWith({
    String? id,
    String? patientId,
    String? patientName,
    String? recordType,
    DateTime? recordDate,
    String? title,
    String? description,
    String? doctorName,
    String? department,
    Map<String, dynamic>? details,
    List<String>? attachments,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? medicationName,
    String? dosage,
    String? frequency,
    String? duration,
    String? instructions,
    DateTime? expiryDate,
    int? refillsRemaining,
    bool? requiresRefill,
  }) {
    return Prescription(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      recordDate: recordDate ?? this.recordDate,
      title: title ?? this.title,
      description: description ?? this.description,
      medicationName: medicationName ?? this.medicationName,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      duration: duration ?? this.duration,
      instructions: instructions ?? this.instructions,
      expiryDate: expiryDate ?? this.expiryDate,
      refillsRemaining: refillsRemaining ?? this.refillsRemaining,
      requiresRefill: requiresRefill ?? this.requiresRefill,
      doctorName: doctorName ?? this.doctorName,
      department: department ?? this.department,
      details: details ?? this.details,
      attachments: attachments ?? this.attachments,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    ...super.props,
    medicationName,
    dosage,
    frequency,
    duration,
    instructions,
    expiryDate,
    refillsRemaining,
    requiresRefill,
  ];
}

class LabResult extends MedicalRecord {
  final String testName;
  final String result;
  final String? normalRange;
  final String? unit;
  final bool isAbnormal;
  final String? interpretation;
  final String? recommendations;

  const LabResult({
    required super.id,
    required super.patientId,
    required super.patientName,
    required super.recordDate,
    required super.title,
    required super.description,
    required this.testName,
    required this.result,
    this.normalRange,
    this.unit,
    this.isAbnormal = false,
    this.interpretation,
    this.recommendations,
    super.doctorName,
    super.department,
    super.details,
    super.attachments,
    super.isActive,
    required super.createdAt,
    super.updatedAt,
  }) : super(recordType: 'lab_result');

  @override
  LabResult copyWith({
    String? id,
    String? patientId,
    String? patientName,
    String? recordType,
    DateTime? recordDate,
    String? title,
    String? description,
    String? doctorName,
    String? department,
    Map<String, dynamic>? details,
    List<String>? attachments,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? testName,
    String? result,
    String? normalRange,
    String? unit,
    bool? isAbnormal,
    String? interpretation,
    String? recommendations,
  }) {
    return LabResult(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      recordDate: recordDate ?? this.recordDate,
      title: title ?? this.title,
      description: description ?? this.description,
      testName: testName ?? this.testName,
      result: result ?? this.result,
      normalRange: normalRange ?? this.normalRange,
      unit: unit ?? this.unit,
      isAbnormal: isAbnormal ?? this.isAbnormal,
      interpretation: interpretation ?? this.interpretation,
      recommendations: recommendations ?? this.recommendations,
      doctorName: doctorName ?? this.doctorName,
      department: department ?? this.department,
      details: details ?? this.details,
      attachments: attachments ?? this.attachments,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    ...super.props,
    testName,
    result,
    normalRange,
    unit,
    isAbnormal,
    interpretation,
    recommendations,
  ];
}
