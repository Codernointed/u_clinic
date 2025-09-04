// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supabase_user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SupabaseUserModel _$SupabaseUserModelFromJson(Map<String, dynamic> json) =>
    SupabaseUserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      studentId: json['studentId'] as String?,
      staffId: json['staffId'] as String?,
      department: json['department'] as String?,
      profileImageUrl: json['profileImageUrl'] as String?,
      dateOfBirth: json['dateOfBirth'] == null
          ? null
          : DateTime.parse(json['dateOfBirth'] as String),
      gender: json['gender'] as String?,
      bloodType: json['bloodType'] as String?,
      emergencyContactName: json['emergencyContactName'] as String?,
      emergencyContactPhone: json['emergencyContactPhone'] as String?,
      emergencyContactRelationship:
          json['emergencyContactRelationship'] as String?,
      presentingSymptoms: (json['presentingSymptoms'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      medicalConditions: (json['medicalConditions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      allergies:
          (json['allergies'] as List<dynamic>).map((e) => e as String).toList(),
      currentMedications: (json['currentMedications'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      role: $enumDecode(_$UserRoleEnumMap, json['role']),
      isActive: json['isActive'] as bool,
      isEmailVerified: json['isEmailVerified'] as bool,
      isPhoneVerified: json['isPhoneVerified'] as bool,
      twoFactorEnabled: json['twoFactorEnabled'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$SupabaseUserModelToJson(SupabaseUserModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'phone': instance.phone,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'studentId': instance.studentId,
      'staffId': instance.staffId,
      'department': instance.department,
      'profileImageUrl': instance.profileImageUrl,
      'dateOfBirth': instance.dateOfBirth?.toIso8601String(),
      'gender': instance.gender,
      'bloodType': instance.bloodType,
      'emergencyContactName': instance.emergencyContactName,
      'emergencyContactPhone': instance.emergencyContactPhone,
      'emergencyContactRelationship': instance.emergencyContactRelationship,
      'presentingSymptoms': instance.presentingSymptoms,
      'medicalConditions': instance.medicalConditions,
      'allergies': instance.allergies,
      'currentMedications': instance.currentMedications,
      'role': _$UserRoleEnumMap[instance.role]!,
      'isActive': instance.isActive,
      'isEmailVerified': instance.isEmailVerified,
      'isPhoneVerified': instance.isPhoneVerified,
      'twoFactorEnabled': instance.twoFactorEnabled,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$UserRoleEnumMap = {
  UserRole.patient: 'patient',
  UserRole.staff: 'staff',
  UserRole.admin: 'admin',
};
