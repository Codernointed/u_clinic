import 'package:json_annotation/json_annotation.dart';

part 'chat_message.g.dart';

@JsonSerializable()
class ChatMessage {
  final String id;
  @JsonKey(name: 'chat_id')
  final String chatId;
  @JsonKey(name: 'sender_id')
  final String senderId;
  @JsonKey(name: 'message_type')
  final String messageType;
  final String content;
  @JsonKey(name: 'file_attachments')
  final String? fileAttachments;
  @JsonKey(name: 'is_read')
  final bool isRead;
  @JsonKey(name: 'read_at')
  final DateTime? readAt;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.messageType,
    required this.content,
    this.fileAttachments,
    required this.isRead,
    this.readAt,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);

  Map<String, dynamic> toJson() => _$ChatMessageToJson(this);

  ChatMessage copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? messageType,
    String? content,
    String? fileAttachments,
    bool? isRead,
    DateTime? readAt,
    DateTime? createdAt,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      messageType: messageType ?? this.messageType,
      content: content ?? this.content,
      fileAttachments: fileAttachments ?? this.fileAttachments,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'ChatMessage(id: $id, chatId: $chatId, senderId: $senderId, messageType: $messageType, content: $content, fileAttachments: $fileAttachments, isRead: $isRead, readAt: $readAt, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatMessage &&
        other.id == id &&
        other.chatId == chatId &&
        other.senderId == senderId &&
        other.messageType == messageType &&
        other.content == content &&
        other.fileAttachments == fileAttachments &&
        other.isRead == isRead &&
        other.readAt == readAt &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        chatId.hashCode ^
        senderId.hashCode ^
        messageType.hashCode ^
        content.hashCode ^
        fileAttachments.hashCode ^
        isRead.hashCode ^
        readAt.hashCode ^
        createdAt.hashCode;
  }
}
