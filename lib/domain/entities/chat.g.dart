// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Chat _$ChatFromJson(Map<String, dynamic> json) => Chat(
      id: json['id'] as String,
      patientId: json['patient_id'] as String,
      patientName: json['patient_name'] as String,
      chatType: json['chat_type'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastMessageAt: json['last_message_at'] == null
          ? null
          : DateTime.parse(json['last_message_at'] as String),
      status: json['status'] as String,
      subject: json['subject'] as String?,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$ChatToJson(Chat instance) => <String, dynamic>{
      'id': instance.id,
      'patient_id': instance.patientId,
      'patient_name': instance.patientName,
      'chat_type': instance.chatType,
      'created_at': instance.createdAt.toIso8601String(),
      'last_message_at': instance.lastMessageAt?.toIso8601String(),
      'status': instance.status,
      'subject': instance.subject,
      'description': instance.description,
    };
