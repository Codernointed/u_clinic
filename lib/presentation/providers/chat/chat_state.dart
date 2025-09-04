import 'package:equatable/equatable.dart';
import 'package:u_clinic/domain/entities/chat.dart';
import 'package:u_clinic/domain/entities/chat_message.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatsLoaded extends ChatState {
  final List<Chat> chats;

  const ChatsLoaded(this.chats);

  @override
  List<Object?> get props => [chats];
}

class MessagesLoaded extends ChatState {
  final List<ChatMessage> messages;
  final String chatId;

  const MessagesLoaded(this.messages, this.chatId);

  @override
  List<Object?> get props => [messages, chatId];
}

class MessageSent extends ChatState {
  final ChatMessage message;

  const MessageSent(this.message);

  @override
  List<Object?> get props => [message];
}

class ChatCreated extends ChatState {
  final Chat chat;

  const ChatCreated(this.chat);

  @override
  List<Object?> get props => [chat];
}

class ChatError extends ChatState {
  final String message;

  const ChatError(this.message);

  @override
  List<Object?> get props => [message];
}

class AttachmentUploading extends ChatState {}

class AttachmentUploaded extends ChatState {
  final String url;

  const AttachmentUploaded(this.url);

  @override
  List<Object?> get props => [url];
}

class SearchResults extends ChatState {
  final List<dynamic> results;
  final String query;
  final String searchType; // 'chats' or 'messages'

  const SearchResults(this.results, this.query, this.searchType);

  @override
  List<Object?> get props => [results, query, searchType];
}





