import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user.dart';
import '../../domain/enums/user_role.dart';

part 'supabase_user_model.g.dart';

@JsonSerializable()
class SupabaseUserModel {
  final String id;
  final String email;
  final String? phone;
  final String firstName;
  final String lastName;
  final String? studentId;
  final String? staffId;
  final String? department;
  final String? profileImageUrl;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? bloodType;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String? emergencyContactRelationship;
  final List<String> presentingSymptoms;
  final List<String> medicalConditions;
  final List<String> allergies;
  final List<String> currentMedications;
  final UserRole role;
  final bool isActive;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final bool twoFactorEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  SupabaseUserModel({
    required this.id,
    required this.email,
    this.phone,
    required this.firstName,
    required this.lastName,
    this.studentId,
    this.staffId,
    this.department,
    this.profileImageUrl,
    this.dateOfBirth,
    this.gender,
    this.bloodType,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.emergencyContactRelationship,
    required this.presentingSymptoms,
    required this.medicalConditions,
    required this.allergies,
    required this.currentMedications,
    required this.role,
    required this.isActive,
    required this.isEmailVerified,
    required this.isPhoneVerified,
    required this.twoFactorEnabled,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SupabaseUserModel.fromJson(Map<String, dynamic> json) =>
      _$SupabaseUserModelFromJson(json);

  Map<String, dynamic> toJson() => _$SupabaseUserModelToJson(this);

  /// Convert to domain entity
  User toDomain() {
    return User(
      id: id,
      email: email,
      firstName: firstName,
      lastName: lastName,
      studentId: studentId,
      staffId: staffId,
      department: department,
      profileImageUrl: profileImageUrl,
      dateOfBirth: dateOfBirth,
      emergencyContactName: emergencyContactName,
      emergencyContactPhone: emergencyContactPhone,
      bloodGroup: bloodType,
      presentingSymptoms: presentingSymptoms,
      medicalConditions: medicalConditions,
      allergies: allergies,
      medications: currentMedications,
      role: role,
      isActive: isActive,
      isEmailVerified: isEmailVerified,
      is2FAEnabled: twoFactorEnabled,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Convert from domain entity
  factory SupabaseUserModel.fromDomain(User user) {
    return SupabaseUserModel(
      id: user.id,
      email: user.email,
      firstName: user.firstName,
      lastName: user.lastName,
      studentId: user.studentId,
      staffId: user.staffId,
      department: user.department,
      profileImageUrl: user.profileImageUrl,
      dateOfBirth: user.dateOfBirth,
      emergencyContactName: user.emergencyContactName,
      emergencyContactPhone: user.emergencyContactPhone,
      bloodType: user.bloodGroup,
      presentingSymptoms: user.presentingSymptoms,
      medicalConditions: user.medicalConditions,
      allergies: user.allergies,
      currentMedications: user.medications,
      role: user.role,
      isActive: user.isActive,
      isEmailVerified: user.isEmailVerified,
      isPhoneVerified:
          false, // Default value since User entity doesn't have this
      twoFactorEnabled: user.is2FAEnabled,
      createdAt: user.createdAt ?? DateTime.now(), // Provide default if null
      updatedAt: user.updatedAt ?? DateTime.now(), // Provide default if null
    );
  }

  /// Copy with method
  SupabaseUserModel copyWith({
    String? id,
    String? email,
    String? phone,
    String? firstName,
    String? lastName,
    String? studentId,
    String? staffId,
    String? department,
    String? profileImageUrl,
    DateTime? dateOfBirth,
    String? gender,
    String? bloodType,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? emergencyContactRelationship,
    List<String>? presentingSymptoms,
    List<String>? medicalConditions,
    List<String>? allergies,
    List<String>? currentMedications,
    UserRole? role,
    bool? isActive,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    bool? twoFactorEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SupabaseUserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      studentId: studentId ?? this.studentId,
      staffId: staffId ?? this.staffId,
      department: department ?? this.department,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      bloodType: bloodType ?? this.bloodType,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone:
          emergencyContactPhone ?? this.emergencyContactPhone,
      emergencyContactRelationship:
          emergencyContactRelationship ?? this.emergencyContactRelationship,
      presentingSymptoms: presentingSymptoms ?? this.presentingSymptoms,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      allergies: allergies ?? this.allergies,
      currentMedications: currentMedications ?? this.currentMedications,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      twoFactorEnabled: twoFactorEnabled ?? this.twoFactorEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
