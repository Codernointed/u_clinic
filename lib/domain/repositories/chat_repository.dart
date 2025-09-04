import 'package:dartz/dartz.dart';
import 'package:u_clinic/core/errors/failures.dart';
import 'package:u_clinic/domain/entities/chat.dart';
import 'package:u_clinic/domain/entities/chat_message.dart';
import 'package:u_clinic/domain/entities/user.dart';

abstract class ChatRepository {
  // Chat management
  Future<Either<Failure, List<Chat>>> getChats(String userId);
  Future<Either<Failure, Chat>> createChat(Chat chat);
  Future<Either<Failure, Chat>> updateChat(Chat chat);
  Future<Either<Failure, void>> closeChat(String chatId);

  // Message management
  Future<Either<Failure, List<ChatMessage>>> getChatMessages(String chatId);
  Future<Either<Failure, ChatMessage>> sendMessage(ChatMessage message);
  Future<Either<Failure, void>> markMessageAsRead(String messageId);
  Future<Either<Failure, void>> markAllMessagesAsRead(String chatId);

  // Real-time features
  Stream<List<ChatMessage>> watchChatMessages(String chatId);
  Stream<List<Chat>> watchUserChats(String userId);

  // File attachments
  Future<Either<Failure, String>> uploadAttachment(
    String filePath,
    String chatId,
  );
  Future<Either<Failure, void>> deleteAttachment(String attachmentUrl);

  // Search and filtering
  Future<Either<Failure, List<Chat>>> searchChats(String userId, String query);
  Future<Either<Failure, List<ChatMessage>>> searchMessages(
    String chatId,
    String query,
  );
}
