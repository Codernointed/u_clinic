import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:u_clinic/core/routes/app_router.dart';
import 'package:u_clinic/core/services/supabase_service.dart';
import 'package:u_clinic/core/services/notification_service.dart';
import 'package:u_clinic/core/theme/app_theme.dart';
import 'package:u_clinic/data/repositories/supabase_auth_repository.dart';
import 'package:u_clinic/data/repositories/supabase_chat_repository.dart';
import 'package:u_clinic/data/repositories/supabase_appointment_repository.dart';
import 'package:u_clinic/domain/usecases/auth/sign_in_usecase.dart';
import 'package:u_clinic/domain/usecases/chat/create_chat_usecase.dart';
import 'package:u_clinic/domain/usecases/chat/get_chat_messages_usecase.dart';
import 'package:u_clinic/domain/usecases/chat/send_message_usecase.dart';
import 'package:u_clinic/presentation/providers/auth/auth_bloc.dart';
// Removed unused imports
import 'package:u_clinic/presentation/providers/chat/chat_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await SupabaseService.instance.initialize();
  
  // Initialize Notification Service
  await notificationService.initialize();

  runApp(const UClinicApp());
}

class UClinicApp extends StatelessWidget {
  const UClinicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<SupabaseAuthRepository>(
          create: (context) => SupabaseAuthRepository(SupabaseService.instance),
        ),
        RepositoryProvider<SupabaseAppointmentRepository>(
          create: (context) =>
              SupabaseAppointmentRepository(SupabaseService.instance),
        ),
        RepositoryProvider<SupabaseChatRepository>(
          create: (context) => SupabaseChatRepository(SupabaseService.instance),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              authRepository: context.read<SupabaseAuthRepository>(),
              signInUseCase: SignInUseCase(
                context.read<SupabaseAuthRepository>(),
              ),
            ),
          ),
          BlocProvider<ChatBloc>(
            create: (context) => ChatBloc(
              chatRepository: SupabaseChatRepository(SupabaseService.instance),
              sendMessageUseCase: SendMessageUseCase(
                SupabaseChatRepository(SupabaseService.instance),
              ),
              getChatMessagesUseCase: GetChatMessagesUseCase(
                SupabaseChatRepository(SupabaseService.instance),
              ),
              createChatUseCase: CreateChatUseCase(
                SupabaseChatRepository(SupabaseService.instance),
              ),
            ),
          ),
        ],
        child: MaterialApp(
          title: 'UMaT E-Health',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.lightTheme, // Using light theme for both for now
          themeMode: ThemeMode.system,
          onGenerateRoute: AppRouter.generateRoute,
          initialRoute: AppRouter.splash,
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
