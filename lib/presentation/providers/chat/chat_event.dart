import 'package:equatable/equatable.dart';
import 'package:u_clinic/domain/entities/chat.dart';
import 'package:u_clinic/domain/entities/chat_message.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class LoadChats extends ChatEvent {
  final String userId;

  const LoadChats(this.userId);

  @override
  List<Object?> get props => [userId];
}

class LoadChatMessages extends ChatEvent {
  final String chatId;

  const LoadChatMessages(this.chatId);

  @override
  List<Object?> get props => [chatId];
}

class SendMessage extends ChatEvent {
  final ChatMessage message;

  const SendMessage(this.message);

  @override
  List<Object?> get props => [message];
}

class CreateChat extends ChatEvent {
  final Chat chat;

  const CreateChat(this.chat);

  @override
  List<Object?> get props => [chat];
}

class SearchChats extends ChatEvent {
  final String userId;
  final String query;

  const SearchChats(this.userId, this.query);

  @override
  List<Object?> get props => [userId, query];
}

class SearchMessages extends ChatEvent {
  final String chatId;
  final String query;

  const SearchMessages(this.chatId, this.query);

  @override
  List<Object?> get props => [chatId, query];
}

class MarkMessageAsRead extends ChatEvent {
  final String messageId;

  const MarkMessageAsRead(this.messageId);

  @override
  List<Object?> get props => [messageId];
}

class UploadAttachment extends ChatEvent {
  final String filePath;
  final String chatId;

  const UploadAttachment(this.filePath, this.chatId);

  @override
  List<Object?> get props => [filePath, chatId];
}











