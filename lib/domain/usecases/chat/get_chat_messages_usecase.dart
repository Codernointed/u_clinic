import 'package:dartz/dartz.dart';
import 'package:u_clinic/core/errors/failures.dart';
import 'package:u_clinic/domain/entities/chat_message.dart';
import 'package:u_clinic/domain/repositories/chat_repository.dart';
import '../usecase.dart';

class GetChatMessagesUseCase implements UseCase<List<ChatMessage>, String> {
  final ChatRepository _chatRepository;

  GetChatMessagesUseCase(this._chatRepository);

  @override
  Future<Either<Failure, List<ChatMessage>>> call(String chatId) async {
    return await _chatRepository.getChatMessages(chatId);
  }
}











