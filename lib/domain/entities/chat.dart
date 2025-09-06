import 'package:json_annotation/json_annotation.dart';

part 'chat.g.dart';

@JsonSerializable()
class Chat {
  final String id;
  @JsonKey(name: 'patient_id')
  final String patientId;
  @JsonKey(name: 'patient_name')
  final String patientName;
  @JsonKey(name: 'staff_id')
  final String? staffId;
  @JsonKey(name: 'staff_name')
  final String? staffName;
  @JsonKey(name: 'chat_type')
  final String chatType; // consultation, support, emergency
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'last_message_at')
  final DateTime? lastMessageAt;
  final String status; // active, closed, pending
  final String? subject;
  final String? description;

  Chat({
    required this.id,
    required this.patientId,
    required this.patientName,
    this.staffId,
    this.staffName,
    required this.chatType,
    required this.createdAt,
    this.lastMessageAt,
    required this.status,
    this.subject,
    this.description,
  });

  factory Chat.fromJson(Map<String, dynamic> json) => _$ChatFromJson(json);

  Map<String, dynamic> toJson() => _$ChatToJson(this);

  Chat copyWith({
    String? id,
    String? patientId,
    String? patientName,
    String? staffId,
    String? staffName,
    String? chatType,
    DateTime? createdAt,
    DateTime? lastMessageAt,
    String? status,
    String? subject,
    String? description,
  }) {
    return Chat(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      staffId: staffId ?? this.staffId,
      staffName: staffName ?? this.staffName,
      chatType: chatType ?? this.chatType,
      createdAt: createdAt ?? this.createdAt,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      status: status ?? this.status,
      subject: subject ?? this.subject,
      description: description ?? this.description,
    );
  }
}
