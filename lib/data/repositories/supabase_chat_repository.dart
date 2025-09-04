import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:u_clinic/core/errors/failures.dart';
import 'package:u_clinic/core/services/supabase_service.dart';
import 'package:u_clinic/domain/entities/chat.dart';
import 'package:u_clinic/domain/entities/chat_message.dart';
import 'package:u_clinic/domain/repositories/chat_repository.dart';

class SupabaseChatRepository implements ChatRepository {
  final SupabaseService _supabase;

  SupabaseChatRepository(this._supabase);

  // ---------------------- Chat management ----------------------
  @override
  Future<Either<Failure, List<Chat>>> getChats(String userId) async {
    try {
      final data = await _supabase
          .from('chats')
          .select()
          .or('patient_id.eq.$userId,staff_id.eq.$userId')
          .order('created_at', ascending: false);

      final chats = (data as List)
          .map((e) => Chat.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      return Right(chats);
    } catch (e) {
      return Left(ServerFailure('Failed to fetch chats: $e'));
    }
  }

  @override
  Future<Either<Failure, Chat>> createChat(Chat chat) async {
    try {
      final inserted = await _supabase
          .from('chats')
          .insert({
            'patient_id': chat.patientId,
            'patient_name': chat.patientName,
            'chat_type': chat.chatType,
            'subject': chat.subject,
            'description': chat.description,
            'status': chat.status,
          })
          .select()
          .single();

      return Right(Chat.fromJson(Map<String, dynamic>.from(inserted)));
    } catch (e) {
      return Left(ServerFailure('Failed to create chat: $e'));
    }
  }

  @override
  Future<Either<Failure, Chat>> updateChat(Chat chat) async {
    try {
      final updated = await _supabase
          .from('chats')
          .update({
            'patient_name': chat.patientName,
            'chat_type': chat.chatType,
            'subject': chat.subject,
            'description': chat.description,
            'status': chat.status,
            'last_message_at': chat.lastMessageAt?.toIso8601String(),
          })
          .eq('id', chat.id)
          .select()
          .single();

      return Right(Chat.fromJson(Map<String, dynamic>.from(updated)));
    } catch (e) {
      return Left(ServerFailure('Failed to update chat: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> closeChat(String chatId) async {
    try {
      await _supabase
          .from('chats')
          .update({'status': 'closed'})
          .eq('id', chatId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to close chat: $e'));
    }
  }

  // ---------------------- Message management ----------------------
  @override
  Future<Either<Failure, List<ChatMessage>>> getChatMessages(
    String chatId,
  ) async {
    try {
      final data = await _supabase
          .from('chat_messages')
          .select()
          .eq('chat_id', chatId)
          .order(
            'created_at',
            ascending: true,
          ); // oldest first (bottom display)

      final messages = (data as List)
          .map((e) => ChatMessage.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      return Right(messages);
    } catch (e) {
      return Left(ServerFailure('Failed to fetch messages: $e'));
    }
  }

  @override
  Future<Either<Failure, ChatMessage>> sendMessage(ChatMessage message) async {
    try {
      final inserted = await _supabase
          .from('chat_messages')
          .insert({
            'chat_id': message.chatId,
            'sender_id': message.senderId,
            'message_type': message.messageType,
            'content': message.content,
            'is_read': message.isRead,
          })
          .select()
          .single();

      // Touch chat last_message_at for ordering
      await _supabase
          .from('chats')
          .update({'last_message_at': DateTime.now().toIso8601String()})
          .eq('id', message.chatId);

      return Right(ChatMessage.fromJson(Map<String, dynamic>.from(inserted)));
    } catch (e) {
      return Left(ServerFailure('Failed to send message: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> markMessageAsRead(String messageId) async {
    try {
      await _supabase
          .from('chat_messages')
          .update({
            'is_read': true,
            'read_at': DateTime.now().toIso8601String(),
          })
          .eq('id', messageId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to mark message as read: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> markAllMessagesAsRead(String chatId) async {
    try {
      await _supabase
          .from('chat_messages')
          .update({
            'is_read': true,
            'read_at': DateTime.now().toIso8601String(),
          })
          .eq('chat_id', chatId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to mark messages as read: $e'));
    }
  }

  // ---------------------- Real-time streams ----------------------
  @override
  Stream<List<ChatMessage>> watchChatMessages(String chatId) {
    return _supabase.client
        .from('chat_messages')
        .stream(primaryKey: ['id'])
        .eq('chat_id', chatId)
        .order('created_at', ascending: true) // oldest first (bottom display)
        .map(
          (rows) => rows
              .map((e) => ChatMessage.fromJson(Map<String, dynamic>.from(e)))
              .toList(),
        );
  }

  @override
  Stream<List<Chat>> watchUserChats(String userId) {
    // Supabase stream builder doesn't support `.or()` directly; filter client-side.
    return _supabase.client
        .from('chats')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((rows) {
          // Filter for either patient or staff participation
          final filtered = rows.where((row) {
            final map = Map<String, dynamic>.from(row);
            return map['patient_id'] == userId || map['staff_id'] == userId;
          }).toList();

          return filtered
              .map((e) => Chat.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        });
  }

  // ---------------------- Attachments ----------------------
  @override
  Future<Either<Failure, String>> uploadAttachment(
    String filePath,
    String chatId,
  ) async {
    try {
      // Expecting caller to provide a public URL; placeholder returns the path
      return Right(filePath);
    } catch (e) {
      return Left(ServerFailure('Failed to upload attachment: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAttachment(String attachmentUrl) async {
    try {
      // No-op placeholder
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to delete attachment: $e'));
    }
  }

  // ---------------------- Search ----------------------
  @override
  Future<Either<Failure, List<Chat>>> searchChats(
    String userId,
    String query,
  ) async {
    try {
      final data = await _supabase
          .from('chats')
          .select()
          .or('patient_id.eq.$userId,staff_id.eq.$userId')
          .or('subject.ilike.%$query%,patient_name.ilike.%$query%')
          .order('created_at', ascending: false);

      final chats = (data as List)
          .map((e) => Chat.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      return Right(chats);
    } catch (e) {
      return Left(ServerFailure('Failed to search chats: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ChatMessage>>> searchMessages(
    String chatId,
    String query,
  ) async {
    try {
      final data = await _supabase
          .from('chat_messages')
          .select()
          .eq('chat_id', chatId)
          .ilike('content', '%$query%')
          .order('created_at');

      final messages = (data as List)
          .map((e) => ChatMessage.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      return Right(messages);
    } catch (e) {
      return Left(ServerFailure('Failed to search messages: $e'));
    }
  }
}
