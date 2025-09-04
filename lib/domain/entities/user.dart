import 'package:equatable/equatable.dart';
import '../enums/user_role.dart';

class User extends Equatable {
  const User({
    required this.id,
    required this.email,
    required this.role,
    required this.firstName,
    required this.lastName,
    this.studentId,
    this.staffId,
    this.phoneNumber,
    this.dateOfBirth,
    this.profileImageUrl,
    this.isActive = true,
    this.isEmailVerified = false,
    this.is2FAEnabled = false,
    this.department,
    this.yearOfStudy,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.bloodGroup,
    this.allergies = const [],
    this.medications = const [],
    this.presentingSymptoms = const [],
    this.medicalConditions = const [],
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String email;
  final UserRole role;
  final String firstName;
  final String lastName;
  final String? studentId;
  final String? staffId;
  final String? phoneNumber;
  final DateTime? dateOfBirth;
  final String? profileImageUrl;
  final bool isActive;
  final bool isEmailVerified;
  final bool is2FAEnabled;

  // Academic/Professional Info
  final String? department;
  final int? yearOfStudy;

  // Emergency & Medical Info
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String? bloodGroup;
  final List<String> allergies;
  final List<String> medications;
  final List<String> presentingSymptoms;
  final List<String> medicalConditions;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  String get fullName => '$firstName $lastName';
  String get displayId => studentId ?? staffId ?? id;
  bool get isPatient => role == UserRole.patient;
  bool get isStaff => role == UserRole.staff;
  bool get isAdmin => role == UserRole.admin;

  User copyWith({
    String? id,
    String? email,
    UserRole? role,
    String? firstName,
    String? lastName,
    String? studentId,
    String? staffId,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? profileImageUrl,
    bool? isActive,
    bool? isEmailVerified,
    bool? is2FAEnabled,
    String? department,
    int? yearOfStudy,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? bloodGroup,
    List<String>? allergies,
    List<String>? medications,
    List<String>? presentingSymptoms,
    List<String>? medicalConditions,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      role: role ?? this.role,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      studentId: studentId ?? this.studentId,
      staffId: staffId ?? this.staffId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isActive: isActive ?? this.isActive,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      is2FAEnabled: is2FAEnabled ?? this.is2FAEnabled,
      department: department ?? this.department,
      yearOfStudy: yearOfStudy ?? this.yearOfStudy,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone:
          emergencyContactPhone ?? this.emergencyContactPhone,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      allergies: allergies ?? this.allergies,
      medications: medications ?? this.medications,
      presentingSymptoms: presentingSymptoms ?? this.presentingSymptoms,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    email,
    role,
    firstName,
    lastName,
    studentId,
    staffId,
    phoneNumber,
    dateOfBirth,
    profileImageUrl,
    isActive,
    isEmailVerified,
    is2FAEnabled,
    department,
    yearOfStudy,
    emergencyContactName,
    emergencyContactPhone,
    bloodGroup,
    allergies,
    medications,
    presentingSymptoms,
    medicalConditions,
    createdAt,
    updatedAt,
  ];
}
