import 'package:dartz/dartz.dart';
import 'package:u_clinic/core/errors/failures.dart';
import '../usecase.dart';
import 'package:u_clinic/domain/entities/chat_message.dart';
import 'package:u_clinic/domain/repositories/chat_repository.dart';

class SendMessageUseCase implements UseCase<ChatMessage, SendMessageParams> {
  final ChatRepository _chatRepository;

  SendMessageUseCase(this._chatRepository);

  @override
  Future<Either<Failure, ChatMessage>> call(SendMessageParams params) async {
    return await _chatRepository.sendMessage(params.message);
  }
}

class SendMessageParams {
  final ChatMessage message;

  SendMessageParams({required this.message});
}
