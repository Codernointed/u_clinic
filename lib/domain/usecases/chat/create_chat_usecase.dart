import 'package:dartz/dartz.dart';
import 'package:u_clinic/core/errors/failures.dart';
import 'package:u_clinic/domain/entities/chat.dart';
import 'package:u_clinic/domain/repositories/chat_repository.dart';
import '../usecase.dart';

class CreateChatUseCase implements UseCase<Chat, CreateChatParams> {
  final ChatRepository _chatRepository;

  CreateChatUseCase(this._chatRepository);

  @override
  Future<Either<Failure, Chat>> call(CreateChatParams params) async {
    return await _chatRepository.createChat(params.chat);
  }
}

class CreateChatParams {
  final Chat chat;

  CreateChatParams({required this.chat});
}











