import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:u_clinic/domain/entities/chat.dart';
import 'package:u_clinic/domain/entities/chat_message.dart';
import 'package:u_clinic/domain/repositories/chat_repository.dart';
import 'package:u_clinic/domain/usecases/chat/create_chat_usecase.dart';
import 'package:u_clinic/domain/usecases/chat/get_chat_messages_usecase.dart';
import 'package:u_clinic/domain/usecases/chat/send_message_usecase.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository _chatRepository;
  final SendMessageUseCase _sendMessageUseCase;
  final GetChatMessagesUseCase _getChatMessagesUseCase;
  final CreateChatUseCase _createChatUseCase;

  StreamSubscription<List<Chat>>? _chatsSubscription;
  StreamSubscription<List<ChatMessage>>? _messagesSubscription;

  ChatBloc({
    required ChatRepository chatRepository,
    required SendMessageUseCase sendMessageUseCase,
    required GetChatMessagesUseCase getChatMessagesUseCase,
    required CreateChatUseCase createChatUseCase,
  }) : _chatRepository = chatRepository,
       _sendMessageUseCase = sendMessageUseCase,
       _getChatMessagesUseCase = getChatMessagesUseCase,
       _createChatUseCase = createChatUseCase,
       super(ChatInitial()) {
    on<LoadChats>(_onLoadChats);
    on<LoadChatMessages>(_onLoadChatMessages);
    on<SendMessage>(_onSendMessage);
    on<CreateChat>(_onCreateChat);
    on<SearchChats>(_onSearchChats);
    on<SearchMessages>(_onSearchMessages);
    on<MarkMessageAsRead>(_onMarkMessageAsRead);
    on<UploadAttachment>(_onUploadAttachment);
  }

  Future<void> _onLoadChats(LoadChats event, Emitter<ChatState> emit) async {
    try {
      emit(ChatLoading());
      print('🔄 Loading chats for user: ${event.userId}');

      final chatsResult = await _chatRepository.getChats(event.userId);

      chatsResult.fold(
        (failure) {
          print('❌ Failed to load chats: ${failure.message}');
          emit(ChatError(failure.message));
        },
        (chats) {
          print('✅ Loaded ${chats.length} chats');
          emit(ChatsLoaded(chats));

          // Start real-time subscription (moved outside to avoid emit after completion)
          _startChatsSubscription(event.userId);
        },
      );
    } catch (e) {
      print('❌ Error in _onLoadChats: $e');
      emit(ChatError('Failed to load chats: $e'));
    }
  }

  Future<void> _onLoadChatMessages(
    LoadChatMessages event,
    Emitter<ChatState> emit,
  ) async {
    try {
      emit(ChatLoading());
      print('🔄 Loading messages for chat: ${event.chatId}');

      final messagesResult = await _getChatMessagesUseCase(event.chatId);

      messagesResult.fold(
        (failure) {
          print('❌ Failed to load messages: ${failure.message}');
          emit(ChatError(failure.message));
        },
        (messages) {
          print('✅ Loaded ${messages.length} messages');
          emit(MessagesLoaded(messages, event.chatId));

          // Start real-time subscription (moved outside to avoid emit after completion)
          _startMessagesSubscription(event.chatId);
        },
      );
    } catch (e) {
      print('❌ Error in _onLoadChatMessages: $e');
      emit(ChatError('Failed to load messages: $e'));
    }
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ChatState> emit,
  ) async {
    try {
      print('📤 Sending message: ${event.message.content}');

      final result = await _sendMessageUseCase(
        SendMessageParams(message: event.message),
      );

      result.fold(
        (failure) {
          print('❌ Failed to send message: ${failure.message}');
          emit(ChatError(failure.message));
        },
        (message) {
          print('✅ Message sent successfully: ${message.id}');
          emit(MessageSent(message));
        },
      );
    } catch (e) {
      print('❌ Error in _onSendMessage: $e');
      emit(ChatError('Failed to send message: $e'));
    }
  }

  Future<void> _onCreateChat(CreateChat event, Emitter<ChatState> emit) async {
    try {
      print('➕ Creating new chat: ${event.chat.subject}');

      final result = await _createChatUseCase(
        CreateChatParams(chat: event.chat),
      );

      result.fold(
        (failure) {
          print('❌ Failed to create chat: ${failure.message}');
          emit(ChatError(failure.message));
        },
        (chat) {
          print('✅ Chat created successfully: ${chat.id}');
          emit(ChatCreated(chat));
        },
      );
    } catch (e) {
      print('❌ Error in _onCreateChat: $e');
      emit(ChatError('Failed to create chat: $e'));
    }
  }

  Future<void> _onSearchChats(
    SearchChats event,
    Emitter<ChatState> emit,
  ) async {
    try {
      print('🔍 Searching chats for: ${event.query}');

      final result = await _chatRepository.searchChats(
        event.userId,
        event.query,
      );

      result.fold(
        (failure) {
          print('❌ Failed to search chats: ${failure.message}');
          emit(ChatError(failure.message));
        },
        (chats) {
          print('🔍 Found ${chats.length} matching chats');
          emit(SearchResults(chats, event.query, 'chats'));
        },
      );
    } catch (e) {
      print('❌ Error in _onSearchChats: $e');
      emit(ChatError('Failed to search chats: $e'));
    }
  }

  Future<void> _onSearchMessages(
    SearchMessages event,
    Emitter<ChatState> emit,
  ) async {
    try {
      print('🔍 Searching messages for: ${event.query}');

      final result = await _chatRepository.searchMessages(
        event.chatId,
        event.query,
      );

      result.fold(
        (failure) {
          print('❌ Failed to search messages: ${failure.message}');
          emit(ChatError(failure.message));
        },
        (messages) {
          print('🔍 Found ${messages.length} matching messages');
          emit(SearchResults(messages, event.query, 'messages'));
        },
      );
    } catch (e) {
      print('❌ Error in _onSearchMessages: $e');
      emit(ChatError('Failed to search messages: $e'));
    }
  }

  Future<void> _onMarkMessageAsRead(
    MarkMessageAsRead event,
    Emitter<ChatState> emit,
  ) async {
    try {
      print('👁️ Marking message as read: ${event.messageId}');

      final result = await _chatRepository.markMessageAsRead(event.messageId);

      result.fold(
        (failure) {
          print('❌ Failed to mark message as read: ${failure.message}');
          emit(ChatError(failure.message));
        },
        (_) {
          print('✅ Message marked as read');
          // Don't emit new state, just log success
        },
      );
    } catch (e) {
      print('❌ Error in _onMarkMessageAsRead: $e');
      emit(ChatError('Failed to mark message as read: $e'));
    }
  }

  Future<void> _onUploadAttachment(
    UploadAttachment event,
    Emitter<ChatState> emit,
  ) async {
    try {
      emit(AttachmentUploading());
      print('📎 Uploading attachment: ${event.filePath}');

      final result = await _chatRepository.uploadAttachment(
        event.filePath,
        event.chatId,
      );

      result.fold(
        (failure) {
          print('❌ Failed to upload attachment: ${failure.message}');
          emit(ChatError(failure.message));
        },
        (url) {
          print('✅ Attachment uploaded: $url');
          emit(AttachmentUploaded(url));
        },
      );
    } catch (e) {
      print('❌ Error in _onUploadAttachment: $e');
      emit(ChatError('Failed to upload attachment: $e'));
    }
  }

  void _startChatsSubscription(String userId) {
    _chatsSubscription?.cancel();
    _chatsSubscription = _chatRepository.watchUserChats(userId).listen((chats) {
      print('🔄 Real-time chat update: ${chats.length} chats');
      // Ignore empty realtime payloads so we don't clear the UI
      if (chats.isEmpty) {
        return;
      }
      if (!isClosed) {
        emit(ChatsLoaded(chats));
      }
    });
  }

  void _startMessagesSubscription(String chatId) {
    _messagesSubscription?.cancel();
    _messagesSubscription = _chatRepository.watchChatMessages(chatId).listen((
      messages,
    ) {
      print('🔄 Real-time message update: ${messages.length} messages');
      // Ignore empty realtime payloads so we don't clear the thread
      if (messages.isEmpty) {
        return;
      }
      if (!isClosed) {
        emit(MessagesLoaded(messages, chatId));
      }
    });
  }

  @override
  Future<void> close() {
    _chatsSubscription?.cancel();
    _messagesSubscription?.cancel();
    return super.close();
  }
}
